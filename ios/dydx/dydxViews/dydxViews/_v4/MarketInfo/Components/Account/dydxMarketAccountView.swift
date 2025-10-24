//
//  dydxMarketAccountView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/13/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketAccountViewModel: PlatformViewModel {
    @Published public var sharedAccountViewModel: SharedAccountViewModel? = SharedAccountViewModel()
    @Published public var depositAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxMarketAccountViewModel {
        let vm = dydxMarketAccountViewModel()
        vm.sharedAccountViewModel = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _ in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                HStack {
                    PlatformIconViewModel(
                        type: .asset(name: "account_wallet", bundle: .dydxView),
                        clip: .noClip,
                        size: .init(width: 16, height: 16),
                        templateColor: .textTertiary
                    )
                    .createView()
                    Text(DataLocalizer.localize(path: "APP.TRADE.AVAILABLE_TO_TRADE"))
                        .themeColor(foreground: .textTertiary)
                        .themeFont(fontType: .base, fontSize: .small)
                    Spacer()
                    Text(self.sharedAccountViewModel?.freeCollateral ?? "")
                        .themeColor(foreground: .textSecondary)
                        .themeFont(fontType: .base, fontSize: .small)
                    PlatformButtonViewModel(
                        content: PlatformIconViewModel(
                            type: .system(name: "plus.circle"),
                            size: .init(width: 16, height: 16),
                            templateColor: .colorPurple
                        ),
                        type: .iconType,
                        action: { self.depositAction?() }
                    )
                    .createView()

                }
                .padding(12)
                .themeColor(background: .layer1)
                .border(borderWidth: 1, cornerRadius: 12, borderColor: ThemeColor.SemanticColor.layer3.color)
            )
        }
    }
}

#if DEBUG
struct dydxMarketAccountView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketAccountViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketAccountView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketAccountViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
