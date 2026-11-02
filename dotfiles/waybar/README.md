# Waybar — Projekt Blackwall (FreeBSD)

The everyday sway bar on Forteca, and the status display of Projekt Blackwall. FreeBSD only; Arch keeps swaybar. Everything is in English except the data contract with iced: the level words `ZIELONY`, `ZOLTY`, `CZERWONY`, `CZARNY` and the state classes `off zielony zolty czerwony czarny armed` stay as specified, because iced and the style sheet share them.

## Assumptions

From the questions: OSS sound (`mixer`), one monitor, vpnmgr has no status command, the Blackwall palette from the brief. The rest was assumed:

| Assumption | Effect |
| --- | --- |
| Terminal: Kitty (on every device), foot as fallback | ICE left click: `kitty --class iced-tui iced-tui` |
| Nerd Font: JetBrainsMono from `pkg` | `icons.jsonc` is installed only when `fc-list` finds a Nerd Font; without it the bar shows text labels |
| Waybar 0.15.0 from ports (`x11/waybar`) | `include` since 0.9.8, `menu` since 0.10.4 (checked in the Waybar git history) |
| Ethernet card detected automatically | the first physical one from `ifconfig -l ether`; put its name in `modules/net.jsonc` once known |
| iced writes its files atomically (temporary file + `mv`) | an in-place write can show `off` for a moment |
| The content of `session` is ignored | only the file's existence counts; the tooltip shows its mtime (UTC) |
| The sudoers rule for `jack slide` is NOPASSWD | `sudo -n`: no password prompt in the background, so nothing hangs |
| Messages: `notify-send` (libnotify) to mako, else `swaynag` | "iced-tui is not installed yet" instead of an error |
| The sh stand-in polls every 5 s, **every 1 s during the countdown** | the seconds to shutdown are right even before `iced-bar` |
| Temperature is `custom` (sysctl), not the built-in module | on FreeBSD the built-in `temperature` throws when no sensor exists, which stops the bar |
| No tray | it was not on the list; add `"tray"` to `config.jsonc` if needed |
| Blackwall in a session has class `czarny` | "BEYOND THE WALL" in CZARNY (#bb7be0) with an ICE accent line |

## File tree

```text
dotfiles/waybar/                 → ~/.config/waybar/ (./install.sh --dotfiles on FreeBSD)
├── config.jsonc                 base: bar, module order, include
├── icons.jsonc                  Nerd Font formats (only with a Nerd Font)
├── modules/
│   ├── ice.jsonc                custom/ice, custom/blackwall (+ menus)
│   ├── sway.jsonc               workspaces, mode, keyboard layout, idle inhibitor
│   ├── net.jsonc                custom/link, custom/vpn
│   └── system.jsonc             clock, cpu, memory, temperature, sound, ZFS
├── menus/
│   ├── ice.xml                  "Raise level", "Snapshot now"
│   └── blackwall.xml            "Slide"
├── style.css                    Blackwall palette, state classes
├── scripts/
│   ├── lib.sh                   shared: JSON, notify, key=value validation
│   ├── ice-exec                 starts iced-bar, or iced-bar.sh
│   ├── iced-bar.sh              POSIX sh stand-in for iced-bar (same format)
│   ├── ice-action               ICE click and menu
│   ├── blackwall-slide          Blackwall menu: jack slide + swaylock
│   ├── link                     Ethernet + wgmgmt
│   ├── vpn                      ready for vpnmgr-bar
│   ├── zfs                      zpool status -x
│   ├── audio                    mixer(8)
│   └── temp                     sysctl temperature
└── iced-bar/
    ├── iced-bar.c               C11, kqueue, Capsicum
    ├── Makefile                 make, make test, make install
    └── test.sh                  tests (ICED_STATE_DIR, JACK_STATE_DIR)
```

## What the bar shows

```text
[ICE ZIELONY][BW][1 2 3][resize]        12:05        [em0 · wg][VPN --][ZFS][CPU 4%][MEM 31%][TMP 45°C][VOL 75%][pl][idle]
```

| Module | States (class) | Clicks |
| --- | --- | --- |
| ICE | `off`, `zielony`, `zolty`, `czerwony`, `czarny`; countdown: `armed` (blinks, seconds in the text) | left: iced-tui; right: menu with actions that only raise protection |
| Blackwall | `off` (a discreet "BW"), `czarny` ("BEYOND THE WALL") | right: "Slide" menu |
| Connectivity | `zielony`; `zolty` (wgmgmt missing or down, no IPv4); `czerwony` (no card, down, no carrier) | — |
| VPN | `off` (no vpnmgr-bar, or DOWN), `zielony` UP, `zolty` CONNECTING, `czerwony` ERROR | — |
| ZFS | `zielony` healthy, `czerwony` anything else, `off` no zpool | — |
| Temperature | `zielony` < 70 °C, `zolty` < 85 °C, `czerwony`, `off` without a sensor | — |
| Sound | `zielony`, `off` (muted, no mixer) | click: mute; scroll: ±5% |
| Clock | local time; tooltip: local time with ISO date, and UTC | scroll: switches the bar to UTC |
| Idle inhibitor | `activated` in yellow (the screen will not lock) | click: toggle |

Colour carries meaning: ICE and Blackwall are filled with their state colour; the rest uses the text colour and only turns yellow or red on a fault.

## The data contract in practice

- `/var/run/iced/level`: one ASCII line (0x20–0x7E), at most 1024 bytes, first word `ZIELONY|ZOLTY|CZERWONY|CZARNY`, then up to 32 `key=value` fields (key `[A-Za-z0-9_.-]+`). Trailing newlines are ignored. Anything else (tab, CR, UTF-8, a second line, a symlink, a FIFO) shows `off` with the reason in the tooltip.
- `/var/run/iced/countdown`: digits only (up to 18), the Unix time of the shutdown. A time in the past shows `0s`.
- `/var/run/jack/session`: a regular file (not a symlink) that exists, even `0600 root`.
- File contents never reach a shell or a click command; they are JSON-escaped, and Waybar (`"escape": true`) also escapes Pango markup.
- Permissions the bar needs: directories `0755`, `level` and `countdown` `0644` (readable by a normal user).

## Installation, command by command

As root:

```sh
pkg install waybar libnotify swaylock nerd-fonts-jetbrainsmono jq
```
Installs Waybar 0.15 from ports, `notify-send` (messages through mako), swaylock (the lock after Slide), the JetBrains Mono Nerd Font (font and icons), and `jq` (only for the tests in `verify.sh`).

```sh
sysrc kld_list+=coretemp      # Intel; on AMD: sysrc kld_list+=amdtemp
```
Adds the temperature sensor module to the modules loaded at boot. Once `kern.securelevel` is 1, `kldload` no longer works, so the module has to be in `kld_list`.

```sh
kldload coretemp              # or amdtemp; only now, before securelevel goes up
```
Loads the module right away, without a reboot.

```sh
sysctl dev.cpu.0.temperature
```
Checks that the sensor works (e.g. `45.0C`). If not, the module tries `hw.acpi.thermal.tz0.temperature`, and shows `--` without either.

As your normal user, in the RetroCRT repository:

```sh
fc-list : family | grep -i 'nerd font'
```
Checks that fontconfig sees a Nerd Font; `install.sh` adds `icons.jsonc` only then.

```sh
./install.sh --dotfiles
```
Links `~/.config/retrocrt` to the repository and, on FreeBSD, creates links in `~/.config/waybar`: `config.jsonc`, `style.css`, `modules/`, `menus/`, `scripts/` (+ `icons.jsonc` with a Nerd Font). Existing files are moved to `*.bak.<date>`.

```sh
make -C ~/.config/retrocrt/dotfiles/waybar/iced-bar
```
Builds `iced-bar` (C11, `-Wall -Wextra -Wpedantic -Werror`). Until then the ICE modules run on `scripts/iced-bar.sh`.

```sh
make -C ~/.config/retrocrt/dotfiles/waybar/iced-bar test
```
Runs the tests on real kqueue (a temporary directory, nothing under `/var/run`): levels, invalid content, countdown, the directory removed and created again, the Tails session. It should end with `passed: 56  failed: 0` (as root `passed: 55`, because the permission test is skipped then).

```sh
make -C ~/.config/retrocrt/dotfiles/waybar/iced-bar install
```
Installs to `~/.local/bin/iced-bar`; `scripts/ice-exec` picks it over the sh script by itself.

In `~/.config/sway/config`, replace the whole `bar { … }` block with:

```text
bar {
    swaybar_command waybar
}
```
sway starts and stops Waybar with the session. Keep one `bar` block and no `exec waybar` anywhere else, or there will be two bars.

Optionally, to open iced-tui as a floating window:

```text
for_window [app_id="iced-tui"] floating enable
```

```sh
swaymsg reload
```
Reloads the sway configuration; the changed `bar` block starts Waybar.

```sh
pkill -USR2 -x waybar
```
Reloads Waybar's configuration and style without logging out (SIGUSR2 means `reload` by default). Waybar picks up changes to `style.css` by itself (`reload_style_on_change`).

## vpnmgr: the format to hook up

vpnmgr has no status command, so the module waits for a small program `vpnmgr-bar` in `PATH` (no root) that asks the daemon over its unix socket and prints **one** line:

```text
STATE [key=value ...]
STATE: UP | CONNECTING | DOWN | ERROR
e.g.:  UP name=pl-waw if=wg1 since=2026-11-02T14:31:00Z
```

The same rules as the `level` file: ASCII, up to 1024 bytes, up to 32 fields, exit status 0. The module gives it 3 s (`timeout`). The bar never calls `vpnmgr` itself: an unknown subcommand could start its TUI or the daemon.

## Test plan

State changes as root; watch the bar. Write the files atomically, as iced will:

```sh
install -d -m 0755 /var/run/iced /var/run/jack
lvl() { printf '%s\n' "$1" > /var/run/iced/level.tmp && mv /var/run/iced/level.tmp /var/run/iced/level; }
```
Creates the state directories and a function that replaces `level` atomically.

| Test | Command (root) | Expected |
| --- | --- | --- |
| no files | `rm -rf /var/run/iced` | ICE `off`, tooltip "no directory" |
| ZIELONY | `install -d -m 0755 /var/run/iced; lvl ZIELONY` | green fill |
| ZOLTY with fields | `lvl 'ZOLTY traces=1'` | yellow fill, `traces=1` in the tooltip |
| CZERWONY | `lvl 'CZERWONY traces=2 since=2026-11-02T14:31:00Z'` | red fill, both fields in the tooltip |
| CZARNY | `lvl CZARNY` | purple fill |
| invalid content | `lvl 'ROZOWY'`; `printf 'ZIELONY\tx=1\n' > /var/run/iced/level` | `off`, "invalid level file" |
| injection attempt | `lvl 'CZERWONY x=$(touch${IFS}/tmp/pwned) y=<b>z</b>'` | the text appears literally in the tooltip; `/tmp/pwned` is not created |
| countdown | `echo $(( $(date +%s) + 60 )) > /var/run/iced/countdown` | blinks, `CZARNY 59s`, one second less each second |
| countdown over | `rm /var/run/iced/countdown` | the blinking stops, so does the tick |
| directory removed | `rm -rf /var/run/iced` | `off`; after `install -d …; lvl ZIELONY` it comes back |
| Tails session | `touch /var/run/jack/session` | "BEYOND THE WALL", purple |
| session over | `rm /var/run/jack/session` | a discreet "BW" |
| Slide without a session | right click → Slide (no session file) | a message, no sudo |

As your normal user:

| Test | Command | Expected |
| --- | --- | --- |
| connectivity | `~/.config/waybar/scripts/link` | `em0 · wg`, class `zielony` |
| no wgmgmt | `~/.config/waybar/scripts/link '' nosuchif` | `wg --`, `zolty` (the real tunnel is left alone) |
| wgmgmt present | `ifconfig wgmgmt` | flags include `UP` |
| ZFS | `~/.config/waybar/scripts/zfs` | `ZFS`, `zielony` |
| VPN | `~/.config/waybar/scripts/vpn` | `VPN --`, `off` (until vpnmgr-bar exists) |
| no iced-tui | left click on ICE | the message "iced-tui is not installed yet" |
| C tests | `make -C …/iced-bar test` | `failed: 0` |
| sh tests | `make -C …/iced-bar test-sh` | `failed: 0` (slower, polls every 5 s) |
| whole repository | `VERIFY_SLOW=1 ./verify.sh` | `verify: PASSED` |

A degraded pool with no risk to your data (root, a pool on files):

```sh
truncate -s 128m /tmp/z1 /tmp/z2
zpool create bwtest mirror /tmp/z1 /tmp/z2
zpool offline bwtest /tmp/z2
```
Creates a test mirror on two files and takes one of them offline: within a minute ZFS on the bar turns to `ZFS !` (red), and the tooltip shows `DEGRADED`. Clean up: `zpool destroy bwtest; rm /tmp/z1 /tmp/z2`.

CPU use (as your user; `see_other_uids=0` does not matter, these are your processes):

```sh
ps -U "$USER" -o pid,%cpu,time,command | grep -E 'iced-bar|waybar'
```
Shows CPU time; `TIME` of `iced-bar` should not grow while the state does not change.

```sh
procstat -r "$(pgrep -U "$USER" -x iced-bar | head -n 1)" | grep 'context switches'
```
Context switch counters: read now and after a minute. With no state change and no countdown the count barely moves (kqueue sleeps); during a countdown it grows by about 60 a minute.

Looks:

```sh
GTK_DEBUG=interactive waybar
```
Starts a second Waybar with the GTK inspector: it shows the classes (`zielony`, `armed`) and the CSS rules of each module. Close it after looking, so there are not two bars.

## To check on your version

| What | How | Why |
| --- | --- | --- |
| Waybar version | `waybar --version`, `pkg info waybar` | `menu` needs ≥ 0.10.4, `include` ≥ 0.9.8 |
| modules built | `ls /usr/local/share/man/man5/ \| grep waybar` | no `waybar-network.5` confirms there is no `network` module (port without libnl) |
| card name | `ifconfig -l ether` | put it in `modules/net.jsonc` (`… /link em0 wgmgmt`) |
| tunnel | `ifconfig wgmgmt` as your user | the module reads only flags and address |
| temperature sensor | `sysctl dev.cpu.0.temperature`, `kldstat \| grep -E 'coretemp\|amdtemp'`, `sysrc kld_list` | sensor path and number (`temp 0 70 85`) |
| mixer | `mixer vol.volume`, `cat /dev/sndstat` | the default OSS unit |
| ZFS without root | `zpool status -x`, `ls -l /dev/zfs` | the module works without sudo |
| Nerd Font | `fc-list : family \| grep -i nerd` | whether `icons.jsonc` is installed |
| signals | only `SIGUSR2` (reload); no `SIGRTMIN+N` | nothing to number |
| sudo without a password | `sudo -n -l /usr/local/bin/jack slide` | Slide does not hang on a password |
| messages | `notify-send test test` | whether mako is running |
| `/var/run` after a reboot | rc clears `/var/run`; iced creates its directories itself | until then the modules show `off` |
