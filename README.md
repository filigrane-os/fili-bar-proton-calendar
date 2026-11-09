# proton-calendar (fili-bar plugin)

Imminent Proton Calendar event in the Filigrane bar, without an open web app. `bin/cal-notify` reads your private ICS links every 5 minutes, notifies before each event and writes the agenda read by the clock card. Recurring events (RRULE/EXDATE) are handled.

```sh
fili-bar install https://github.com/filigrane-os/fili-bar-proton-calendar
```

The daemon starts at login by itself (`autostart` in `module.toml`, run by niri through `fili-bar autostart`).

`fili-bar install` also runs `install.sh`: it creates your options file from `config.example.toml`, asks for what is missing (credentials go to the keyring or to a file under `~/.config`, never to this folder) and prints what is left to do. Run it again with `fili-bar setup proton-calendar`; it is safe to repeat.

## Personal data

The ICS links are secrets: one per line in `~/.config/filigrane/bar/proton-calendar.url` (Proton: Calendar settings > Share via a link, read-only). Options: copy `config.example.toml` to `~/.config/filigrane/bar/proton-calendar.toml`. Neither file is ever committed (`.gitignore` blocks `*.url` and `config.toml`).
