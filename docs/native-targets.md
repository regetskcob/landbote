# Widget und Apple Watch in Xcode einrichten

Die Swift-Quellen liegen fertig im Repository. Nur die Ziele selbst
müssen einmal in Xcode angelegt werden. Ein von Hand bearbeitetes
`project.pbxproj` wäre zu fehleranfällig.

Voraussetzung im Apple-Developer-Konto: App-Gruppe
`group.de.regetskcob.landbote`. Der Runner trägt sie bereits
(`ios/Runner/Runner.entitlements`).

## Widget „Heute“ (WidgetKit)

1. `ios/Runner.xcworkspace` öffnen und *File › New › Target › Widget
   Extension* wählen. Name `LandboteWidget`, Bundle-ID
   `de.regetskcob.landbote.widget`, „Include Configuration App Intent“ aus.
2. Die von Xcode erzeugten Swift-Dateien löschen. Stattdessen
   `ios/LandboteWidget/LandboteWidget.swift` und `HzColors.swift` zum Ziel
   hinzufügen.
3. Unter *Signing & Capabilities* die *App Groups* mit
   `group.de.regetskcob.landbote` eintragen.
4. Mindestversion iOS 17 (wegen `containerBackground`).

Der Name des Widgets ist `LandboteHeute`. Flutter ruft
`HomeWidget.updateWidget(iOSName: 'LandboteHeute')` nach jedem Abruf auf.

## Apple Watch

1. *File › New › Target › watchOS › App*. Name `LandboteWatch`,
   Bundle-ID `de.regetskcob.landbote.watchkitapp`, „Watch App for
   Existing iOS App“ mit `Runner` als Begleiter.
2. Die erzeugten Swift-Dateien durch `ios/LandboteWatch/LandboteWatchApp.swift`
   und `HzColors.swift` ersetzen. Den Asset-Katalog
   `ios/LandboteWatch/Assets.xcassets` mit dem App-Icon hinzufügen.
3. Die Verbindung läuft über WatchConnectivity. Das iPhone schickt Heute
   als Application Context (`WatchBridge` in `ios/Runner/AppDelegate.swift`),
   die Uhr schickt `save` zurück, und Flutter merkt den Beitrag
   (`lib/services/watch.dart`).

## Farben

`python3 tool/widget_colors.py` erzeugt `HzColors.swift` und die
Android-Farben aus `tokens/horizont.json`. Das Skript nach jedem
Horizont-Update neu laufen lassen.
