//
//  dydxSimpleUIMarketInfoHeaderView.swift
//  dydxUI
//
//  Created by Rui Huang on 26/12/2024.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import Foundation

public class dydxSimpleUIMarketInfoHeaderViewModel: PlatformViewModel {
    @Published public var sharedMarketViewModel: SharedMarketViewModel? = SharedMarketViewModel()
    @Published public var onBackButtonTap: (() -> Void)?
    @Published public var favoriteViewModel: dydxUserFavoriteViewModel? = dydxUserFavoriteViewModel(size: .init(width: 20, height: 20))

    public init() { }

    public static var previewValue: dydxSimpleUIMarketInfoHeaderViewModel {
        let vm = dydxSimpleUIMarketInfoHeaderViewModel()
        vm.sharedMarketViewModel = .previewValue
        vm.favoriteViewModel = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return HStack(spacing: 12) {
                HStack(spacing: 4) {
                    ChevronBackButtonModel(onBackButtonTap: self.onBackButtonTap ?? {})
                        .createView(parentStyle: style)
                        .frame(width: 24)

                    self.createIcon(style: style)
                }

                self.createNameVolume(style: style)

                Spacer()

                self.createPriceChange(style: style)

                self.favoriteViewModel?.createView(parentStyle: style)
                    .frame(width: 32)
            }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .wrappedInAnyView()
        }
    }

    private func createIcon(style: ThemeStyle) -> some View {
        let placeholderText = { [weak self] in
            if let assetName = self?.sharedMarketViewModel?.assetName {
                return Text(assetName.prefix(1))
                    .frame(width: 32, height: 32)
                    .themeColor(foreground: .textTertiary)
                    .themeColor(background: .layer5)
                    .borderAndClip(style: .circle, borderColor: .layer7, lineWidth: 1)
                    .wrappedInAnyView()
            }
            return AnyView(PlatformView.nilView)
        }
        let iconType = PlatformIconViewModel.IconType.url(url: sharedMarketViewModel?.logoUrl, placeholderContent: placeholderText)
        return PlatformIconViewModel(type: iconType,
                                     clip: .circle(background: .transparent, spacing: 0),
                                     size: CGSize(width: 32, height: 32),
                                     backgroundColor: .colorWhite)
            .createView(parentStyle: style)
    }

    private func createNameVolume(style: ThemeStyle) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(sharedMarketViewModel?.assetId ?? "")
                .themeColor(foreground: .textPrimary)
                .themeFont(fontSize: .medium)

            HStack(spacing: 4) {
                if sharedMarketViewModel?.isLaunched ?? true {
                    Text(sharedMarketViewModel?.marketCap ?? "-")
                        .themeColor(foreground: .textSecondary)
                    Text(DataLocalizer.localize(path: "APP.GENERAL.MARKET"))
                        .themeColor(foreground: .textTertiary)
                } else {
                    Text(DataLocalizer.localize(path: "APP.GENERAL.LAUNCHABLE"))
                        .themeColor(foreground: .textTertiary)
                }
            }
            .themeFont(fontSize: .small)
        }
    }

    private func createPriceChange(style: ThemeStyle) -> some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(sharedMarketViewModel?.indexPrice ?? "")
                .themeColor(foreground: .textPrimary)
                .themeFont(fontSize: .medium)

            sharedMarketViewModel?.priceChangePercent24H?.createView(parentStyle: style.themeFont(fontSize: .small))
        }
    }
}

#if DEBUG
struct dydxSimpleUIMarketInfoHeaderView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketInfoHeaderViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUIMarketInfoHeaderView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUIMarketInfoHeaderViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
