#!/bin/sh
# First-run setup, run by `fili-bar install` / `fili-bar setup` / `fili-bar sync`. Idempotent; asks questions only on a terminal.
# Secrets never go in this folder: they go to the keyring or to a file under ~/.config.
set -u
here="$(cd "$(dirname "$0")" && pwd)"
opts="${FILI_BAR_OPTIONS:-$HOME/.config/filigrane/bar/proton-calendar.toml}"
tty=0; [ -t 0 ] && tty=1
# Options file: copy the example once, never overwrite
if [ ! -e "$opts" ] && [ -f "$here/config.example.toml" ]; then
    mkdir -p "$(dirname "$opts")" && cp "$here/config.example.toml" "$opts" && echo "options: $opts (edit it to change the defaults)"
fi
. "$here/bin/opt.sh"
url_file="$(opt url_file "$HOME/.config/filigrane/bar/proton-calendar.url")"
if [ ! -s "$url_file" ]; then
    if [ "$tty" = 1 ]; then
        echo "Proton Calendar: Settings > Share via a link (read-only), copy the ICS link."
        printf 'ICS link (empty to skip): '; read -r u
        if [ -n "$u" ]; then
            mkdir -p "$(dirname "$url_file")"
            ( umask 077; printf '%s\n' "$u" > "$url_file" )
            echo "link stored in $url_file (mode 600)"
        fi
    else
        echo "put your ICS links, one per line, in $url_file (chmod 600)"
    fi
fi
echo "autostart: $here/bin/cal-notify at login"
