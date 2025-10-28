//
//  SharedNativeModule.swift
//  dydxPresenters
//
//  Created by Rui Huang on 27/10/2025.
//

import React
import Foundation
import Utilities

@objc(SharedNativeModule)
class SharedNativeModule: NSObject, RCTBridgeModule {
    static func moduleName() -> String {
        return "SharedNativeModule"
    }

    static func requiresMainQueueSetup() -> Bool {
      return false
    }

    private var pendingCompletions: [String: (String) -> Void] = [:]

    @objc(trackEvent::)
    func trackEvent(eventName: String, eventParams: [String: String]) {
        Tracking.shared?.log(event: eventName, data: eventParams)
    }

    @objc(localize::::)
    func localize(path: String,
                  params: Any?,
                  resolver: RCTPromiseResolveBlock,
                  rejecter: RCTPromiseRejectBlock) {
        let dict = params as? [String: String] ?? [:]
        let localizedString = DataLocalizer.localize(path: path, params: dict)
        resolver(localizedString)
    }
}
