//
//  dydxMarketInfoHeaderView.swift
//  dydxViews
//
//  Created by Rui Huang on 10/6/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketInfoHeaderViewModel: PlatformViewModel {
    @Published public var sharedMarketViewModel: SharedMarketViewModel? = SharedMarketViewModel()
    @Published public var favoriteViewModel: dydxUserFavoriteViewModel? = dydxUserFavoriteViewModel(size: .init(width: 20, height: 20))
    @Published public var onBackButtonTap: (() -> Void)?
    @Published public var onMarketSelectorTap: (() -> Void)?

    public init() {}

    public static var previewValue: dydxMarketInfoHeaderViewModel = {
        let vm = dydxMarketInfoHeaderViewModel()
        vm.sharedMarketViewModel = .previewValue
        vm.favoriteViewModel = .previewValue
        return vm
    }()

    private func createMarketSelectorView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> some View {
        HStack(spacing: 8) {
            PlatformIconViewModel(type: .url(url: self.sharedMarketViewModel?.logoUrl),
                                  clip: .defaultCircle,
                                  size: CGSize(width: 24, height: 24),
                                  backgroundColor: .colorWhite)
            .createView(parentStyle: parentStyle, styleKey: styleKey)
            HStack(spacing: 4) {
                Text(sharedMarketViewModel?.assetName ?? "")
                    .themeColor(foreground: .textSecondary)
                    .themeFont(fontType: .base, fontSize: .large)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            PlatformIconViewModel(type: .asset(name: "icon_dropdown", bundle: .dydxView),
                                  clip: .noClip,
                                  size: .init(width: 14, height: 8))
            .createView(parentStyle: parentStyle, styleKey: styleKey)
        }
        .onTapGesture(perform: self.onMarketSelectorTap ?? {})
    }

    private func statLine<Value: View>(labelKey: String, valueType: ThemeFont.FontType? = .base, value: () -> Value) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(DataLocalizer.localize(path: labelKey))
                .themeColor(foreground: .textTertiary)
                .themeFont(fontType: .base, fontSize: .smallest)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            value()
                .themeColor(foreground: .textSecondary)
                .themeFont(fontType: valueType, fontSize: .medium)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
    }

    private func statLine(labelKey: String, value: String, valueType: ThemeFont.FontType? = .base) -> some View {
        statLine(labelKey: labelKey) { Text(value) }
    }

    private func createMarketInfoView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> some View {
        HStack(alignment: .center) {
            statLine(labelKey: "APP.GENERAL.PRICE", value: sharedMarketViewModel?.indexPrice ?? "")
                .padding(.horizontal, 16)
                .overlay(
                    Rectangle()
                        .frame(width: 1)
                        .themeColor(foreground: .layer3),
                    alignment: .trailing
                )
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    statLine(labelKey: "APP.GENERAL.MARKET_CAP", value: sharedMarketViewModel?.marketCap ?? "")
                    statLine(labelKey: "APP.TRADE.CHANGE_24H") { sharedMarketViewModel?.priceChangePercent24H?.createView() }
                    statLine(labelKey: "APP.TRADE.VOLUME_24H", value: sharedMarketViewModel?.volume24H ?? "")
                    statLine(labelKey: "APP.TRADE.OPEN_INTEREST", value: sharedMarketViewModel?.openInterest ?? "")
                    statLine(labelKey: "APP.TRADE.FUNDING_RATE_SHORT") { sharedMarketViewModel?.fundingRate?.createView() }
                    statLine(labelKey: "APP.TRADE.NEXT_FUNDING") { sharedMarketViewModel?.nextFunding?.createView() }
                    statLine(labelKey: "APP.GENERAL.BUYING_POWER", value: sharedMarketViewModel?.buyingPower ?? "")
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 4)
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self, self.sharedMarketViewModel != nil else {
                return AnyView(PlatformView.nilView)
            }

            return VStack {
                HStack(spacing: 16) {
                    ChevronBackButtonModel(onBackButtonTap: self.onBackButtonTap ?? {})
                        .createView(parentStyle: style)
                        .frame(width: 32)

                    self.createMarketSelectorView(parentStyle: parentStyle, styleKey: styleKey)
                        .frame(maxWidth: .infinity)

                    self.favoriteViewModel?.createView(parentStyle: style)
                        .frame(width: 32)
                }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                DividerModel().createView()
                self.createMarketInfoView(parentStyle: parentStyle)
                DividerModel().createView()
            }
            .wrappedInAnyView()
        }
    }
}

#if DEBUG
struct dydxMarketInfoHeaderView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketInfoHeaderViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketInfoHeaderView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketInfoHeaderViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
