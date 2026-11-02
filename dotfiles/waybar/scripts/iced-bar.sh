#!/bin/sh
# iced-bar.sh - stand-in for iced-bar (C) until it is built and installed.
# Same JSON, same validation rules; polls every 5 s (every 1 s while the
# countdown file exists, so the seconds are right).
#
#   iced-bar.sh               ICE: $ICED_STATE_DIR (/var/run/iced) level, countdown
#   iced-bar.sh --blackwall   Blackwall: $JACK_STATE_DIR (/var/run/jack) session
#
# File contents are untrusted: size-checked, validated, never executed, never
# glob-expanded (set -f), never passed to a command line, JSON-escaped.

export LC_ALL=C
set -f

mode=ice
case ${1-} in
  --blackwall) mode=blackwall ;;
  '') ;;
  *) echo 'usage: iced-bar.sh [--blackwall]' >&2; exit 2 ;;
esac

ice_dir=${ICED_STATE_DIR:-/var/run/iced}
jack_dir=${JACK_STATE_DIR:-/var/run/jack}
nl='
'

case $(uname -s) in
  FreeBSD)
    mtime() { stat -f %m "$1" 2>/dev/null; }
    utc() { date -u -r "$1" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo '?'; }
    ;;
  *)
    mtime() { stat -c %Y "$1" 2>/dev/null; }
    utc() { date -u -d "@$1" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo '?'; }
    ;;
esac

# JSON string body. Newlines become \n; contents are printable ASCII by now,
# so quote and backslash are the only other characters to escape.
json() {
  printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' |
    awk 'BEGIN { ORS = "" } NR > 1 { print "\\n" } { print }'
}

# read_small FILE: sets st (missing|valid|invalid|unreadable) and data.
# Same rules as iced-bar.c: regular file, no symlink, at most 1024 bytes,
# printable ASCII plus newlines; trailing newlines dropped.
read_small() {
  data=
  if [ ! -e "$1" ] && [ ! -L "$1" ]; then st=missing; return; fi
  if [ -L "$1" ] || [ ! -f "$1" ]; then st=invalid; return; fi
  if [ ! -r "$1" ]; then st=unreadable; return; fi
  size=$(( $(head -c 1025 "$1" 2>/dev/null | wc -c) ))
  if [ "$size" -gt 1024 ]; then st=invalid; return; fi
  bad=$(( $(head -c 1025 "$1" 2>/dev/null | tr -d '\040-\176\n' | wc -c) ))
  if [ "$bad" -ne 0 ]; then st=invalid; return; fi
  data=$(head -c 1025 "$1" 2>/dev/null)
  st=valid
}

# parse_level: data -> word, fields (newline-separated); st=invalid on error.
parse_level() {
  word= fields=
  case $data in ''|*"$nl"*) st=invalid; return ;; esac
  old_ifs=$IFS
  IFS=' '
  # shellcheck disable=SC2086 # split on spaces on purpose; globbing is off
  set -- $data
  IFS=$old_ifs
  case ${1-} in
    ZIELONY|ZOLTY|CZERWONY|CZARNY) word=$1 ;;
    *) st=invalid; return ;;
  esac
  shift
  if [ $# -gt 32 ]; then st=invalid; return; fi
  for t; do
    case $t in *=*) ;; *) st=invalid; return ;; esac
    key=${t%%=*}
    case $key in ''|*[!A-Za-z0-9_.-]*) st=invalid; return ;; esac
    fields=$fields$nl$t
  done
}

# parse_countdown: data -> deadline; returns 1 when invalid.
parse_countdown() {
  case $data in ''|*[!0-9]*) return 1 ;; esac
  while :; do
    case $data in 0?*) data=${data#0} ;; *) break ;; esac
  done
  [ ${#data} -le 18 ] || return 1
  deadline=$data
}

render_blackwall() {
  f=$jack_dir/session
  if [ -f "$f" ] && [ ! -L "$f" ]; then
    m=$(mtime "$f")
    printf '{"text":"ZA MUREM","alt":"session","tooltip":"%s","class":["czarny"]}' \
      "$(json "Blackwall: sesja Tails (bhyve, VLAN 40)${nl}od $(utc "${m:-0}")${nl}PPM: Slide")"
  else
    printf '{"text":"BW","alt":"off","tooltip":"%s","class":["off"]}' \
      "$(json 'Blackwall: brak sesji')"
  fi
}

render_ice() {
  armed=0 word= fields= reason=
  # As iced-bar.c: the directory must be openable (read and search).
  if [ ! -d "$ice_dir" ] || [ ! -r "$ice_dir" ] || [ ! -x "$ice_dir" ]; then
    reason="brak katalogu $ice_dir"
  else
    read_small "$ice_dir/level"
    [ "$st" = valid ] && parse_level
    case $st in
      missing) reason='brak pliku level' ;;
      invalid) reason='niepoprawna treść pliku level'; word= fields= ;;
      unreadable) reason='brak dostępu do pliku level' ;;
    esac
    read_small "$ice_dir/countdown"
    if [ "$st" = valid ] && parse_countdown; then armed=1; fi
  fi

  case $word in
    ZIELONY) cls=zielony ;; ZOLTY) cls=zolty ;;
    CZERWONY) cls=czerwony ;; CZARNY) cls=czarny ;;
    *) cls=off ;;
  esac
  shown=${word:-off}
  tip="ICE: $shown$fields"
  [ -n "$reason" ] && tip=$tip$nl$reason

  if [ "$armed" = 1 ]; then
    left=$((deadline - $(date +%s)))
    [ "$left" -lt 0 ] && left=0
    text="${word:-ICE} ${left}s"
    alt=armed
    tip="${tip}${nl}Wyłączenie za $left s ($(utc "$deadline"))"
    class="\"$cls\",\"armed\""
  else
    text=$shown
    alt=$cls
    class="\"$cls\""
  fi
  printf '{"text":"%s","alt":"%s","tooltip":"%s","class":[%s]}' \
    "$(json "$text")" "$alt" "$(json "$tip")" "$class"
}

last=
while :; do
  if [ "$mode" = blackwall ]; then out=$(render_blackwall); else out=$(render_ice); fi
  if [ "$out" != "$last" ]; then
    printf '%s\n' "$out" || exit 0
    last=$out
  fi
  # render_* runs in a subshell, so read "armed" back from the output.
  case $out in
    *'"armed"]}') sleep 1 ;;
    *) sleep 5 ;;
  esac
done
