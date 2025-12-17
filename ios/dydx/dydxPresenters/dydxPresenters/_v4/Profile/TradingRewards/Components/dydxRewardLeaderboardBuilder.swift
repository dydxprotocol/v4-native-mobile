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

public class dydxRewardLeaderboardBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        return dydxRewardLeaderboardViewController() as? T
    }
}

@objc(DydxRewardLeaderboardNativeModule)
class DydxRewardLeaderboardNativeModule: NSObject, RCTBridgeModule {
    static func moduleName() -> String {
        return "Leaderboard"
    }
}

public class dydxRewardLeaderboardBridgeManager {
    public static let shared = dydxRewardLeaderboardBridgeManager()
    private let module = DydxRewardLeaderboardNativeModule()

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

private class dydxRewardLeaderboardViewController: ReactNativeHostingController, NavigableProtocol {

    init() {
        super.init(moduleName: "Leaderboard", bridge: dydxRewardLeaderboardBridgeManager.shared.bridge)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func navigate(to request: RoutingKit.RoutingRequest?, animated: Bool, completion: RoutingKit.RoutingCompletionBlock?) {
        completion?(nil, true)
    }
}
