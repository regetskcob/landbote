/// The interface texts, German. One place, so a later translation only
/// replaces this file with generated localizations.
library;

// ignore_for_file: public_member_api_docs

abstract final class S {
  static const appName = 'Landbote';
  static const sender = 'ein Projekt von regetskcob';

  // Destinations
  static const today = 'Heute';
  static const sources = 'Quellen';
  static const saved = 'Gemerkt';
  static const archive = 'Archiv';
  static const menu = 'Menü';
  static const settings = 'Einstellungen';
  static const search = 'Suchen';

  // Kennungen
  static String todayKennung(int n) => n == 0 ? 'HEUTE · ALLES GELESEN' : 'HEUTE · $n NEU';
  static String sourcesKennung(int n) => 'QUELLEN · $n';
  static String savedKennung(int n) => 'GEMERKT · $n';
  static const archiveKennung = 'ARCHIV · GELESEN UND GEERNTET';
  static const folderless = 'Ohne Ordner';

  // Lists
  static const emptyToday = 'Alles gelesen. Der Himmel ist leer.';
  static const emptyTodayDetail = 'Neues kommt von selbst. Ziehen zum Aktualisieren.';
  static const emptySaved = 'Noch nichts gemerkt.';
  static const emptySavedDetail = 'Wische einen Beitrag nach rechts oder tippe auf das Lesezeichen.';
  static const emptySources = 'Noch keine Quellen.';
  static const emptySourcesDetail = 'Füge eine Seite oder einen Feed hinzu, oder importiere eine OPML-Datei.';
  static const emptyFeed = 'Diese Quelle hat noch nichts geliefert.';
  static const emptySearch = 'Nichts gefunden.';
  static const markAllRead = 'Alles gelesen';
  static const markAllReadConfirm = 'Alle Beiträge dieser Liste als gelesen markieren?';
  static const refresh = 'Aktualisieren';
  static const refreshing = 'Aktualisiere';
  static String refreshed(int n) => n == 0 ? 'Nichts Neues.' : (n == 1 ? '1 neuer Beitrag.' : '$n neue Beiträge.');
  static String refreshFailed(int n) => n == 1 ? '1 Quelle nicht erreichbar.' : '$n Quellen nicht erreichbar.';
  static const read = 'Gelesen';
  static const unread = 'Ungelesen';
  static const markRead = 'Als gelesen markieren';
  static const markUnread = 'Als ungelesen markieren';
  static const save = 'Merken';
  static const unsave = 'Nicht mehr merken';
  static String bundle(int n) => '$n Beiträge';
  static const bundleOpen = 'Aufklappen';
  static const bundleClose = 'Zuklappen';
  static const yesterday = 'Gestern';
  static String minutes(int n) => '$n MIN';
  static const showUnreadOnly = 'Nur ungelesene';

  // Reader
  static const share = 'Teilen';
  static const openInBrowser = 'Im Browser öffnen';
  static const fullText = 'Volltext laden';
  static const fullTextLoading = 'Lade den ganzen Beitrag';
  static const fullTextFailed = 'Der Beitrag ließ sich nicht laden. Es bleibt die Fassung aus dem Feed.';
  static const feedVersion = 'Fassung aus dem Feed';
  static const loadImage = 'Bild laden';
  static const next = 'Nächster Beitrag';
  static const previous = 'Voriger Beitrag';
  static const noContent = 'Dieser Beitrag hat keinen Text im Feed.';
  static const copyLink = 'Link kopieren';
  static const linkCopied = 'Link kopiert.';
  static String chapter(int n) => 'Abschnitt $n';
  static const progress = 'Lesefortschritt';

  // Sources
  static const addSource = 'Quelle hinzufügen';
  static const addSourceHint = 'Adresse einer Seite oder eines Feeds';
  static const addSourceHelp = 'Landbote findet den Feed selbst, etwa bei smnvdl.de oder regetskcob.de.';
  static const find = 'Suchen';
  static const finding = 'Suche Feeds';
  static const noFeedFound = 'Unter dieser Adresse ist kein Feed zu finden.';
  static const add = 'Hinzufügen';
  static const added = 'Hinzugefügt.';
  static const folder = 'Ordner';
  static const newFolder = 'Neuer Ordner';
  static const noFolder = 'Kein Ordner';
  static const rename = 'Umbenennen';
  static const name = 'Name';
  static const delete = 'Löschen';
  static const deleteFeed = 'Quelle löschen';
  static String deleteFeedConfirm(String t) => '„$t“ und alle Beiträge daraus löschen? Gemerktes geht mit.';
  static const deleteFolder = 'Ordner löschen';
  static String deleteFolderConfirm(String t) => 'Ordner „$t“ löschen? Die Quellen bleiben, ohne Ordner.';
  static const feedSettings = 'Quelle';
  static const alwaysFullText = 'Immer den ganzen Beitrag laden';
  static const alwaysFullTextHelp = 'Für Feeds, die nur einen Anriss liefern.';
  static const neverBundle = 'Nie bündeln';
  static const neverBundleHelp = 'Auch viele Beiträge am Tag einzeln zeigen.';
  static const lastFetched = 'ZULETZT';
  static const address = 'ADRESSE';
  static const site = 'SEITE';
  static const error = 'FEHLER';
  static const perMonth = 'IM MONAT';
  static const unreadTerm = 'UNGELESEN';
  static const listView = 'Liste';
  static const mapView = 'Flurkarte';
  static const manageSources = 'Quellen verwalten';
  static const flurkarteKennung = 'FLURKARTE · FLÄCHE NACH BEITRÄGEN IM MONAT';
  static const flurkarteLegendTitle = 'Farbe nach Ungelesenen';
  static const flurkarteLegendLow = 'still';
  static String flurkarteField(int recent, int unread) => unread > 0 ? '$recent im Monat · $unread neu' : '$recent im Monat';
  static const flurkarteLegendHigh = 'laut';
  static String flurkarteSemantics(String t, int n, int u) => '$t, $n Beiträge im Monat, $u ungelesen';

  // Settings
  static const sectionReading = 'LESEN';
  static const sectionHarvest = 'ERNTE';
  static const sectionAccount = 'KONTO';
  static const sectionData = 'DATEN';
  static const sectionSupporter = 'FÖRDERPAKET';
  static const sectionAbout = 'ÜBER';
  static const appearance = 'Erscheinung';
  static const system = 'System';
  static const light = 'Hell';
  static const dark = 'Dunkel';
  static const images = 'Bilder';
  static const imagesAlways = 'Immer laden';
  static const imagesOnDemand = 'Nur auf Wunsch';
  static const openLinks = 'Links öffnen';
  static const openLinksInApp = 'In der App';
  static const openLinksBrowser = 'Im Browser';
  static const harvestAfter = 'Ungelesenes ernten nach';
  static String days(int n) => '$n Tagen';
  static const harvestHelp = 'Was liegen bleibt, wandert leise ins Archiv. Kein Zähler wächst.';
  static const bundleFrom = 'Laute Quellen bündeln ab';
  static String perDay(int n) => '$n Beiträgen';
  static const bundleHelp = 'Viele Beiträge einer Quelle stehen dann als eine Zeile in Heute.';
  static const refreshEvery = 'Im Hintergrund aktualisieren';
  static String everyMinutes(int n) => n >= 60 ? 'alle ${n ~/ 60} h' : 'alle $n min';
  static const refreshOff = 'Nie';
  static const rules = 'Gräben (Filter)';
  static const rulesHelp = 'Beiträge mit diesen Wörtern verschwinden oder gelten als gelesen.';
  static const rulesKennung = 'GRÄBEN';
  static const addRule = 'Graben ziehen';
  static const pattern = 'Wort oder /Regex/';
  static const ruleField = 'Suchen in';
  static const ruleFieldAny = 'Titel und Text';
  static const ruleFieldTitle = 'Nur Titel';
  static const ruleFieldAuthor = 'Autor';
  static const ruleAction = 'Dann';
  static const ruleHide = 'Ausblenden';
  static const ruleMarkRead = 'Als gelesen';
  static const ruleAllFeeds = 'Alle Quellen';
  static const noRules = 'Keine Gräben. Alles fließt durch.';
  static const importOpml = 'OPML importieren';
  static const exportOpml = 'OPML exportieren';
  static String imported(int n) => n == 1 ? '1 Quelle importiert.' : '$n Quellen importiert.';
  static const importFailed = 'Die Datei ist keine lesbare OPML-Datei.';
  static const account = 'Synchronisieren';
  static const accountLocal = 'Nur auf diesem Gerät';
  static const accountHelp = 'Landbote braucht keinen Server. Wer schon FreshRSS, Miniflux oder Nextcloud News nutzt, kann es verbinden.';
  static const server = 'Server';
  static const serverUrl = 'Adresse des Servers';
  static const user = 'Benutzer';
  static const password = 'Passwort';
  static const apiToken = 'API-Token';
  static const passwordHelpFreshRss = 'Das API-Passwort aus den Profileinstellungen von FreshRSS, nicht das Login-Passwort.';
  static const tokenHelpMiniflux = 'Einstellungen › API-Schlüssel in Miniflux.';
  static const connect = 'Verbinden';
  static const connecting = 'Verbinde';
  static const disconnect = 'Trennen';
  static const disconnectConfirm = 'Konto trennen? Quellen und Beiträge bleiben auf diesem Gerät.';
  static const connectFailed = 'Anmeldung fehlgeschlagen. Adresse und Zugang prüfen.';
  static const syncNow = 'Jetzt synchronisieren';
  static const lastSync = 'ZULETZT';
  static const connectedTo = 'VERBUNDEN';
  static const yearHarvest = 'Jahresernte';
  static const readingStyle = 'Lesestil';
  static const morningEdition = 'Morgenausgabe';
  static const about = 'Über Landbote';
  static const licenses = 'Lizenzen';
  static const sourceCode = 'Quelltext';
  static const sourceCodeHelp = 'Landbote ist offen, MPL-2.0.';
  static const version = 'VERSION';
  static const keyboard = 'Tastenkürzel';

  // Supporter
  static const supporterTitle = 'Förderpaket';
  static const supporterKennung = 'FÖRDERPAKET · EINMALIG';
  static const supporterIntro =
      'Landbote ist offen und bleibt es. Wer die Arbeit daran unterstützen will, bekommt dafür drei Dinge, die den Reader zum eigenen machen.';
  static const supporterStyle = 'Lesestil';
  static const supporterStyleText = 'Schrift, Größe, Zeilenabstand und Satz der Beiträge nach eigenem Geschmack.';
  static const supporterHarvest = 'Jahresernte';
  static const supporterHarvestText = 'Ein Jahr Lesen auf einen Blick: Tage, Quellen und Lesezeit, als Flur von oben.';
  static const supporterMorning = 'Morgenausgabe';
  static const supporterMorningText = 'Jeden Morgen zur gewählten Zeit eine Zeile: was über Nacht gekommen ist.';
  static const supporterFlag = 'Die Fahne';
  static const supporterFlagText = 'Im Über-Dialog steht, seit wann du Förderer bist. Mehr nicht, versprochen.';
  static String buy(String price) => 'Fördern für $price';
  static const buyFallbackPrice = '2,99 €';
  static const restore = 'Käufe wiederherstellen';
  static const thanks = 'Danke. Die Fahne ist oben.';
  static String supporterSince(String d) => 'FÖRDERER SEIT $d';
  static const storeUnavailable = 'Der Store ist gerade nicht erreichbar.';
  static const purchaseFailed = 'Der Kauf hat nicht geklappt.';
  static const purchasePending = 'Der Kauf wartet auf Bestätigung.';
  static const locked = 'Im Förderpaket';
  static const unlock = 'Ansehen';

  // Reading style
  static const font = 'Schrift';
  static const fontLiterata = 'Literata';
  static const fontMona = 'Mona Sans';
  static const size = 'Größe';
  static const lineSpacing = 'Zeilenabstand';
  static const lineTight = 'Eng';
  static const lineNormal = 'Normal';
  static const lineWide = 'Weit';
  static const alignment = 'Satz';
  static const alignLeft = 'Flattersatz';
  static const alignJustify = 'Blocksatz';
  static const preview = 'VORSCHAU';
  static const previewText =
      'Der Rhein liegt still unter dem Nebel, am Deich stehen die Kopfweiden in einer Reihe. Weiter hinten, wo der Feldweg abknickt, steht ein Briefkasten am Pfahl, die Fahne oben.';

  // Morning edition
  static const morningTime = 'Uhrzeit';
  static const morningOn = 'Morgenausgabe senden';
  static const morningHelp = 'Eine Mitteilung am Morgen, nur wenn es Neues gibt.';
  static String morningBody(int n, int f) => n == 1 ? '1 neuer Beitrag aus $f Quelle.' : '$n neue Beiträge aus $f Quellen.';
  static const morningTitle = 'Deine Morgenausgabe';

  // Jahresernte
  static String harvestKennung(int year) => 'JAHRESERNTE · $year';
  static const harvestRead = 'GELESEN';
  static const harvestMinutes = 'LESEZEIT';
  static const harvestDays = 'TAGE';
  static const harvestTop = 'MEISTGELESEN';
  static String harvestDaySemantics(String d, int n) => '$d: $n gelesen';
  static const harvestEmpty = 'Noch nichts gelesen in diesem Jahr.';

  // Misc
  static const cancel = 'Abbrechen';
  static const ok = 'OK';
  static const done = 'Fertig';
  static const offline = 'Offline. Es bleibt, was schon da ist.';
  static const retry = 'Erneut versuchen';
  static const welcomeKennung = 'LANDBOTE · RSS-READER';
  static const welcomeTitle = 'Was draußen geschrieben wird, kommt hierher.';
  static const welcomeText =
      'Füge Seiten hinzu, die du lesen willst. Landbote holt neue Beiträge, zeigt sie in Ruhe und vergisst, was du nicht lesen wolltest.';
  static const welcomeStart = 'Mit regetskcob.de anfangen';
  static const welcomeOwn = 'Eigene Quelle hinzufügen';
}
