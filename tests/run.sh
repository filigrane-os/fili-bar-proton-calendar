#!/bin/sh
# Tests of the proton-calendar plugin: no network and no real account (the external commands are stubs). Usage: tests/run.sh
PLUGIN=proton-calendar
. "$(dirname "$0")/common.sh"

common_checks
printf 'url_file = "~/cal.url"\nlead_minutes = 15\n' > "$T/options.toml"
check "opt expands ~ and reads the lead time" '[ "$(in_env sh -c ". $ROOT/bin/opt.sh; opt url_file x; echo; opt lead_minutes 10")" = "$HOME_T/cal.url
15" ]'
rm -f "$T/options.toml"
check "opt defaults: lead 10 minutes" '[ "$(in_env sh -c ". $ROOT/bin/opt.sh; opt lead_minutes 10")" = 10 ]'
if python3 -c "import icalendar, dateutil" 2> /dev/null && command -v curl > /dev/null; then
    # an event in 5 minutes, served as a file:// link: notified, and written to the agenda of the clock
    soon="$(date -u -d "+5 min" +%Y%m%dT%H%M%SZ)"; later="$(date -u -d "+90 min" +%Y%m%dT%H%M%SZ)"
    printf 'BEGIN:VCALENDAR\nVERSION:2.0\nBEGIN:VEVENT\nUID:t1@test\nDTSTART:%s\nSUMMARY:Test meeting\nLOCATION:Room 1\nEND:VEVENT\nBEGIN:VEVENT\nUID:t2@test\nDTSTART:%s\nSUMMARY:Later event\nEND:VEVENT\nEND:VCALENDAR\n' "$soon" "$later" > "$T/test.ics"
    printf '# a comment\n\nfile://%s\n' "$T/test.ics" > "$T/cal.url"
    printf 'url_file = "%s"\n' "$T/cal.url" > "$T/options.toml"
    : > "$LOG"
    setsid sh -c "echo \$\$ > '$T/pid'; exec env HOME='$HOME_T' PATH='$STUB:$PATH' FILI_BAR_OPTIONS='$T/options.toml' LOG='$LOG' '$ROOT/bin/cal-notify'" > /dev/null 2>&1 < /dev/null &
    n=0; while [ "$n" -lt 40 ] && [ ! -s "$HOME_T/.local/state/agenda" ]; do sleep 0.25; n=$((n + 1)); done
    sleep 1
    pid="$(cat "$T/pid" 2> /dev/null)"; [ -n "$pid" ] && kill -- "-$pid" 2> /dev/null
    check "cal-notify downloads the link and notifies an imminent event" 'grep -q "notify-send .*Test meeting" "$LOG"'
    check "cal-notify writes the next events for the clock card" 'grep -q "Test meeting" "$HOME_T/.local/state/agenda" && grep -q "Later event" "$HOME_T/.local/state/agenda"'
    check "cal-notify does not notify an event that is far away" '! grep -q "notify-send .*Later event" "$LOG"'
else
    echo "skip - $PLUGIN: python3 icalendar/dateutil or curl missing, cal-notify not run"
fi
check "manifest autostarts cal-notify" 'grep -q "^autostart = .*cal-notify" "$ROOT/module.toml"'

exit "$fail"
