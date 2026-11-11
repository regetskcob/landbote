// Landbote on the Apple Watch: one value large in Mono (new articles), the
// newest headlines below, the Digital Crown scrolls, one action: "Später
// lesen" saves the newest article on the iPhone. Black ground as Horizont
// asks for the watch.
import SwiftUI
import WatchConnectivity

final class HeuteModel: NSObject, ObservableObject, WCSessionDelegate {
  @Published var unread = 0
  @Published var titles: [String] = []
  @Published var sources: [String] = []
  @Published var ids: [Int] = []
  @Published var saved = false

  override init() {
    super.init()
    if WCSession.isSupported() {
      WCSession.default.delegate = self
      WCSession.default.activate()
    }
  }

  func apply(_ c: [String: Any]) {
    DispatchQueue.main.async {
      self.unread = c["unread"] as? Int ?? 0
      self.titles = c["titles"] as? [String] ?? []
      self.sources = c["sources"] as? [String] ?? []
      self.ids = c["ids"] as? [Int] ?? []
      self.saved = false
    }
  }

  func saveFirst() {
    guard let id = ids.first, WCSession.default.isReachable else { return }
    WCSession.default.sendMessage(["save": id], replyHandler: nil)
    saved = true
  }

  func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
    apply(session.receivedApplicationContext)
  }

  func session(_ session: WCSession, didReceiveApplicationContext context: [String: Any]) {
    apply(context)
  }
}

struct HeuteWatchView: View {
  @StateObject private var model = HeuteModel()

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 6) {
        Text("HEUTE · NEU")
          .font(.system(size: 11, weight: .semibold, design: .monospaced))
          .foregroundStyle(Hz.textMuted(true))
        Text("\(model.unread)")
          .font(.system(size: 44, weight: .regular, design: .monospaced))
          .monospacedDigit()
          .foregroundStyle(Hz.accentText(true))
        Rectangle().fill(Hz.line(true)).frame(height: 1)
        ForEach(Array(model.titles.enumerated()), id: \.offset) { i, title in
          VStack(alignment: .leading, spacing: 0) {
            if i < model.sources.count {
              Text(model.sources[i].uppercased())
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(Hz.textMuted(true))
            }
            Text(title).font(.system(size: 15, weight: .semibold)).foregroundStyle(Hz.text(true))
          }
        }
        if !model.ids.isEmpty {
          Button(model.saved ? "Gemerkt" : "Später lesen") { model.saveFirst() }
            .disabled(model.saved)
            .padding(.top, 8)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .background(Color.black)
  }
}

@main
struct LandboteWatchApp: App {
  var body: some Scene {
    WindowGroup { HeuteWatchView() }
  }
}
