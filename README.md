# Landbote

Ein RSS-Reader für iOS, iPadOS, macOS und Android, gebaut auf
[Horizont](https://www.regetskcob.de/horizont/). Offen unter MPL-2.0.
Ein Projekt von regetskcob.

Landbote ist eine Zeitung, die morgens kommt, kein Posteingang. Was
liegen bleibt, wird nicht zur Pflicht.

## Was Landbote kann

**Lesen**
- *Heute* statt Ordnern mit Zählern. Ungelesenes steht halbfett,
  Gelesenes leise. Nach 3 bis 30 Tagen wandert Liegengebliebenes ins
  Archiv (die Ernte).
- Leseansicht in Literata, auf 720 Breite gesetzt. Beiträge werden in
  Flutter gesetzt, nicht in einer WebView: Text ist auswählbar, Bilder
  öffnen sich auf dem Scrim, Links öffnen im Systembrowser.
- Volltext, lokal extrahiert: Liefert ein Feed nur einen Anriss (etwa
  WordPress mit „[…]“), lädt Landbote die Seite und schneidet den Beitrag
  heraus. Pro Quelle kann man das auf „immer“ stellen.
- **Lese-Horizont:** eine Linie mit dem Zeichen der App, das beim Lesen
  mitwandert; links davon ist sie im Akzent nachgezogen. Zwischenüberschriften
  sind Striche an ihrer echten Stelle; tippen springt hin, ziehen blättert.
  Mit Zeiger steht die Linie oben, auf Touch unten.

**Quellen**
- Eine beliebige Adresse eingeben genügt; den Feed findet Landbote selbst.
- Unterstützt werden RSS 2.0, RSS 1.0 (RDF), Atom und JSON Feed.
- Abrufe sind bedingt (ETag, Last-Modified), Tracking-Parameter werden
  aus Links entfernt.
- **Laute Quellen bündeln:** Eine Quelle mit vielen Beiträgen am Tag
  steht in *Heute* als eine Zeile, aufklappbar.
- **Gräben:** Filter nach Wort oder `/Regex/` in Titel, Text oder
  Autor. Treffer werden ausgeblendet oder als gelesen markiert.
- **Flurkarte:** alle Quellen von oben gesehen. Die Fläche richtet sich
  nach den Beiträgen im Monat, die Farbe der Datenrampe nach dem
  Ungelesenen. Ordner liegen zusammen.
- OPML-Import und -Export.

**Synchronisieren** (optional, ohne eigenen Server)
- FreshRSS über die Google-Reader-API
- Miniflux mit API-Token
- Nextcloud News über API v1-3

**Überall**
- *iPhone, Android:* Tab-Bar mit Heute, Quellen und Gemerkt. Wischen
  merkt einen Beitrag oder markiert ihn als gelesen.
- *iPad (ab 600):* Seitenleiste und Liste. Ab 840 kommt der Leser als
  dritte Spalte dazu.
- *Mac:* Menüleiste, Tastatur zuerst (`J`/`K`, `M`, `S`, `O`, `⌘R`, `⇧⌘A`,
  `⌘1`–`⌘4`, `⌘⌥S`), Kontextmenü mit Rechtsklick.
- *Im Hintergrund:* Abruf über Workmanager (Android) bzw.
  BGTaskScheduler (iOS); auf dem Mac läuft ein Timer, solange die App
  offen ist.
- *Widget „Heute“* (Android fertig, iOS siehe unten) und eine *Apple-Watch-App*:
  ein Wert groß, eine Aktion („Später lesen“).

## Förderpaket (2,99 €, einmalig)

Alles oben ist frei. Das Förderpaket ist ein Dank und kein Schloss:

| | |
| --- | --- |
| **Lesestil** | Schrift (Literata oder Mona Sans), Größe, Zeilenabstand, Blocksatz |
| **Jahresernte** | ein Jahr Lesen als Flur von oben: Tage, Lesezeit, meistgelesene Quellen |
| **Morgenausgabe** | jeden Morgen zur gewählten Zeit eine lokale Mitteilung mit dem, was neu ist |
| **Die Fahne** | im Über-Dialog steht, seit wann man Förderer ist |

Produkt-ID in App Store Connect und Play Console:
`de.regetskcob.landbote.foerderpaket` (Typ: nicht verbrauchbar).
Wer selbst baut, darf das Paket freischalten; der Quelltext ist offen.

## Bauen

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # nur nach Änderungen an der Datenbank
flutter run -d macos     # oder ios, android
flutter test             # Parser, Repository, Sync, Zeitleiste, Bildschirme
```

Horizont hängt per Git am Branch, der Landbote als Produkt eingeführt hat.
Sobald `v0.12.0` getaggt ist, kommt `ref: v0.12.0` in die `pubspec.yaml`.
Die Farben der nativen Widgets erzeugt `python3 tool/widget_colors.py`
aus den Horizont-Tokens.

### Noch einmal von Hand in Xcode

Zwei Ziele lassen sich nicht sauber aus der Kommandozeile anlegen. Die
Quellen liegen bereit, siehe [docs/native-targets.md](docs/native-targets.md):

- `ios/LandboteWidget/`: WidgetKit-Erweiterung „Heute“
- `ios/LandboteWatch/`: watchOS-App

## Aufbau

```
lib/
  app/        Einstieg: Provider, Einstellungen, Förderpaket, Theme
  data/       Drift-Datenbank, Repository (der einzige Schreibweg)
    feeds/    Parser, Abruf, Feed-Suche, OPML, Volltext, Tracking
    sync/     FreshRSS, Miniflux, Nextcloud News, Sync-Engine
  services/   Hintergrund, Morgenausgabe, Widgets, Uhr
  ui/         Schale, Liste, Leser mit Lese-Horizont, Quellen, Flurkarte, Einstellungen
```
