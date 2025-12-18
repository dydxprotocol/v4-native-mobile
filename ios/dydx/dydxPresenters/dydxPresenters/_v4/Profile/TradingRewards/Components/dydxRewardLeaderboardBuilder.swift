//
//  dydxRewardLeaderboardBuilder.swift
//  dydxPresenters
//
//  Created by Sam Newby on 2025-12-17.
//

import Foundation
import ParticlesKit
import PlatformUI
import RoutingKit
import Utilities
import dydxViews
import React
import dydxStateManager
import Combine

protocol DydxRewardLeaderboardDelegate: AnyObject {
    func onNavigateBack()
}

public class dydxRewardLeaderboardBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        return dydxRewardLeaderboardViewController() as? T
    }
}

@objc(LeaderboardNativeModule)
class LeaderboardNativeModule: NSObject, RCTBridgeModule {
    weak var delegate: DydxRewardLeaderboardDelegate?

    static func moduleName() -> String {
        return "LeaderboardNativeModule"
    }

    @objc
    static func requiresMainQueueSetup() -> Bool {
        return false
    }

    @objc(onNavigateBack)
    func onNavigateBack() {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.onNavigateBack()
        }
    }
}

public class dydxRewardLeaderboardBridgeManager {
    public static let shared = dydxRewardLeaderboardBridgeManager()
    private let module = LeaderboardNativeModule()

    weak var delegate: DydxRewardLeaderboardDelegate? {
        didSet {
            module.delegate = delegate
        }
    }

    public lazy var bridge: RCTBridge = {
        RCTBridge(bundleURL: Self.bundleURL!,
                  moduleProvider: {
            [self.module]
        },
                  launchOptions: nil)
    }()

    public static var bundleURL: URL? {
#if DEBUG
        RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index")
#else
        Bundle.main.url(forResource: "main", withExtension: "jsbundle")
#endif
    }
}

private class dydxRewardLeaderboardViewController: ReactNativeHostingController, NavigableProtocol, DydxRewardLeaderboardDelegate {
    private let bridge = dydxRewardLeaderboardBridgeManager.shared.bridge
    private var subscriptions = Set<AnyCancellable>()

    init() {
        let initialProperties: [String: Any] = [
            "address": NSNull(),
            "theme": dydxThemeSettings.shared.currentThemeType.rnThemeIdentifier
        ]

        super.init(moduleName: "Leaderboard",
                   initialProperties: initialProperties,
                   bridge: bridge)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dydxRewardLeaderboardBridgeManager.shared.delegate = self
    }

    override func setupSubscriptions() {
        // Get initial value and then observe changes
        AbacusStateManager.shared.state.walletState
            .map { $0.currentWallet?.cosmoAddress }
            .removeDuplicates()
            .sink { [weak self] cosmoAddress in
                self?.updateAddress(cosmoAddress)
            }
            .store(in: &subscriptions)
    }

    private func updateAddress(_ address: String?) {
        let bridge = dydxRewardLeaderboardBridgeManager.shared.bridge
        let addressValue = address
        bridge.enqueueJSCall(
            "RCTDeviceEventEmitter",
            method: "emit",
            args: ["addressChanged", ["address": addressValue]],
            completion: nil
        )
    }

    func navigate(to request: RoutingKit.RoutingRequest?, animated: Bool, completion: RoutingKit.RoutingCompletionBlock?) {
        completion?(nil, true)
    }

    func onNavigateBack() {
        navigationController?.popViewController(animated: true)
    }
}
