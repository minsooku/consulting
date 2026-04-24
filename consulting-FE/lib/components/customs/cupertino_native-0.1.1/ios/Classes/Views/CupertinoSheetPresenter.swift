import Flutter
import UIKit

// MARK: - Sheet Presenter (singleton)

class CupertinoSheetPresenter: NSObject {
    static let shared = CupertinoSheetPresenter()

    private var engineGroup: FlutterEngineGroup?
    private var activeSheetEngine: FlutterEngine?
    private var mainChannel: FlutterMethodChannel?
    private var resultCallback: FlutterResult?

    // Warm-up state
    private var warmedEngine: FlutterEngine?
    private var warmedChannel: FlutterMethodChannel?
    private var engineReady = false

    // Prevents handleSheetDismissed from stealing the result during a
    // programmatic dismiss (closeSheet). viewDidDisappear fires before
    // the dismiss completion handler, so without this flag the result
    // would be overwritten with nil.
    private var closingProgrammatically = false

    // MARK: Setup

    func setup(messenger: FlutterBinaryMessenger) {
        mainChannel = FlutterMethodChannel(
            name: "cupertino_native_sheet",
            binaryMessenger: messenger
        )
        mainChannel?.setMethodCallHandler { [weak self] call, result in
            self?.handleMainCall(call, result: result)
        }
    }

    // MARK: Main-engine channel handler

    private func handleMainCall(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        switch call.method {
        case "showSheet":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(
                    code: "INVALID_ARGS",
                    message: "Expected dictionary arguments",
                    details: nil
                ))
                return
            }
            resultCallback = result
            showSheet(config: args)

        case "closeSheet":
            let args = call.arguments as? [String: Any]
            closeSheet(result: args?["result"])
            result(nil)

        case "warmUp":
            warmUp()
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: Warm-up

    private func ensureEngineGroup() {
        if engineGroup == nil {
            engineGroup = FlutterEngineGroup(name: "cn_sheet_engines", project: nil)
        }
    }

    /// Pre-spawn the secondary engine so it's ready when the first sheet opens.
    private func warmUp() {
        guard warmedEngine == nil, activeSheetEngine == nil else { return }

        ensureEngineGroup()
        let options = FlutterEngineGroupOptions()
        options.entrypoint = "sheetMain"

        guard let engine = engineGroup?.makeEngine(with: options) else { return }
        warmedEngine = engine
        engineReady = false

        Self.registerPlugins(with: engine)

        let channel = FlutterMethodChannel(
            name: "cupertino_native_sheet_content",
            binaryMessenger: engine.binaryMessenger
        )
        warmedChannel = channel

        channel.setMethodCallHandler { [weak self] call, result in
            switch call.method {
            case "ready":
                self?.engineReady = true
                result(nil)
            case "closeSheet":
                let args = call.arguments as? [String: Any]
                self?.closeSheet(result: args?["result"])
                result(nil)
            case "setDetent":
                let args = call.arguments as? [String: Any]
                let name = args?["detent"] as? String ?? "large"
                self?.setDetent(name: name)
                result(nil)
            case "setScrollLocked":
                let args = call.arguments as? [String: Any]
                let locked = args?["locked"] as? Bool ?? false
                self?.setScrollLocked(locked)
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    // MARK: Present

    private func showSheet(config: [String: Any]) {
        let engine: FlutterEngine
        let contentChannel: FlutterMethodChannel

        if let warm = warmedEngine, engineReady, let ch = warmedChannel {
            // ── Warm path: engine already running, just send route ──
            engine = warm
            contentChannel = ch
            warmedEngine = nil
            warmedChannel = nil
            engineReady = false

            contentChannel.invokeMethod("setRoute", arguments: [
                "route": config["route"] ?? "",
                "arguments": config["arguments"] ?? [String: Any](),
            ])
        } else {
            // ── Cold path: create engine from scratch ──
            warmedEngine?.destroyContext()
            warmedEngine = nil
            warmedChannel = nil
            engineReady = false

            ensureEngineGroup()
            let options = FlutterEngineGroupOptions()
            options.entrypoint = "sheetMain"

            guard let newEngine = engineGroup?.makeEngine(with: options) else {
                fail("ENGINE_FAILED", "Could not create secondary FlutterEngine")
                return
            }
            engine = newEngine
            Self.registerPlugins(with: engine)

            let ch = FlutterMethodChannel(
                name: "cupertino_native_sheet_content",
                binaryMessenger: engine.binaryMessenger
            )
            contentChannel = ch

            ch.setMethodCallHandler { [weak self] call, channelResult in
                switch call.method {
                case "ready":
                    ch.invokeMethod("setRoute", arguments: [
                        "route": config["route"] ?? "",
                        "arguments": config["arguments"] ?? [String: Any](),
                    ])
                    channelResult(nil)
                case "closeSheet":
                    let args = call.arguments as? [String: Any]
                    self?.closeSheet(result: args?["result"])
                    channelResult(nil)
                case "setDetent":
                    let args = call.arguments as? [String: Any]
                    let name = args?["detent"] as? String ?? "large"
                    self?.setDetent(name: name)
                    channelResult(nil)
                case "setScrollLocked":
                    let args = call.arguments as? [String: Any]
                    let locked = args?["locked"] as? Bool ?? false
                    self?.setScrollLocked(locked)
                    channelResult(nil)
                default:
                    channelResult(FlutterMethodNotImplemented)
                }
            }
        }

        activeSheetEngine = engine

        let flutterVC = FlutterViewController(
            engine: engine, nibName: nil, bundle: nil
        )
        flutterVC.overrideUserInterfaceStyle = .light

        guard #available(iOS 15.0, *) else {
            guard let topVC = Self.topViewController() else {
                fail("NO_ROOT_VC", "Could not find a presenting view controller")
                cleanupEngine()
                return
            }
            flutterVC.modalPresentationStyle = .pageSheet
            topVC.present(flutterVC, animated: true)
            return
        }

        let sheetVC = SheetHostViewController(contentVC: flutterVC)
        sheetVC.configureSheet(config: config)
        sheetVC.onDismiss = { [weak self] in
            self?.handleSheetDismissed()
        }

        guard let topVC = Self.topViewController() else {
            fail("NO_ROOT_VC", "Could not find a presenting view controller")
            cleanupEngine()
            return
        }

        topVC.present(sheetVC, animated: true)
    }

    // MARK: Dismiss

    private func closeSheet(result: Any?) {
        guard let topVC = Self.topViewController() else { return }

        let isSheet: Bool
        if #available(iOS 15.0, *) {
            isSheet = topVC is SheetHostViewController
        } else {
            isSheet = topVC is FlutterViewController && topVC != Self.topViewController()
        }
        guard isSheet || topVC.presentingViewController != nil else { return }

        closingProgrammatically = true
        topVC.dismiss(animated: true) { [weak self] in
            self?.closingProgrammatically = false
            self?.cleanupEngine()
            self?.resultCallback?(result)
            self?.resultCallback = nil
            self?.warmUp()
        }
    }

    private func handleSheetDismissed() {
        guard !closingProgrammatically else { return }
        cleanupEngine()
        resultCallback?(nil)
        resultCallback = nil
        warmUp()
    }

    // MARK: Scroll lock

    /// Toggle `isModalInPresentation` on the active sheet so that the native
    /// iOS swipe-to-dismiss gesture is blocked while the Flutter scroll view
    /// is not at the top.
    private func setScrollLocked(_ locked: Bool) {
        guard #available(iOS 15.0, *),
              let topVC = Self.topViewController() as? SheetHostViewController
        else { return }
        DispatchQueue.main.async {
            topVC.isModalInPresentation = locked
        }
    }

    // MARK: Detent

    private func setDetent(name: String) {
        guard #available(iOS 15.0, *),
              let topVC = Self.topViewController() as? SheetHostViewController,
              let sheet = topVC.sheetPresentationController
        else { return }

        sheet.animateChanges {
            switch name {
            case "medium": sheet.selectedDetentIdentifier = .medium
            case "large":  sheet.selectedDetentIdentifier = .large
            default:
                if #available(iOS 16.0, *), name.hasPrefix("custom:") {
                    let fractionStr = String(name.dropFirst("custom:".count))
                    sheet.selectedDetentIdentifier = UISheetPresentationController.Detent.Identifier("custom_\(fractionStr)")
                }
            }
        }
    }

    // MARK: Helpers

    private func cleanupEngine() {
        activeSheetEngine?.destroyContext()
        activeSheetEngine = nil
        engineGroup = nil
    }

    private func fail(_ code: String, _ message: String) {
        resultCallback?(FlutterError(code: code, message: message, details: nil))
        resultCallback = nil
    }

    private static func registerPlugins(with engine: FlutterEngine) {
        let className = "GeneratedPluginRegistrant"
        guard let cls = NSClassFromString(className) as? NSObject.Type else {
            return
        }
        let selector = NSSelectorFromString("registerWithRegistry:")
        if cls.responds(to: selector) {
            cls.perform(selector, with: engine)
        }
    }

    private static func topViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive })
                as? UIWindowScene,
              let keyWindow = scene.windows.first(where: { $0.isKeyWindow })
        else { return nil }

        var vc = keyWindow.rootViewController
        while let presented = vc?.presentedViewController {
            vc = presented
        }
        return vc
    }
}

// MARK: - Sheet Host View Controller

@available(iOS 15.0, *)
class SheetHostViewController: UIViewController,
    UISheetPresentationControllerDelegate,
    UIAdaptivePresentationControllerDelegate
{
    let contentVC: UIViewController
    var onDismiss: (() -> Void)?
    private var sheetConfig: [String: Any] = [:]
    private var didNotifyDismiss = false

    init(contentVC: UIViewController) {
        self.contentVC = contentVC
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    func configureSheet(config: [String: Any]) {
        sheetConfig = config
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light

        addChild(contentVC)
        view.addSubview(contentVC.view)
        contentVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            contentVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        contentVC.didMove(toParent: self)

        if #available(iOS 15.0, *) {
            configureSheetPresentation()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed, !didNotifyDismiss {
            didNotifyDismiss = true
            onDismiss?()
        }
    }

    @available(iOS 15.0, *)
    private func configureSheetPresentation() {
        guard let sheet = sheetPresentationController else { return }
        sheet.delegate = self

        let names = sheetConfig["detents"] as? [String] ?? ["medium", "large"]
        var detents: [UISheetPresentationController.Detent] = []
        for name in names {
            switch name {
            case "medium": detents.append(.medium())
            case "large":  detents.append(.large())
            default:
                if #available(iOS 16.0, *), name.hasPrefix("custom:") {
                    let fractionStr = String(name.dropFirst("custom:".count))
                    if let fraction = Double(fractionStr) {
                        let id = UISheetPresentationController.Detent.Identifier("custom_\(fractionStr)")
                        let detent = UISheetPresentationController.Detent.custom(identifier: id) { context in
                            return context.maximumDetentValue * fraction
                        }
                        detents.append(detent)
                    }
                }
            }
        }
        sheet.detents = detents.isEmpty ? [.medium(), .large()] : detents

        if let initial = sheetConfig["initialDetent"] as? String {
            switch initial {
            case "medium": sheet.selectedDetentIdentifier = .medium
            case "large":  sheet.selectedDetentIdentifier = .large
            default:
                if #available(iOS 16.0, *), initial.hasPrefix("custom:") {
                    let fractionStr = String(initial.dropFirst("custom:".count))
                    sheet.selectedDetentIdentifier = UISheetPresentationController.Detent.Identifier("custom_\(fractionStr)")
                }
            }
        }

        sheet.prefersGrabberVisible =
            sheetConfig["showDragHandle"] as? Bool ?? true

        if let radius = sheetConfig["cornerRadius"] as? Double {
            sheet.preferredCornerRadius = CGFloat(radius)
        }

        let dismissible = sheetConfig["dismissible"] as? Bool ?? true
        isModalInPresentation = !dismissible

        sheet.prefersEdgeAttachedInCompactHeight = true
        sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
    }

    func presentationControllerDidDismiss(
        _ presentationController: UIPresentationController
    ) {
        guard !didNotifyDismiss else { return }
        didNotifyDismiss = true
        onDismiss?()
    }
}
