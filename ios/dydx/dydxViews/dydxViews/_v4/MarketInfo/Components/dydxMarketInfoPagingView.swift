//
//  dydxMarketInfoPagingView.swift
//  dydxViews
//
//  Created by Rui Huang on 10/10/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public enum TileType: Int {
    case price
    case depth
    case funding
    case orderbook
    case recent
}

public class dydxMarketInfoPagingViewModel: PlatformViewModel {
    @Published public var tiles = dydxMarketTilesViewModel()
    @Published public var tileSelection: TileType = .price
    @Published public var account: dydxMarketAccountViewModel? = dydxMarketAccountViewModel()
    @Published public var priceCandles: dydxMarketPriceCandlesViewModel? = dydxMarketPriceCandlesViewModel()
    @Published public var depth: dydxMarketDepthChartViewModel? = dydxMarketDepthChartViewModel()
    @Published public var funding: dydxMarketFundingChartViewModel? = dydxMarketFundingChartViewModel()
    @Published public var trades: dydxMarketTradesViewModel? = dydxMarketTradesViewModel()
    @Published public var orderbook: dydxMarketOrderbookViewModel? = dydxMarketOrderbookViewModel()
    @Published public var isAccountVisible: Bool = true

    public init() { }

    public static var previewValue: dydxMarketInfoPagingViewModel = {
        let vm = dydxMarketInfoPagingViewModel()
        vm.account = .previewValue
        vm.priceCandles = .previewValue
        vm.depth = .previewValue
        vm.funding = .previewValue
        vm.trades = .previewValue
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                VStack {
                    self.tiles.createView(parentStyle: style)

                    Group {
                        switch self.tileSelection {
                        case .price:
                            self.priceCandles?
                                .createView(parentStyle: style)
                        case .depth:
                            self.depth?
                                .createView(parentStyle: style)
                        case .funding:
                            self.funding?
                                .createView(parentStyle: style)
                        case .orderbook:
                            self.orderbook?
                            .createView(parentStyle: style)
                        case .recent:
                            self.trades?
                                .createView(parentStyle: style)
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width, height: 310)

                    if self.isAccountVisible {
                        self.account?.createView(parentStyle: style)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                    }
                }
            )
        }
    }
}

#if DEBUG
struct dydxMarketInfoPagingView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketInfoPagingViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketInfoPagingView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketInfoPagingViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
