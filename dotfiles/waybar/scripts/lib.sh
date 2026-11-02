# shellcheck shell=sh
# Projekt Blackwall - helpers for the Waybar module scripts (FreeBSD).
# Sourced, not run. No root, no network, no eval.

export LC_ALL=C
# Base tools live in /sbin and /usr/sbin on FreeBSD (ifconfig, sysctl, zpool);
# appended, so the user's own PATH order still wins.
PATH=$PATH:/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
export PATH

has() { command -v "$1" > /dev/null 2>&1; }

# JSON string body: tabs become spaces, other control characters are
# dropped, quote and backslash escaped, newlines become \n.
json() {
  printf '%s' "$1" | tr '\t' ' ' | tr -d '\000-\010\013-\037\177' |
    sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' |
    awk 'BEGIN { ORS = "" } NR > 1 { print "\\n" } { print }'
}

# emit TEXT CLASS TOOLTIP [PERCENTAGE]
# One Waybar JSON line. CLASS is one of the shared state classes
# (off zielony zolty czerwony czarny armed) and doubles as "alt" for icons.
emit() {
  pct=
  [ -n "${4-}" ] && pct=",\"percentage\":$4"
  printf '{"text":"%s","alt":"%s","tooltip":"%s","class":["%s"]%s}\n' \
    "$(json "$1")" "$2" "$(json "$3")" "$2" "$pct"
}

# notify TITLE MESSAGE: a desktop notification (mako), else a swaynag bar.
notify() {
  if has notify-send; then
    notify-send -a Blackwall -- "$1" "$2"
  elif has swaynag; then
    swaynag -t warning -m "$1: $2" > /dev/null 2>&1 &
  else
    printf '%s: %s\n' "$1" "$2" >&2
  fi
}

# kv_line WORD...: validate $data like the ICE level file: printable ASCII,
# one line, first word one of WORD..., then key=value fields with keys of
# [A-Za-z0-9_.-]. Sets kv_word and kv_fields (newline-separated).
# Returns 1 when invalid.
kv_line() {
  kv_allowed=$*
  kv_word= kv_fields=
  case $data in ''|*'
'*) return 1 ;; esac
  bad=$(( $(printf '%s' "$data" | tr -d '\040-\176' | wc -c) ))
  [ "$bad" -eq 0 ] || return 1
  old_ifs=$IFS; IFS=' '; set -f
  # shellcheck disable=SC2086 # split on spaces on purpose; globbing is off
  set -- $data
  IFS=$old_ifs
  [ $# -ge 1 ] || return 1
  for allowed in $kv_allowed; do
    [ "$1" = "$allowed" ] && kv_word=$1
  done
  [ -n "$kv_word" ] || return 1
  shift
  [ $# -le 32 ] || return 1
  for t; do
    case $t in *=*) ;; *) return 1 ;; esac
    key=${t%%=*}
    case $key in ''|*[!A-Za-z0-9_.-]*) return 1 ;; esac
    kv_fields="$kv_fields
$t"
  done
  return 0
}
