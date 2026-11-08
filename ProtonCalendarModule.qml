// Imminent Proton Calendar event (hidden otherwise), click = open Proton Calendar. A line of the alert file is
// "start epoch<TAB>HH:MM<TAB>title", shown until 5 min after the start.
import QtQuick
import qs
import qs.bar.modules.alert

AlertModule {
    kind: "cal"
    title: "Proton Calendar"
    url: "https://calendar.proton.me"
    glyph: ""
    accent: FiliTheme.sable
    render: (rows, now) => {
        const live = rows.filter(x => Number(x[0]) >= now - 300).sort((a, b) => Number(a[0]) - Number(b[0]));
        if (live.length === 0)
            return null;
        const title = live[0][2] ?? "";
        const short = title.length > 28 ? title.slice(0, 27) + "…" : title;
        return { text: short + " " + (live[0][1] ?? ""), rows: live.map(x => [x[1], x[2] ?? ""]) };
    }
}
