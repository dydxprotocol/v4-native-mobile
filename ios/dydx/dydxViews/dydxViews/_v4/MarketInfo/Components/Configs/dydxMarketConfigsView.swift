//
//  dydxMarketConfigsView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/4/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketConfigsViewModel: PlatformViewModel {
    public struct Item: Hashable {
        public init(title: String, value: String, token: TokenTextViewModel? = nil) {
            self.title = title
            self.value = value
            self.token = token
        }

        let title: String
        let value: String
        let token: TokenTextViewModel?
    }

    @Published public var items: [Item] = []

    public init() { }

    public static var previewValue: dydxMarketConfigsViewModel {
        let vm = dydxMarketConfigsViewModel()
        vm.items = [
            Item(title: "Title", value: "Value"),
            Item(title: "Title", value: "Value"),
            Item(title: "Title", value: "Value", token: .previewValue)
        ]
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                VStack(alignment: .leading, spacing: 0) {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.STATS"))
                        .themeColor(foreground: .textPrimary)
                        .themeFont(fontType: .plus, fontSize: .medium)
                        .padding(.bottom, 12)
                    ForEach(Array(self.items.enumerated()), id: \.element) { index, item in
                        HStack {
                            Text(item.title)
                                .themeColor(foreground: .textTertiary)
                            Spacer()
                            HStack(spacing: 4) {
                                Text(item.value)
                                item.token?.createView(parentStyle: style.themeFont(fontSize: .smaller))
                            }
                        }
                        .padding(8)
                        .themeColor(background: index % 2 == 0 ? .layer3 : .transparent)
                    }
                }
                .themeFont(fontSize: .medium)
            )
        }
    }
}

#if DEBUG
struct dydxMarketConfigsView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketConfigsViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketConfigsView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketConfigsViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
