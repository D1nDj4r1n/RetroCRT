/*
 * iced-bar - Waybar module for Projekt Blackwall (FreeBSD).
 *
 *   iced-bar               ICE level from $ICED_STATE_DIR (default
 *                          /var/run/iced): files "level" and "countdown"
 *   iced-bar --blackwall   Tails session from $JACK_STATE_DIR (default
 *                          /var/run/jack): file "session"
 *
 * Prints one line of Waybar JSON each time the state changes (custom module,
 * continuous "exec", "return-type": "json").
 *
 * FreeBSD: no polling. kqueue EVFILT_VNODE watches the parent directory (the
 * state directory being removed and created again), the state directory
 * (files created, removed, renamed) and each file (written in place).
 * EVFILT_TIMER ticks once a second only while "countdown" exists. Once the
 * parent directory is open the process enters Capsicum capability mode and
 * only opens files below it with openat().
 *
 * File contents are untrusted: size-limited, validated, never executed and
 * always JSON-escaped. Missing or invalid means "off".
 *
 * Other systems (development and tests only): the state is re-read once a
 * second.
 */
#if !defined(__FreeBSD__)
#define _POSIX_C_SOURCE 200809L
#endif

#include <sys/types.h>
#include <sys/stat.h>

#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#ifdef __FreeBSD__
#include <sys/capsicum.h>
#include <sys/event.h>
#endif

#define MAX_FILE 1024   /* bytes; a longer file is invalid */
#define MAX_FIELDS 32   /* key=value fields after the level */
#define MAX_DIGITS 18   /* countdown: fits in long long */
#define OUT_MAX 8192

enum mode { MODE_ICE, MODE_BLACKWALL };

enum fstatus { F_MISSING, F_VALID, F_INVALID, F_UNREADABLE };

struct state {
	int dir_ok;
	/* ICE */
	enum fstatus level;
	char level_word[16];
	char fields[MAX_FIELDS][MAX_FILE + 1];
	int nfields;
	int armed;
	long long deadline;
	/* Blackwall */
	int session;
	long long session_mtime;
};

static const char *const levels[] = { "ZIELONY", "ZOLTY", "CZERWONY", "CZARNY" };
static const char *const classes[] = { "zielony", "zolty", "czerwony", "czarny" };

static enum mode mode = MODE_ICE;
static const char *state_dir;    /* as given, for messages */
static char parent_path[4096];
static char base_name[256];
static int parentfd = -1;
static int dirfd_ = -1;
static int filefd[2] = { -1, -1 };
static char last_out[OUT_MAX];

#ifdef __FreeBSD__
static int kq = -1;
static int timer_on;
#endif

/* Best effort: nothing more can be done if stderr is gone. */
static void
say(const char *s, size_t len)
{
	ssize_t w = write(STDERR_FILENO, s, len);
	(void)w;
}

static void
die(const char *what)
{
	char msg[512];
	int n = snprintf(msg, sizeof msg, "iced-bar: %s: %s\n", what, strerror(errno));
	if (n > 0)
		say(msg, (size_t)n < sizeof msg ? (size_t)n : sizeof msg - 1);
	exit(1);
}

/* Copy src into dst[cap] or die; nothing is ever silently truncated. */
static void
copy_path(char *dst, size_t cap, const char *src, size_t len)
{
	if (len >= cap) {
		errno = ENAMETOOLONG;
		die(state_dir);
	}
	memcpy(dst, src, len);
	dst[len] = '\0';
}

/* ---- output ------------------------------------------------------------ */

struct buf {
	char s[OUT_MAX];
	size_t n;
	int overflow;
};

static void
put(struct buf *b, const char *s, size_t len)
{
	if (b->n + len >= sizeof b->s) {
		b->overflow = 1;
		return;
	}
	memcpy(b->s + b->n, s, len);
	b->n += len;
	b->s[b->n] = '\0';
}

static void
puts_raw(struct buf *b, const char *s)
{
	put(b, s, strlen(s));
}

/* JSON string body: quote, backslash and control characters escaped. */
static void
puts_json(struct buf *b, const char *s)
{
	char esc[8];
	for (; *s != '\0'; s++) {
		unsigned char c = (unsigned char)*s;
		if (c == '"')
			put(b, "\\\"", 2);
		else if (c == '\\')
			put(b, "\\\\", 2);
		else if (c == '\n')
			put(b, "\\n", 2);
		else if (c < 0x20) {
			(void)snprintf(esc, sizeof esc, "\\u%04x", c);
			put(b, esc, 6);
		} else
			put(b, (const char *)&c, 1);
	}
}

static void
emit(const struct buf *b)
{
	size_t off = 0;
	if (b->overflow || strcmp(b->s, last_out) == 0)
		return;
	while (off < b->n) {
		ssize_t w = write(STDOUT_FILENO, b->s + off, b->n - off);
		if (w == -1) {
			if (errno == EINTR)
				continue;
			exit(0);        /* Waybar went away (EPIPE) */
		}
		off += (size_t)w;
	}
	memcpy(last_out, b->s, b->n + 1);
}

static void
iso_utc(long long t, char *out, size_t cap)
{
	struct tm tm;
	time_t tt = (time_t)t;
	if (gmtime_r(&tt, &tm) == NULL || strftime(out, cap, "%Y-%m-%dT%H:%M:%SZ", &tm) == 0)
		(void)snprintf(out, cap, "?");
}

static long long
now_s(void)
{
	struct timespec ts;
	if (clock_gettime(CLOCK_REALTIME, &ts) == -1)
		die("clock_gettime");
	return (long long)ts.tv_sec;
}

/* ---- validation (same rules as iced-bar.sh) ----------------------------- */

/* Strip trailing newlines; every byte left must be printable ASCII. */
static int
printable_line(char *s, size_t *len)
{
	size_t i;
	while (*len > 0 && s[*len - 1] == '\n')
		s[--*len] = '\0';
	if (*len == 0)
		return 0;
	for (i = 0; i < *len; i++)
		if ((unsigned char)s[i] < 0x20 || (unsigned char)s[i] > 0x7e)
			return 0;
	return 1;
}

static int
key_char(char c)
{
	return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') ||
	    (c >= '0' && c <= '9') || c == '_' || c == '.' || c == '-';
}

static int
parse_level(char *s, size_t len, struct state *st)
{
	char *tok, *save = NULL;
	int first = 1;
	size_t i;

	st->nfields = 0;
	st->level_word[0] = '\0';
	if (!printable_line(s, &len))
		return 0;
	for (tok = strtok_r(s, " ", &save); tok != NULL; tok = strtok_r(NULL, " ", &save)) {
		if (first) {
			for (i = 0; i < sizeof levels / sizeof levels[0]; i++)
				if (strcmp(tok, levels[i]) == 0)
					break;
			if (i == sizeof levels / sizeof levels[0])
				return 0;
			memcpy(st->level_word, levels[i], strlen(levels[i]) + 1);
			first = 0;
			continue;
		}
		{
			char *eq = strchr(tok, '=');
			char *k;
			if (eq == NULL || eq == tok || st->nfields == MAX_FIELDS)
				return 0;
			for (k = tok; k < eq; k++)
				if (!key_char(*k))
					return 0;
			copy_path(st->fields[st->nfields++], sizeof st->fields[0], tok, strlen(tok));
		}
	}
	return !first;
}

static int
parse_countdown(char *s, size_t len, long long *out)
{
	size_t i;
	long long v = 0;
	if (!printable_line(s, &len))
		return 0;
	while (len > 1 && s[0] == '0') {        /* leading zeros */
		s++;
		len--;
	}
	if (len > MAX_DIGITS)
		return 0;
	for (i = 0; i < len; i++) {
		if (s[i] < '0' || s[i] > '9')
			return 0;
		v = v * 10 + (s[i] - '0');
	}
	*out = v;
	return 1;
}

/* ---- watching ----------------------------------------------------------- */

static void
watch(int fd, unsigned int fflags)
{
#ifdef __FreeBSD__
	struct kevent ev;
	EV_SET(&ev, fd, EVFILT_VNODE, EV_ADD | EV_CLEAR, fflags, 0, NULL);
	if (kevent(kq, &ev, 1, NULL, 0, NULL) == -1)
		die("kevent vnode");
#else
	(void)fd;
	(void)fflags;
#endif
}

static void
set_timer(int on)
{
#ifdef __FreeBSD__
	struct kevent ev;
	if (on == timer_on)
		return;
	EV_SET(&ev, 1, EVFILT_TIMER, on ? EV_ADD : EV_DELETE, 0, 1000, NULL);
	if (kevent(kq, &ev, 1, NULL, 0, NULL) == -1)
		die("kevent timer");
	timer_on = on;
#else
	(void)on;
#endif
}

#ifdef __FreeBSD__
#define FILE_NOTES (NOTE_WRITE | NOTE_EXTEND | NOTE_ATTRIB | NOTE_DELETE | NOTE_RENAME | NOTE_LINK | NOTE_REVOKE)
#define DIR_NOTES (NOTE_WRITE | NOTE_ATTRIB | NOTE_DELETE | NOTE_RENAME | NOTE_REVOKE)
#else
#define FILE_NOTES 0u
#define DIR_NOTES 0u
#endif

/* Open name below the state directory, watch it, read at most MAX_FILE + 1
 * bytes. Regular files only (a FIFO would block), no symlinks. */
static enum fstatus
read_file(const char *name, int slot, char *out, size_t *len)
{
	struct stat sb;
	ssize_t r;
	size_t n = 0;
	int fd = openat(dirfd_, name, O_RDONLY | O_NONBLOCK | O_NOFOLLOW | O_CLOEXEC);

	if (fd == -1) {
		if (errno == ENOENT)
			return F_MISSING;
		/* O_NOFOLLOW on a symlink: ELOOP (POSIX), EMLINK (FreeBSD) */
		return (errno == ELOOP || errno == EMLINK) ? F_INVALID : F_UNREADABLE;
	}
	filefd[slot] = fd;
	watch(fd, FILE_NOTES);
	if (fstat(fd, &sb) == -1 || !S_ISREG(sb.st_mode))
		return F_INVALID;
	while (n < MAX_FILE + 1) {
		r = read(fd, out + n, MAX_FILE + 1 - n);
		if (r == -1) {
			if (errno == EINTR)
				continue;
			return F_UNREADABLE;
		}
		if (r == 0)
			break;
		n += (size_t)r;
	}
	if (n > MAX_FILE)
		return F_INVALID;
	out[n] = '\0';
	*len = n;
	return F_VALID;
}

static void
close_all(void)
{
	int i;
	for (i = 0; i < 2; i++)
		if (filefd[i] != -1) {
			(void)close(filefd[i]);
			filefd[i] = -1;
		}
	if (dirfd_ != -1) {
		(void)close(dirfd_);
		dirfd_ = -1;
	}
}

/* Re-open the directory and the files, re-register watches, re-read. The
 * directory watch is registered before the files are read, so a change made
 * while reading still produces an event. */
static void
rescan(struct state *st)
{
	char data[MAX_FILE + 2];
	size_t len = 0;
	long long cd;

	close_all();
	memset(st, 0, sizeof *st);
	st->level = F_MISSING;
	dirfd_ = openat(parentfd, base_name, O_RDONLY | O_DIRECTORY | O_CLOEXEC);
	if (dirfd_ == -1)
		return;
	st->dir_ok = 1;
	watch(dirfd_, DIR_NOTES);

	if (mode == MODE_BLACKWALL) {
		/* Existence only, content is never read: the directory watch
		 * sees it created and removed, even when it is root-only. */
		struct stat sb;
		if (fstatat(dirfd_, "session", &sb, AT_SYMLINK_NOFOLLOW) == 0 && S_ISREG(sb.st_mode)) {
			st->session = 1;
			st->session_mtime = (long long)sb.st_mtime;
		}
		return;
	}
	st->level = read_file("level", 0, data, &len);
	if (st->level == F_VALID && !parse_level(data, len, st))
		st->level = F_INVALID;
	if (read_file("countdown", 1, data, &len) == F_VALID && parse_countdown(data, len, &cd)) {
		st->armed = 1;
		st->deadline = cd;
	}
}

/* ---- rendering (same output as iced-bar.sh) ----------------------------- */

static void
render(const struct state *st, struct buf *b)
{
	char line[128], when[32];
	const char *cls = "off";
	int i;

	b->n = 0;
	b->s[0] = '\0';
	b->overflow = 0;

	if (mode == MODE_BLACKWALL) {
		if (st->session) {
			iso_utc(st->session_mtime, when, sizeof when);
			puts_raw(b, "{\"text\":\"ZA MUREM\",\"alt\":\"session\",\"tooltip\":\"");
			puts_json(b, "Blackwall: sesja Tails (bhyve, VLAN 40)\nod ");
			puts_json(b, when);
			puts_json(b, "\nPPM: Slide");
			puts_raw(b, "\",\"class\":[\"czarny\"]}\n");
		} else {
			puts_raw(b, "{\"text\":\"BW\",\"alt\":\"off\",\"tooltip\":\"");
			puts_json(b, "Blackwall: brak sesji");
			puts_raw(b, "\",\"class\":[\"off\"]}\n");
		}
		return;
	}

	if (st->level == F_VALID)
		for (i = 0; i < 4; i++)
			if (strcmp(st->level_word, levels[i]) == 0)
				cls = classes[i];

	/* text */
	puts_raw(b, "{\"text\":\"");
	if (st->armed) {
		long long left = st->deadline - now_s();
		if (left < 0)
			left = 0;
		(void)snprintf(line, sizeof line, "%s %llds",
		    st->level == F_VALID ? st->level_word : "ICE", left);
		puts_json(b, line);
	} else
		puts_json(b, st->level == F_VALID ? st->level_word : "off");

	/* alt */
	puts_raw(b, "\",\"alt\":\"");
	puts_raw(b, st->armed ? "armed" : cls);

	/* tooltip */
	puts_raw(b, "\",\"tooltip\":\"");
	puts_json(b, "ICE: ");
	puts_json(b, st->level == F_VALID ? st->level_word : "off");
	for (i = 0; st->level == F_VALID && i < st->nfields; i++) {
		puts_json(b, "\n");
		puts_json(b, st->fields[i]);
	}
	if (!st->dir_ok) {
		puts_json(b, "\nbrak katalogu ");
		puts_json(b, state_dir);
	} else if (st->level == F_MISSING)
		puts_json(b, "\nbrak pliku level");
	else if (st->level == F_INVALID)
		puts_json(b, "\nniepoprawna tre\xc5\x9b\xc4\x87 pliku level");
	else if (st->level == F_UNREADABLE)
		puts_json(b, "\nbrak dost\xc4\x99pu do pliku level");
	if (st->armed) {
		long long left = st->deadline - now_s();
		if (left < 0)
			left = 0;
		iso_utc(st->deadline, when, sizeof when);
		(void)snprintf(line, sizeof line, "\nWy\xc5\x82\xc4\x85" "czenie za %lld s (%s)", left, when);
		puts_json(b, line);
	}

	/* class */
	puts_raw(b, "\",\"class\":[\"");
	puts_raw(b, cls);
	puts_raw(b, st->armed ? "\",\"armed\"]}\n" : "\"]}\n");
}

/* ---- setup -------------------------------------------------------------- */

static void
split_dir(const char *path)
{
	size_t len = strlen(path);
	const char *slash;

	while (len > 1 && path[len - 1] == '/')     /* trailing slashes */
		len--;
	slash = NULL;
	{
		size_t i;
		for (i = 0; i < len; i++)
			if (path[i] == '/')
				slash = path + i;
	}
	if (slash == NULL) {
		copy_path(parent_path, sizeof parent_path, ".", 1);
		copy_path(base_name, sizeof base_name, path, len);
	} else {
		copy_path(base_name, sizeof base_name, slash + 1, len - (size_t)(slash + 1 - path));
		if (slash == path)
			copy_path(parent_path, sizeof parent_path, "/", 1);
		else
			copy_path(parent_path, sizeof parent_path, path, (size_t)(slash - path));
	}
	if (base_name[0] == '\0' || strcmp(base_name, ".") == 0 || strcmp(base_name, "..") == 0) {
		errno = EINVAL;
		die(path);
	}
}

static void
sandbox(void)
{
#ifdef __FreeBSD__
	cap_rights_t r;

	cap_rights_init(&r, CAP_LOOKUP, CAP_READ, CAP_FSTAT, CAP_FSTATAT, CAP_EVENT);
	if (cap_rights_limit(parentfd, &r) == -1 && errno != ENOSYS)
		die("cap_rights_limit");
	cap_rights_init(&r, CAP_WRITE);
	if (cap_rights_limit(STDOUT_FILENO, &r) == -1 && errno != ENOSYS)
		die("cap_rights_limit stdout");
	if (cap_rights_limit(STDERR_FILENO, &r) == -1 && errno != ENOSYS)
		die("cap_rights_limit stderr");
	if (cap_enter() == -1 && errno != ENOSYS)
		die("cap_enter");
#endif
}

int
main(int argc, char **argv)
{
	struct state st;
	struct buf out;
	const char *env;

	if (argc == 2 && strcmp(argv[1], "--blackwall") == 0)
		mode = MODE_BLACKWALL;
	else if (argc != 1) {
		static const char usage[] = "usage: iced-bar [--blackwall]\n";
		say(usage, sizeof usage - 1);
		return 2;
	}
	env = getenv(mode == MODE_ICE ? "ICED_STATE_DIR" : "JACK_STATE_DIR");
	state_dir = (env != NULL && env[0] != '\0') ? env :
	    (mode == MODE_ICE ? "/var/run/iced" : "/var/run/jack");
	split_dir(state_dir);
	(void)signal(SIGPIPE, SIG_IGN);

	parentfd = open(parent_path, O_RDONLY | O_DIRECTORY | O_CLOEXEC);
	if (parentfd == -1)
		die(parent_path);
#ifdef __FreeBSD__
	kq = kqueue();
	if (kq == -1)
		die("kqueue");
	watch(parentfd, DIR_NOTES);
#endif
	sandbox();

	rescan(&st);
	set_timer(mode == MODE_ICE && st.armed);
	render(&st, &out);
	emit(&out);

	for (;;) {
#ifdef __FreeBSD__
		struct kevent ev[16];
		int i, n, again = 0;

		n = kevent(kq, NULL, 0, ev, 16, NULL);
		if (n == -1) {
			if (errno == EINTR)
				continue;
			die("kevent wait");
		}
		for (i = 0; i < n; i++) {
			if (ev[i].filter == EVFILT_TIMER)
				continue;
			if ((int)ev[i].ident == parentfd &&
			    (ev[i].fflags & (NOTE_DELETE | NOTE_RENAME | NOTE_REVOKE)))
				return 1;   /* parent gone; Waybar restarts us */
			again = 1;
		}
		if (again) {
			rescan(&st);
			set_timer(mode == MODE_ICE && st.armed);
		}
#else
		struct timespec ts = { 1, 0 };
		(void)nanosleep(&ts, NULL);
		rescan(&st);
#endif
		render(&st, &out);
		emit(&out);
	}
}
