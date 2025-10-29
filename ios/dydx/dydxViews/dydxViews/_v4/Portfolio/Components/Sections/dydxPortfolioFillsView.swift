//
//  dydxPortfolioFillsView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/5/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxPortfolioFillsViewModel: PlatformListViewModel {
    @Published public var isSignedIn: Bool = false
    @Published public var onboardAction: (() -> Void)?

    public override var placeholder: PlatformViewModel? {
        guard self.isSignedIn else {
            return PlatformButtonViewModel(
                content: Text(DataLocalizer.localize(path: "APP.GENERAL.SIGN_IN_TO_VIEW")).wrappedViewModel,
                action: { self.onboardAction?() }
            )
            .createView()
            .frame(width: UIScreen.main.bounds.width - 16)
            .wrappedViewModel
        }
        return PlaceholderViewModel(
            text: DataLocalizer.localize(path: "APP.TRADE.TRADES_EMPTY_STATE"),
            subText: DataLocalizer.localize(path: "APP.TRADE.TRADES_SHOW_HERE"),
            icon: .system(name: "rectangle.stack.fill"),
            useUpdatedStyle: true
        )
    }

    public init(items: [PlatformViewModel] = [], contentChanged: (() -> Void)? = nil) {
        super.init(items: items,
                   intraItemSeparator: true,
                   firstListItemTopSeparator: false,
                   lastListItemBottomSeparator: true,
                   contentChanged: contentChanged)
        self.width = UIScreen.main.bounds.width - 16
    }

    public static var previewValue: dydxPortfolioFillsViewModel {
        let vm = dydxPortfolioFillsViewModel {}
        vm.items = [
            SharedFillViewModel.previewValue,
            SharedFillViewModel.previewValue
        ]
        return vm
    }
}

#if DEBUG
struct dydxPortfolioFillsView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxPortfolioFillsViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxPortfolioFillsView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxPortfolioFillsViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
