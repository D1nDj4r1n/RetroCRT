# Waybar — Projekt Blackwall (FreeBSD)

Codzienny pasek sway na Fortecy i jednocześnie wskaźnik stanu Blackwall. Tylko FreeBSD (na Arch zostaje swaybar). Komentarze w plikach są po angielsku, jak w reszcie repo; teksty na pasku i w tooltipach po polsku.

## Założenia

Odpowiedzi z pytań: dźwięk OSS (`mixer`), jeden monitor, vpnmgr bez polecenia statusu, kolory Blackwall z briefu. Pozostałe przyjęte wprost:

| Założenie | Skutek |
| --- | --- |
| Terminal: Kitty (na każdym urządzeniu), zapasowo foot | lewy klik ICE: `kitty --class iced-tui iced-tui` |
| Nerd Font: JetBrainsMono z `pkg` | `icons.jsonc` instaluje się tylko, gdy `fc-list` widzi Nerd Font; bez niego pasek ma etykiety tekstowe |
| Waybar 0.15.0 z portów (`x11/waybar`) | `include` od 0.9.8, `menu` od 0.10.4 (sprawdzone w historii repo Waybara) |
| Karta Ethernet wykrywana automatycznie | pierwsza fizyczna z `ifconfig -l ether`; wpisz nazwę w `modules/net.jsonc`, gdy ją znasz |
| iced zapisuje pliki atomowo (plik tymczasowy + `mv`) | zapis „w miejscu” może na ułamek sekundy pokazać `off` |
| Treść `session` jest ignorowana | liczy się tylko istnienie pliku; w tooltipie czas jego utworzenia (mtime, UTC) |
| Reguła sudoers dla `jack slide` jest NOPASSWD | `sudo -n`: brak hasła w tle zamiast zawieszenia |
| Komunikaty: `notify-send` (libnotify) → mako, inaczej `swaynag` | „iced-tui nie jest zainstalowany” zamiast błędu |
| Skrypt zastępczy odpytuje co 5 s, ale **co 1 s podczas odliczania** | sekundy do wyłączenia są dokładne także przed `iced-bar` |
| Temperatura jako `custom` (sysctl), nie wbudowany moduł | wbudowany `temperature` na FreeBSD rzuca wyjątek, gdy brak czujnika, i zatrzymuje pasek |
| Bez zasobnika (tray) | nie był na liście; dopisz `"tray"` w `config.jsonc`, jeśli potrzebny |
| Blackwall w sesji ma klasę `czarny` | „ZA MUREM” w kolorze CZARNY (#bb7be0) z linią akcentu ICE |

## Drzewo plików

```text
dotfiles/waybar/                 → ~/.config/waybar/ (./install.sh --dotfiles na FreeBSD)
├── config.jsonc                 baza: pasek, kolejność modułów, include
├── icons.jsonc                  formaty z ikonami Nerd Font (tylko z Nerd Fontem)
├── modules/
│   ├── ice.jsonc                custom/ice, custom/blackwall (+ menu)
│   ├── sway.jsonc               obszary robocze, tryb, układ klawiatury, inhibitor
│   ├── net.jsonc                custom/link, custom/vpn
│   └── system.jsonc             zegar, cpu, pamięć, temperatura, dźwięk, ZFS
├── menus/
│   ├── ice.xml                  „Podnieś poziom”, „Snapshot teraz”
│   └── blackwall.xml            „Slide”
├── style.css                    paleta Blackwall, klasy stanów
├── scripts/
│   ├── lib.sh                   wspólne: JSON, notify, walidacja klucz=wartość
│   ├── ice-exec                 uruchamia iced-bar albo iced-bar.sh
│   ├── iced-bar.sh              zastępca iced-bar w POSIX sh (ten sam format)
│   ├── ice-action               klik i menu ICE
│   ├── blackwall-slide          menu Blackwall: jack slide + swaylock
│   ├── link                     Ethernet + wgmgmt
│   ├── vpn                      gotowy na vpnmgr-bar
│   ├── zfs                      zpool status -x
│   ├── audio                    mixer(8)
│   └── temp                     sysctl temperatury
└── iced-bar/
    ├── iced-bar.c               C11, kqueue, Capsicum
    ├── Makefile                 make, make test, make install
    └── test.sh                  testy (ICED_STATE_DIR, JACK_STATE_DIR)
```

## Co jest na pasku

```text
[ICE ZIELONY][BW][1 2 3][resize]        12:05        [em0 · wg][VPN --][ZFS][CPU 4%][MEM 31%][TMP 45°C][VOL 75%][pl][idle]
```

| Moduł | Stany (klasa) | Kliknięcia |
| --- | --- | --- |
| ICE | `off`, `zielony`, `zolty`, `czerwony`, `czarny`; odliczanie: `armed` (miga, sekundy w tekście) | lewy: iced-tui; prawy: menu tylko z akcjami zaostrzającymi |
| Blackwall | `off` (dyskretne „BW”), `czarny` („ZA MUREM”) | prawy: menu „Slide” |
| Łączność | `zielony`; `zolty` (brak/down wgmgmt, brak IPv4); `czerwony` (brak karty, down, brak linku) | — |
| VPN | `off` (brak vpnmgr-bar / DOWN), `zielony` UP, `zolty` CONNECTING, `czerwony` ERROR | — |
| ZFS | `zielony` zdrowe, `czerwony` cokolwiek innego, `off` brak zpool | — |
| Temperatura | `zielony` < 70 °C, `zolty` < 85 °C, `czerwony`, `off` bez czujnika | — |
| Dźwięk | `zielony`, `off` (wyciszony, brak miksera) | klik: wycisz; scroll: ±5% |
| Zegar | czas lokalny; tooltip: lokalnie z datą ISO i UTC | scroll: przełącza pasek na UTC |
| Inhibitor | `activated` na żółto (ekran się nie zablokuje) | klik: przełącz |

Kolor niesie znaczenie: ICE i Blackwall są wypełnione kolorem stanu, reszta ma kolor tekstu i barwi się tylko przy usterce.

## Kontrakt danych w praktyce

- `/var/run/iced/level`: jedna linia ASCII (0x20–0x7E), najwyżej 1024 bajty, pierwszy wyraz `ZIELONY|ZOLTY|CZERWONY|CZARNY`, dalej do 32 pól `klucz=wartość` (klucz `[A-Za-z0-9_.-]+`). Końcowe znaki nowej linii są pomijane. Cokolwiek innego (tabulator, CR, UTF-8, druga linia, dowiązanie, FIFO) daje `off` z powodem w tooltipie.
- `/var/run/iced/countdown`: same cyfry (do 18), czas uniksowy wyłączenia. Wartość w przeszłości pokazuje `0s`.
- `/var/run/jack/session`: liczy się istnienie zwykłego pliku (nie dowiązania), także `0600 root`.
- Treść nigdy nie trafia do powłoki ani do poleceń kliknięć; jest escapowana w JSON-ie, a Waybar (`"escape": true`) escapuje jeszcze markup Pango.
- Uprawnienia, których potrzebuje pasek: katalogi `0755`, pliki `level` i `countdown` `0644` (czytelne dla zwykłego użytkownika).

## Instalacja (komenda po komendzie)

Jako root:

```sh
pkg install waybar libnotify swaylock nerd-fonts-jetbrainsmono jq
```
Instaluje Waybar 0.15 z portów, `notify-send` (komunikaty przez mako), swaylock (blokada po Slide), JetBrains Mono Nerd Font (font i ikony) oraz `jq` (tylko do testów w `verify.sh`).

```sh
sysrc kld_list+=coretemp      # Intel; na AMD: sysrc kld_list+=amdtemp
```
Dopisuje moduł czujnika temperatury do ładowanych przy starcie. Po podniesieniu `kern.securelevel` do 1 `kldload` nie zadziała, więc moduł musi być w `kld_list`.

```sh
kldload coretemp              # albo amdtemp; tylko teraz, przed podniesieniem securelevel
```
Ładuje moduł od razu, bez restartu.

```sh
sysctl dev.cpu.0.temperature
```
Sprawdza, czy czujnik działa (np. `45.0C`). Jeśli nie, moduł spróbuje `hw.acpi.thermal.tz0.temperature`, a bez obu pokaże `--`.

Jako zwykły użytkownik, w katalogu repo RetroCRT:

```sh
fc-list : family | grep -i 'nerd font'
```
Sprawdza, czy Nerd Font jest widoczny dla fontconfig; od tego zależy, czy `install.sh` dołoży `icons.jsonc`.

```sh
./install.sh --dotfiles
```
Linkuje `~/.config/retrocrt` do repo i na FreeBSD tworzy w `~/.config/waybar` dowiązania: `config.jsonc`, `style.css`, `modules/`, `menus/`, `scripts/` (+ `icons.jsonc` z Nerd Fontem). Istniejące pliki przenosi do `*.bak.<data>`.

```sh
make -C ~/.config/retrocrt/dotfiles/waybar/iced-bar
```
Buduje `iced-bar` (C11, `-Wall -Wextra -Wpedantic -Werror`). Do tego czasu moduły ICE działają na `scripts/iced-bar.sh`.

```sh
make -C ~/.config/retrocrt/dotfiles/waybar/iced-bar test
```
Uruchamia testy na prawdziwym kqueue (katalog tymczasowy, nic w `/var/run`): poziomy, niepoprawne treści, odliczanie, usunięcie i odtworzenie katalogu, sesja Tails. Powinno skończyć się `passed: 56  failed: 0` (jako root `passed: 55`, bo test braku uprawnień jest wtedy pomijany).

```sh
make -C ~/.config/retrocrt/dotfiles/waybar/iced-bar install
```
Instaluje do `~/.local/bin/iced-bar`; `scripts/ice-exec` sam go wybierze zamiast skryptu sh.

W `~/.config/sway/config` zamień cały blok `bar { … }` na:

```text
bar {
    swaybar_command waybar
}
```
sway uruchamia i zamyka Waybara razem z sesją. Jeden blok `bar` i żadnego `exec waybar` gdzie indziej, inaczej będą dwa paski.

Opcjonalnie, żeby iced-tui otwierał się jako okno pływające:

```text
for_window [app_id="iced-tui"] floating enable
```

```sh
swaymsg reload
```
Przeładowuje konfigurację sway; zmieniony blok `bar` uruchamia Waybara.

```sh
pkill -USR2 -x waybar
```
Przeładowuje konfigurację i styl Waybara bez wylogowania (SIGUSR2 = `reload`, domyślnie). Zmiany samego `style.css` Waybar wczytuje sam (`reload_style_on_change`).

## vpnmgr: format do podpięcia

vpnmgr nie ma polecenia statusu, więc moduł czeka na mały program `vpnmgr-bar` w `PATH` (bez roota), który zapyta demona przez gniazdo unix i wypisze **jedną** linię:

```text
STAN [klucz=wartość ...]
STAN: UP | CONNECTING | DOWN | ERROR
np.:  UP name=pl-waw if=wg1 since=2026-11-02T14:31:00Z
```

Te same zasady co plik `level`: ASCII, do 1024 bajtów, do 32 pól, kod wyjścia 0. Moduł daje mu 3 s (`timeout`). Samego `vpnmgr` pasek nie wywołuje: nieznane podpolecenie mogłoby uruchomić TUI albo demona.

## Plan testów

Zmiany stanu jako root; obserwuj pasek. Pliki zapisuj atomowo, jak będzie robił iced:

```sh
install -d -m 0755 /var/run/iced /var/run/jack
lvl() { printf '%s\n' "$1" > /var/run/iced/level.tmp && mv /var/run/iced/level.tmp /var/run/iced/level; }
```
Tworzy katalogi stanu i funkcję do atomowej podmiany pliku `level`.

| Test | Komenda (root) | Oczekiwane |
| --- | --- | --- |
| brak plików | `rm -rf /var/run/iced` | ICE `off`, tooltip „brak katalogu” |
| ZIELONY | `install -d -m 0755 /var/run/iced; lvl ZIELONY` | zielone tło |
| ŻÓŁTY z polami | `lvl 'ZOLTY traces=1'` | żółte tło, tooltip `traces=1` |
| CZERWONY | `lvl 'CZERWONY traces=2 since=2026-11-02T14:31:00Z'` | czerwone tło, oba pola w tooltipie |
| CZARNY | `lvl CZARNY` | fioletowe tło |
| treść niepoprawna | `lvl 'ROZOWY'`; `printf 'ZIELONY\tx=1\n' > /var/run/iced/level` | `off`, „niepoprawna treść” |
| próba wstrzyknięcia | `lvl 'CZERWONY x=$(touch${IFS}/tmp/pwned) y=<b>z</b>'` | tekst dosłownie w tooltipie; `/tmp/pwned` nie powstaje |
| odliczanie | `echo $(( $(date +%s) + 60 )) > /var/run/iced/countdown` | miga, `CZARNY 59s`, co sekundę mniej |
| koniec odliczania | `rm /var/run/iced/countdown` | miganie znika, tik ustaje |
| usunięcie katalogu | `rm -rf /var/run/iced` | `off`; po `install -d …; lvl ZIELONY` wraca |
| sesja Tails | `touch /var/run/jack/session` | „ZA MUREM”, fioletowo |
| koniec sesji | `rm /var/run/jack/session` | dyskretne „BW” |
| Slide bez sesji | prawy klik → Slide (bez pliku session) | komunikat, bez sudo |

Jako użytkownik:

| Test | Komenda | Oczekiwane |
| --- | --- | --- |
| łączność | `~/.config/waybar/scripts/link` | `em0 · wg`, klasa `zielony` |
| brak wgmgmt | `~/.config/waybar/scripts/link '' nieistniejacy` | `wg --`, `zolty` (bez ruszania prawdziwego tunelu) |
| obecność wgmgmt | `ifconfig wgmgmt` | flagi z `UP` |
| ZFS | `~/.config/waybar/scripts/zfs` | `ZFS`, `zielony` |
| VPN | `~/.config/waybar/scripts/vpn` | `VPN --`, `off` (do czasu vpnmgr-bar) |
| iced-tui brak | lewy klik ICE | komunikat „iced-tui nie jest jeszcze zainstalowany” |
| testy C | `make -C …/iced-bar test` | `failed: 0` |
| testy sh | `make -C …/iced-bar test-sh` | `failed: 0` (wolniej, odpytuje co 5 s) |
| całe repo | `VERIFY_SLOW=1 ./verify.sh` | `verify: PASSED` |

Uszkodzona pula bez ryzyka dla danych (root, pula na plikach):

```sh
truncate -s 128m /tmp/z1 /tmp/z2
zpool create bwtest mirror /tmp/z1 /tmp/z2
zpool offline bwtest /tmp/z2
```
Tworzy testową pulę w lustrze na dwóch plikach i odłącza jeden z nich: w ciągu minuty ZFS na pasku zmieni się na `ZFS !` (czerwony), a tooltip pokaże `DEGRADED`. Sprzątanie: `zpool destroy bwtest; rm /tmp/z1 /tmp/z2`.

Zużycie CPU (jako użytkownik; `see_other_uids=0` nie przeszkadza, to Twoje procesy):

```sh
ps -U "$USER" -o pid,%cpu,time,command | grep -E 'iced-bar|waybar'
```
Pokazuje czas procesora; `TIME` przy `iced-bar` nie powinien rosnąć bez zmian stanu.

```sh
procstat -r "$(pgrep -U "$USER" -x iced-bar | head -n 1)" | grep 'context switches'
```
Liczniki przełączeń kontekstu: odczyt teraz i po minucie. Bez zmian stanu i bez odliczania liczba prawie stoi (kqueue śpi); podczas odliczania rośnie o około 60 na minutę.

Wygląd:

```sh
GTK_DEBUG=interactive waybar
```
Uruchamia drugą kopię Waybara z inspektorem GTK: pokazuje klasy (`zielony`, `armed`) i reguły CSS każdego modułu. Zamknij ją po oględzinach, żeby nie było dwóch pasków.

## Do sprawdzenia w Twojej wersji

| Co | Jak | Po co |
| --- | --- | --- |
| wersja Waybara | `waybar --version`, `pkg info waybar` | `menu` wymaga ≥ 0.10.4, `include` ≥ 0.9.8 |
| zbudowane moduły | `ls /usr/local/share/man/man5/ \| grep waybar` | brak `waybar-network.5` potwierdza brak modułu `network` (port bez libnl) |
| nazwa karty | `ifconfig -l ether` | wpisz ją w `modules/net.jsonc` (`… /link em0 wgmgmt`) |
| tunel | `ifconfig wgmgmt` jako użytkownik | moduł czyta tylko flagi i adres |
| czujnik temperatury | `sysctl dev.cpu.0.temperature`, `kldstat \| grep -E 'coretemp\|amdtemp'`, `sysrc kld_list` | ścieżka i numer czujnika (`temp 0 70 85`) |
| mikser | `mixer vol.volume`, `cat /dev/sndstat` | domyślna karta OSS |
| ZFS bez roota | `zpool status -x`, `ls -l /dev/zfs` | moduł działa bez sudo |
| Nerd Font | `fc-list : family \| grep -i nerd` | czy jest `icons.jsonc` |
| sygnały | tylko `SIGUSR2` (przeładowanie); żadnych `SIGRTMIN+N` | nic do numerowania |
| sudo bez hasła | `sudo -n -l /usr/local/bin/jack slide` | Slide nie zawiśnie na haśle |
| komunikaty | `notify-send test test` | czy mako działa |
| locale | `locale` (UTF-8, np. `pl_PL.UTF-8`) | polskie znaki w tooltipach |
| `/var/run` po restarcie | rc czyści `/var/run`; iced tworzy katalogi sam | do tego czasu moduły pokazują `off` |
