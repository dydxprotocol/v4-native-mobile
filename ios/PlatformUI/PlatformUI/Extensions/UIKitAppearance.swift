//
//  UIKitAppearance.swift
//  PlatformUI
//
//  Created by Sam Newby on 2025-10-24.
//

import UIKit

public extension ThemeSettings {
    /// Configure global UIKit appearance customizations
    func configureUIKitAppearance() {
        // Segmented displays
        UISegmentedControl.appearance().selectedSegmentTintColor = ThemeColor.SemanticColor.layer4.uiColor
        UISegmentedControl.appearance().backgroundColor = ThemeColor.SemanticColor.layer1.uiColor
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: ThemeColor.SemanticColor.textPrimary.uiColor],
            for: .selected
        )
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: ThemeColor.SemanticColor.textTertiary.uiColor],
            for: .normal
        )
    }
}
