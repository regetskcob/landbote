// The Heute widget (WidgetKit). Reads what Flutter wrote through home_widget
// into the app group; draws flat like the app: ground, ink, one hairline.
import SwiftUI
import WidgetKit

private let group = "group.de.regetskcob.landbote"

struct HeuteEntry: TimelineEntry {
  let date: Date
  let unread: Int
  let items: [(title: String, source: String)]
}

struct HeuteProvider: TimelineProvider {
  func placeholder(in context: Context) -> HeuteEntry {
    HeuteEntry(date: .now, unread: 3, items: [("Kamera-Experimente in der Toskana", "Simons Seite")])
  }

  func getSnapshot(in context: Context, completion: @escaping (HeuteEntry) -> Void) {
    completion(read())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<HeuteEntry>) -> Void) {
    // Flutter asks for a reload after every refresh; this is the fallback.
    completion(Timeline(entries: [read()], policy: .after(.now.addingTimeInterval(60 * 60))))
  }

  private func read() -> HeuteEntry {
    let defaults = UserDefaults(suiteName: group)
    let unread = defaults?.integer(forKey: "unread") ?? 0
    var items: [(String, String)] = []
    if let json = defaults?.string(forKey: "top"), let data = json.data(using: .utf8),
       let list = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
      items = list.map { ($0["title"] as? String ?? "", $0["source"] as? String ?? "") }
    }
    return HeuteEntry(date: .now, unread: unread, items: items)
  }
}

struct HeuteView: View {
  @Environment(\.colorScheme) var scheme
  @Environment(\.widgetFamily) var family
  let entry: HeuteEntry

  var body: some View {
    let dark = scheme == .dark
    VStack(alignment: .leading, spacing: 4) {
      Text(entry.unread == 0 ? "HEUTE · ALLES GELESEN" : "HEUTE · NEU")
        .font(.system(size: 11, weight: .semibold, design: .monospaced))
        .tracking(0.9)
        .foregroundStyle(Hz.textMuted(dark))
      Text("\(entry.unread)")
        .font(.system(size: 32, weight: .regular, design: .monospaced))
        .monospacedDigit()
        .foregroundStyle(Hz.accentText(dark))
      if family != .systemSmall {
        Rectangle().fill(Hz.line(dark)).frame(height: 1).padding(.vertical, 4)
        ForEach(Array(entry.items.prefix(family == .systemLarge ? 3 : 2).enumerated()), id: \.offset) { _, item in
          VStack(alignment: .leading, spacing: 0) {
            Text(item.source.uppercased())
              .font(.system(size: 10, weight: .semibold, design: .monospaced))
              .foregroundStyle(Hz.textMuted(dark))
            Text(item.title)
              .font(.system(size: 14, weight: .semibold))
              .foregroundStyle(Hz.text(dark))
              .lineLimit(2)
          }
        }
      }
      Spacer(minLength: 0)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .containerBackground(Hz.bg(dark), for: .widget)
  }
}

@main
struct LandboteHeute: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "LandboteHeute", provider: HeuteProvider()) { entry in
      HeuteView(entry: entry)
    }
    .configurationDisplayName("Heute")
    .description("Neue Beiträge von heute.")
    .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
  }
}
