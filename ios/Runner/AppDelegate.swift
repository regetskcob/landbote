import Flutter
import UIKit
import WatchConnectivity
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let watch = WatchBridge()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Background refresh: the plugins of the background isolate, and the
    // BGTask identifier from Info.plist (the system picks the exact time).
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    WorkmanagerPlugin.registerPeriodicTask(
      withIdentifier: "de.regetskcob.landbote.refresh",
      frequency: NSNumber(value: 60 * 60)
    )
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "LandboteWatchBridge") {
      watch.attach(messenger: registrar.messenger())
    }
  }
}

/// Hands Heute to the watch app and the watch's "Später lesen" back to
/// Flutter. The watch shows one value large (new articles) and one action.
final class WatchBridge: NSObject, WCSessionDelegate {
  private var channel: FlutterMethodChannel?

  func attach(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "landbote/watch", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "update", let context = call.arguments as? [String: Any] else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.send(context)
      result(nil)
    }
    self.channel = channel
    if WCSession.isSupported() {
      WCSession.default.delegate = self
      WCSession.default.activate()
    }
  }

  private func send(_ context: [String: Any]) {
    guard WCSession.isSupported(), WCSession.default.activationState == .activated,
          WCSession.default.isPaired, WCSession.default.isWatchAppInstalled else { return }
    try? WCSession.default.updateApplicationContext(context)
  }

  func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
    guard let id = message["save"] as? Int else { return }
    DispatchQueue.main.async { self.channel?.invokeMethod("save", arguments: id) }
  }

  func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {}
  func sessionDidBecomeInactive(_ session: WCSession) {}
  func sessionDidDeactivate(_ session: WCSession) { WCSession.default.activate() }
}
