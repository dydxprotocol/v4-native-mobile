//
//  dydxPortfolioOrdersView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/5/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import dydxFormatter

public class dydxPortfolioOrderItemViewModel: PlatformViewModel {

    public struct Handler: Hashable {
        public static func == (lhs: Handler, rhs: Handler) -> Bool {
            true
        }

        public func hash(into hasher: inout Hasher) { }

        public var onTapAction: (() -> Void)?
        public var onCloseAction: (() -> Void)?
    }

    @Published public var id: String?
    @Published public var date: Date?
    @Published public var status: String?
    @Published public var canCancel: Bool = false
    @Published public var orderStatus = OrderStatusModel()
    @Published public var sideText = SideTextViewModel()
    @Published public var type: String?
    @Published public var size: String?
    @Published public var filledSize: String?
    @Published public var price: String?
    @Published public var triggerPrice: String?
    @Published public var token: TokenTextViewModel?
    @Published public var logoUrl: URL?
    @Published public var handler: Handler?

    public init(id: String? = nil, date: Date? = nil, status: String? = nil, canCancel: Bool = false, orderStatus: OrderStatusModel = OrderStatusModel(), sideText: SideTextViewModel = SideTextViewModel(), type: String? = nil, size: String? = nil, filledSize: String? = nil, price: String? = nil, triggerPrice: String? = nil, token: TokenTextViewModel? = nil, logoUrl: URL? = nil, onTapAction: (() -> Void)? = nil) {
        self.id = id
        self.date = date
        self.status = status
        self.canCancel = canCancel
        self.orderStatus = orderStatus
        self.sideText = sideText
        self.type = type
        self.size = size
        self.filledSize = filledSize
        self.price = price
        self.triggerPrice = triggerPrice
        self.token = token
        self.logoUrl = logoUrl
        self.handler = Handler(onTapAction: onTapAction)
    }

    public static var previewValue: dydxPortfolioOrderItemViewModel {
        let vm = dydxPortfolioOrderItemViewModel(
            id: "id",
            status: "Open",
            orderStatus: .previewValue,
            sideText: .previewValue,
            type: "Market Order",
            size: "200",
            filledSize: "100",
            price: "$12.00",
            token: .previewValue,
            logoUrl: URL(string: "https://media.dydx.exchange/currencies/eth.png"))
        return vm
    }

    private func headerView(style: ThemeStyle = ThemeStyle.defaultStyle) -> some View {
        HStack(spacing: 8) {
            Text(DataLocalizer.localize(path: "APP.TRADE.LIMIT_ORDER"))
                .themeColor(foreground: .textPrimary)
                .themeFont(fontSize: .small)
            self.sideText.createView(parentStyle: style.themeFont(fontSize: .small))
            Spacer()
            HStack(spacing: 16) {
                PlatformButtonViewModel(
                    content: PlatformIconViewModel(
                        type: .system(name: "pencil"),
                        size: .init(width: 16, height: 16),
                        templateColor: .textTertiary
                    ),
                    type: .iconType,
                    action: self.handler?.onTapAction ?? {}
                ).createView(parentStyle: style)
                PlatformButtonViewModel(
                    content: PlatformIconViewModel(
                        type: .system(name: "xmark"),
                        size: .init(width: 16, height: 16),
                        templateColor: .colorRed
                    ),
                    type: .iconType,
                    action: self.handler?.onCloseAction ?? {}
                ).createView(parentStyle: style)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            Rectangle()
                .frame(maxWidth: .infinity, minHeight: 2, maxHeight: 2)
                .themeColor(foreground: .layer2)
        }
    }

    private func detailView<Content: View>(_ labelKey: String, _ value: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(DataLocalizer.localize(path: labelKey))
                .themeColor(foreground: .textTertiary)
                .themeFont(fontSize: .smaller)
            value()
        }
    }

    private func orderDetailsView(style: ThemeStyle = ThemeStyle.defaultStyle) -> some View {
        HStack(alignment: .center, spacing: 16) {
            detailView("APP.TRADE.LIMIT_PRICE") {
                Text(triggerPrice ?? "")
                    .themeColor(foreground: .textPrimary)
                    .themeFont(fontSize: .medium)
            }
            detailView("APP.TRADE.ORDERBOOK_ORDER_SIZE") {
                Text("\(size ?? "") \(token?.symbol ?? "")")
                    .themeColor(foreground: .textPrimary)
                    .themeFont(fontSize: .medium)
            }
            detailView("APP.TRADE.AMOUNT_FILLED") {
                HStack {
                    Text(filledSize ?? "")
                        .themeColor(foreground: .textPrimary)
                        .themeFont(fontSize: .medium)
                    orderStatus.createView()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return VStack(alignment: .leading) {
                self.headerView(style: style)
                self.orderDetailsView(style: style)
            }
            .themeColor(background: .layer1)
            .cornerRadius(16, corners: .allCorners)
            .wrappedInAnyView()
        }
    }
}

public class dydxPortfolioOrdersViewModel: PlatformListViewModel {
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
            text: DataLocalizer.localize(path: "APP.TRADE.ORDER_EMPTY_STATE"),
            subText: DataLocalizer.localize(path: "APP.TRADE.ORDER_SHOW_HERE"),
            icon: .system(name: "square.stack.fill"),
            useUpdatedStyle: true
        )
    }

    public init(items: [PlatformViewModel] = [], contentChanged: (() -> Void)? = nil) {
        super.init(items: items,
                   intraItemSeparator: false,
                   firstListItemTopSeparator: false,
                   lastListItemBottomSeparator: false,
                   contentChanged: contentChanged)
    }

    public static var previewValue: dydxPortfolioOrdersViewModel {
        let vm = dydxPortfolioOrdersViewModel()
        vm.items = [
            dydxPortfolioOrderItemViewModel.previewValue,
            dydxPortfolioOrderItemViewModel.previewValue
        ]
        return vm
    }
}

#if DEBUG
struct dydxPortfolioOrdersView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return ScrollView(showsIndicators: false) {
            LazyVStack(pinnedViews: [.sectionHeaders]) {
                dydxPortfolioOrdersViewModel.previewValue
                    .createView()
            }
            .previewLayout(.sizeThatFits)
        }
    }
}

struct dydxPortfolioOrdersView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return ScrollView(showsIndicators: false) {
            LazyVStack(pinnedViews: [.sectionHeaders]) {
                dydxPortfolioOrdersViewModel.previewValue
                    .createView()
            }
            .previewLayout(.sizeThatFits)
        }
    }
}
#endif
