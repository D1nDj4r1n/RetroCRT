#!/bin/sh
# Tests for iced-bar (C) and scripts/iced-bar.sh: one set of expected JSON
# lines for both, so they must print the same format.
#
#   sh test.sh ./iced-bar                  kqueue: a change shows at once
#   sh test.sh ../scripts/iced-bar.sh 7    polls every 5 s: wait up to 7 s
#
# State lives in a scratch directory passed through ICED_STATE_DIR and
# JACK_STATE_DIR; nothing under /var/run is touched.

set -u
export LC_ALL=C
prog=$1
wait_max=${2:-3}
case $prog in /*) ;; *) prog=$(pwd)/$prog ;; esac
T=$(mktemp -d "${TMPDIR:-/tmp}/iced-bar-test.XXXXXX")
pids=
cleanup() {
  for p in $pids; do kill "$p" 2>/dev/null; done
  chmod -R u+rwx "$T" 2>/dev/null
  rm -rf "$T"
}
trap cleanup EXIT INT TERM
pass=0 fail=0
I=$T/iced J=$T/jack
uid=$(id -u)

ok() { pass=$((pass + 1)); printf 'ok   %s\n' "$1"; }
no() { fail=$((fail + 1)); printf 'FAIL %s\n' "$1"; [ -n "${2-}" ] && printf '     %s\n' "$2"; }

start() { # name ice|blackwall
  out=$T/$1.out
  : > "$out"
  if [ "$2" = blackwall ]; then
    JACK_STATE_DIR=$J "$prog" --blackwall > "$out" 2> "$T/$1.err" &
  else
    ICED_STATE_DIR=$I "$prog" > "$out" 2> "$T/$1.err" &
  fi
  pids="$pids $!"
}
last() { tail -n 1 "$out"; }
lines() { wc -l < "$out" | tr -d ' '; }

# expect DESCRIPTION LINE: the newest output line becomes exactly LINE.
expect() {
  i=0
  while [ $i -lt $((wait_max * 10)) ]; do
    [ "$(last)" = "$2" ] && break
    sleep 0.1; i=$((i + 1))
  done
  if [ "$(last)" = "$2" ]; then ok "$1"; else no "$1" "got:  $(last)${NL}     want: $2"; fi
}
# expect_glob DESCRIPTION PATTERN: for lines with a countdown in them.
# In PATTERN, write \[ \] for JSON brackets and \\n for a JSON "\n".
expect_glob() {
  i=0
  while [ $i -lt $((wait_max * 10)) ]; do
    # shellcheck disable=SC2254
    case $(last) in $2) break ;; esac
    sleep 0.1; i=$((i + 1))
  done
  # shellcheck disable=SC2254
  case $(last) in $2) ok "$1" ;; *) no "$1" "got:  $(last)" ;; esac
}
NL='
'
ice() { # text alt tooltip(JSON-escaped) class-list
  printf '{"text":"%s","alt":"%s","tooltip":"%s","class":[%s]}' "$1" "$2" "$3" "$4"
}
OFF_DIR=$(ice off off "ICE: off\\nbrak katalogu $I" '"off"')
OFF_FILE=$(ice off off 'ICE: off\nbrak pliku level' '"off"')
OFF_BAD=$(ice off off 'ICE: off\nniepoprawna treść pliku level' '"off"')
OFF_PERM=$(ice off off 'ICE: off\nbrak dostępu do pliku level' '"off"')
put() { printf '%s\n' "$1" > "$I/level"; }

echo "== ICE: $prog"
start ice ice
expect "no directory: off" "$OFF_DIR"
mkdir "$I"
expect "directory, no level file: off" "$OFF_FILE"
put ZIELONY
expect "ZIELONY" "$(ice ZIELONY zielony 'ICE: ZIELONY' '"zielony"')"
put 'ZOLTY traces=1'
expect "ZOLTY with a field" "$(ice ZOLTY zolty 'ICE: ZOLTY\ntraces=1' '"zolty"')"
put 'CZERWONY traces=2 since=2026-11-02T14:31:00Z'
expect "CZERWONY with fields" "$(ice CZERWONY czerwony 'ICE: CZERWONY\ntraces=2\nsince=2026-11-02T14:31:00Z' '"czerwony"')"
put CZARNY
expect "CZARNY" "$(ice CZARNY czarny 'ICE: CZARNY' '"czarny"')"
put '   ZOLTY    a=1   b=   '
expect "extra spaces collapse, empty value allowed" "$(ice ZOLTY zolty 'ICE: ZOLTY\na=1\nb=' '"zolty"')"
put 'CZERWONY q="x\y"'
expect "quote and backslash are JSON-escaped" "$(ice CZERWONY czerwony 'ICE: CZERWONY\nq=\"x\\y\"' '"czerwony"')"
# Shell syntax in a value stays text: nothing is executed.
printf 'CZERWONY a=$(touch${IFS}%s/pwned) b=`touch${IFS}%s/pwned`\n' "$T" "$T" > "$I/level"
expect "command substitution stays text" "$(ice CZERWONY czerwony "ICE: CZERWONY\\na=\$(touch\${IFS}$T/pwned)\\nb=\`touch\${IFS}$T/pwned\`" '"czerwony"')"
sleep 1
[ ! -e "$T/pwned" ] && ok "nothing was executed" || no "a value was executed"
put 'CZERWONY <b>markup</b>=1'
expect "invalid key (markup) is invalid" "$OFF_BAD"

for bad in 'ROZOWY' 'zielony' 'ZIELONY traces' 'ZIELONY =x' 'ZIELONY ą=1' 'ZIELONY a=ą'; do
  put ZIELONY; expect "reset" "$(ice ZIELONY zielony 'ICE: ZIELONY' '"zielony"')" > /dev/null
  put "$bad"
  expect "invalid: $bad" "$OFF_BAD"
done
printf 'ZIELONY\tx=1\n' > "$I/level"; expect "invalid: tab" "$OFF_BAD"
printf 'ZIELONY\r\n' > "$I/level"; expect "invalid: CRLF" "$OFF_BAD"
printf 'ZIELONY\nZOLTY\n' > "$I/level"; expect "invalid: two lines" "$OFF_BAD"
: > "$I/level"; expect "invalid: empty file" "$OFF_BAD"
printf '   \n' > "$I/level"; expect "invalid: only spaces" "$OFF_BAD"
printf 'ZIELONY\n\n\n' > "$I/level"
expect "trailing newlines are fine" "$(ice ZIELONY zielony 'ICE: ZIELONY' '"zielony"')"
long=$(awk 'BEGIN { s = "ZIELONY"; while (length(s) < 1100) s = s " k=v"; print s }')
put "$long"; expect "invalid: longer than 1024 bytes" "$OFF_BAD"
f33=$(awk 'BEGIN { s = "ZIELONY"; for (i = 0; i < 33; i++) s = s " k=v"; print s }')
put "$f33"; expect "invalid: 33 fields" "$OFF_BAD"
f32=$(awk 'BEGIN { s = "ZIELONY"; for (i = 0; i < 32; i++) s = s " k=v"; print s }')
put "$f32"; expect_glob "32 fields are fine" '{"text":"ZIELONY","alt":"zielony",*"class":\["zielony"\]}'
rm "$I/level"; ln -s /etc/passwd "$I/level"; expect "invalid: symlink" "$OFF_BAD"
rm "$I/level"; mkfifo "$I/level"; expect "invalid: FIFO (and no hang)" "$OFF_BAD"
rm "$I/level"; put CZARNY
expect "still running after the FIFO" "$(ice CZARNY czarny 'ICE: CZARNY' '"czarny"')"
if [ "$uid" -ne 0 ]; then
  chmod 000 "$I/level"; expect "unreadable level file" "$OFF_PERM"; chmod 644 "$I/level"
else
  echo "skip unreadable level file (running as root)"
fi
printf 'ZOLTY src=mv\n' > "$I/level.tmp"; mv "$I/level.tmp" "$I/level"
expect "atomic replace (rename)" "$(ice ZOLTY zolty 'ICE: ZOLTY\nsrc=mv' '"zolty"')"
put ZIELONY; put ZOLTY; put CZERWONY
expect "fast successive writes: last one wins" "$(ice CZERWONY czerwony 'ICE: CZERWONY' '"czerwony"')"

echo "== countdown"
put CZARNY
now=$(date +%s)
echo $((now + 120)) > "$I/countdown"
expect_glob "countdown: seconds, armed, CZARNY" '{"text":"CZARNY 1[01][0-9]s","alt":"armed","tooltip":"ICE: CZARNY\\nWyłączenie za 1[01][0-9] s (*Z)","class":\["czarny","armed"\]}'
n1=$(lines); sleep 2.5; n2=$(lines)
[ "$n2" -ge $((n1 + 2)) ] && ok "ticks once a second while armed ($n1 -> $n2 lines)" || no "no ticks while armed ($n1 -> $n2 lines)"
rm "$I/countdown"
expect "countdown removed: not armed" "$(ice CZARNY czarny 'ICE: CZARNY' '"czarny"')"
n1=$(lines); sleep 3; n2=$(lines)
[ "$n2" -eq "$n1" ] && ok "no ticks without countdown" || no "output while idle ($n1 -> $n2 lines)"
echo 0000000005 > "$I/countdown"
expect_glob "deadline in the past: 0s (leading zeros fine)" '{"text":"CZARNY 0s","alt":"armed","tooltip":"ICE: CZARNY\\nWyłączenie za 0 s (1970-01-01T00:00:05Z)","class":\["czarny","armed"\]}'
echo -5 > "$I/countdown"
expect "invalid countdown is ignored" "$(ice CZARNY czarny 'ICE: CZARNY' '"czarny"')"
rm "$I/level"; echo $(($(date +%s) + 60)) > "$I/countdown"
expect_glob "countdown without level: ICE Ns, off+armed" '{"text":"ICE [0-9]*s","alt":"armed","tooltip":"ICE: off\\nbrak pliku level\\nWyłączenie za *","class":\["off","armed"\]}'
rm "$I/countdown"

echo "== directory removed and created again"
rm -rf "$I"
expect "directory removed: off" "$OFF_DIR"
mkdir "$I"; put ZIELONY
expect "directory created again" "$(ice ZIELONY zielony 'ICE: ZIELONY' '"zielony"')"

echo "== Blackwall: $prog --blackwall"
start bw blackwall
BW_OFF='{"text":"BW","alt":"off","tooltip":"Blackwall: brak sesji","class":["off"]}'
expect "no directory: discreet" "$BW_OFF"
mkdir "$J"
expect "directory, no session: discreet" "$BW_OFF"
TZ=UTC touch -t 202611021431.00 "$J/session"
expect "session: ZA MUREM" '{"text":"ZA MUREM","alt":"session","tooltip":"Blackwall: sesja Tails (bhyve, VLAN 40)\nod 2026-11-02T14:31:00Z\nPPM: Slide","class":["czarny"]}'
chmod 000 "$J/session"
sleep 1
case $(last) in *'"ZA MUREM"'*) ok "root-only session file still counts" ;; *) no "root-only session file lost" "$(last)" ;; esac
chmod 644 "$J/session"
rm "$J/session"
expect "session over: discreet" "$BW_OFF"
ln -s /etc/passwd "$J/session"
expect "symlink is not a session" "$BW_OFF"
rm "$J/session"; rm -rf "$J"; mkdir "$J"; TZ=UTC touch -t 202611021431.00 "$J/session"
expect_glob "directory created again with a session" '*"ZA MUREM"*'

echo "== output"
if command -v jq > /dev/null 2>&1; then
  bad=0
  for f in "$T"/*.out; do jq -e . "$f" > /dev/null 2>&1 || bad=1; done
  [ "$bad" -eq 0 ] && ok "every line is valid JSON (jq)" || no "invalid JSON line"
else
  echo "skip JSON check (no jq)"
fi
if [ -s "$T/ice.err" ] || [ -s "$T/bw.err" ]; then no "stderr not empty" "$(cat "$T/ice.err" "$T/bw.err")"; else ok "stderr empty"; fi

echo
echo "passed: $pass  failed: $fail"
[ "$fail" -eq 0 ]
