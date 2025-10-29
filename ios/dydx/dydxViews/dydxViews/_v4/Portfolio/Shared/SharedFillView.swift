//
//  SharedFillView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/27/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class SharedFillViewModel: PlatformViewModel {
    public struct Handler: Hashable {
        public static func == (lhs: Handler, rhs: Handler) -> Bool {
            true
        }

        public func hash(into hasher: inout Hasher) { }

        public var onTapAction: (() -> Void)?
    }

    public init(type: String? = nil, amount: String? = nil, date: String? = nil, price: String? = nil, fee: String? = nil, feeLiquidity: String? = nil, sideText: SideTextViewModel = SideTextViewModel(), token: TokenTextViewModel? = TokenTextViewModel(), logoUrl: URL? = nil, onTapAction: (() -> Void)? = nil) {
        self.type = type
        self.size = amount
        self.date = date
        self.price = price
        self.fee = fee
        self.feeLiquidity = feeLiquidity
        self.sideText = sideText
        self.token = token
        self.logoUrl = logoUrl
        self.handler = Handler(onTapAction: onTapAction)
    }

    @Published public var type: String?
    @Published public var size: String?
    @Published public var date: String?
    @Published public var price: String?
    @Published public var fee: String?
    @Published public var feeLiquidity: String?
    @Published public var sideText = SideTextViewModel()
    @Published public var token: TokenTextViewModel? = TokenTextViewModel()
    @Published public var logoUrl: URL?
    @Published public var handler: Handler? = Handler()

    public init() { }

    public static var previewValue: SharedFillViewModel {
        let vm = SharedFillViewModel(type: "Market Order",
                                     amount: "0.017 ETH",
                                     date: Date().englishDatetimeString,
                                     price: "$1,203.8",
                                     fee: "$0.0",
                                     feeLiquidity: "Taker",
                                     sideText: .previewValue,
                                     token: .previewValue,
                                     logoUrl: URL(string: "https://media.dydx.exchange/currencies/eth.png"))
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let icon = self.createLogo(parentStyle: style)
            let main = self.createMain(parentStyle: style)
            let trailing = self.createTrailing(parentStyle: style)

            return AnyView(
                PlatformTableViewCellViewModel(logo: icon.wrappedViewModel,
                                               main: main.wrappedViewModel,
                                               trailing: trailing.wrappedViewModel,
                                               edgeInsets: EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                .createView(parentStyle: parentStyle)
                .onTapGesture { [weak self] in
                    self?.handler?.onTapAction?()
                }
            )
        }
    }

    private func createLogo(parentStyle: ThemeStyle) -> some View {
        ZStack {
            PlatformIconViewModel(type: .url(url: logoUrl),
                                  clip: .defaultCircle,
                                  size: CGSize(width: 32, height: 32),
                                  backgroundColor: .colorWhite)
            .createView(parentStyle: parentStyle)

            Group {
                OrderStatusModel(status: .green)
                    .createView(parentStyle: parentStyle)
                    .rightAligned()
                    .topAligned()
            }
            .frame(width: 42, height: 42)
        }
        .layoutPriority(1)
    }

    private func createMain(parentStyle: ThemeStyle) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                sideText.createView(parentStyle: parentStyle)
                Text("\(size ?? "") \(token?.symbol ?? "")")
                    .themeColor(foreground: .textPrimary)
                    .themeFont(fontSize: .medium)
            }
            Text(date ?? "")
                .themeColor(foreground: .textTertiary)
                .themeFont(fontSize: .smallest)
        }
        .layoutPriority(1)
    }

    private func createTrailing(parentStyle: ThemeStyle) -> some View {
        HStack {
            VStack(alignment: .trailing, spacing: 2) {
                Text(price ?? "")
                    .themeFont(fontSize: .small)
                    .themeColor(foreground: .textPrimary)
                Text(type ?? "")
                    .themeFont(fontSize: .smaller)
                    .themeColor(foreground: .textTertiary)
            }
            if handler?.onTapAction != nil {
                PlatformIconViewModel(
                    type: .asset(name: "icon_link", bundle: .dydxView),
                    size: .init(width: 16, height: 16),
                    templateColor: .textTertiary
                )
                .createView(parentStyle: parentStyle)
            }
        }
        .minimumScaleFactor(0.5)
    }
}

#if DEBUG
struct SharedFillView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return SharedFillViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct SharedFillView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return SharedFillViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
