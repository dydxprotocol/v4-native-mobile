//
//  dydxMarketPositionView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/11/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketPositionViewModel: PlatformViewModel {
    @Published public var closeAction: (() -> Void)?
    @Published public var editMarginAction: (() -> Void)?
    @Published public var onboardAction: (() -> Void)?

    @Published public var isSignedIn: Bool = false
    @Published public var hasOpenPosition: Bool = false

    @Published public var unrealizedPNLAmount: SignedAmountViewModel?
    @Published public var unrealizedPNLPercent: String = ""
    @Published public var realizedPNLAmount: SignedAmountViewModel?
    @Published public var marginMode: String?
    @Published public var margin: String?
    @Published public var leverage: String?
    @Published public var leverageIcon: LeverageRiskModel?
    @Published public var liquidationPrice: String?
    @Published public var side: SideTextViewModel?
    @Published public var size: String?
    @Published public var amount: String?
    @Published public var token: TokenTextViewModel?
    @Published public var logoUrl: URL?
    @Published public var gradientType: GradientType = .none

    @Published public var openPrice: String?
    @Published public var closePrice: String?
    @Published public var funding: SignedAmountViewModel?

    @Published public var tpSlGroupViewModel: dydxMarketTpSlGroupViewModel?

    @Published public var pendingPosition: dydxPortfolioPendingPositionsItemViewModel? {
        didSet {
            contentChanged?()
        }
    }

    @Published public var contentChanged: (() -> Void)?

    let columns = [GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading)]

    public init() { }

    public static var previewValue: dydxMarketPositionViewModel {
        let vm = dydxMarketPositionViewModel()
        vm.closeAction = {}
        vm.unrealizedPNLAmount = .previewValue
        vm.unrealizedPNLPercent = "10%"
        vm.realizedPNLAmount = .previewValue
        vm.marginMode = "Cross"
        vm.margin = "$10"
        vm.leverage = "$12.00"
        vm.leverageIcon = .previewValue
        vm.liquidationPrice = "$12.00"
        vm.side = .previewValue
        vm.size = "0.0012"
        vm.amount = "$120.00"
        vm.token = .previewValue
        vm.logoUrl = URL(string: "https://media.dydx.exchange/currencies/eth.png")
        vm.gradientType = .plus
        vm.openPrice = "$12.00"
        vm.closePrice = "$12.00"
        vm.funding = .previewValue
        return vm
    }

    private var closeButton: any View {
        if let closeAction = self.closeAction {
            return Button(
                action: closeAction,
                label: {
                    HStack {
                        PlatformIconViewModel(
                            type: .system(name: "xmark"),
                            size: .init(width: 12, height: 12),
                            templateColor: .colorRed
                        )
                            .createView()
                        Text(DataLocalizer.localize(path: "APP.GENERAL.CLOSE"))
                            .themeColor(foreground: .colorRed)
                            .themeFont(fontSize: .small)
                    }
                }
            )
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(ThemeColor.SemanticColor.colorRed.color.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        } else {
            return EmptyView()
        }
    }

    private func headerText(_ textKey: String) -> Text {
        Text(DataLocalizer.localize(path: textKey))
            .themeColor(foreground: .textTertiary)
            .themeFont(fontSize: .smaller)
    }

    private func valueText(_ text: String?) -> Text {
        Text(text ?? "-")
            .themeColor(foreground: .textPrimary)
            .themeFont(fontSize: .medium)
    }

    private func defaultStat(_ textKey: String, _ value: String?) -> some View {
        defaultStat(headerText(textKey), valueText(value))
    }

    private func defaultStat<Header: View, Value: View>(_ header: Header, _ value: Value) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            header
            value
        }
    }

    private func createCollection(parentStyle: ThemeStyle) -> some View {
        VStack(spacing: 16) {
            LazyVGrid(columns: columns, spacing: 16) {
                let leverageHeader = HStack {
                    headerText("APP.GENERAL.LEVERAGE")
                    side?.createView(
                        parentStyle: parentStyle.themeFont(fontType: .plus, fontSize: .smallest)
                    )
                }
                defaultStat(leverageHeader, valueText(leverage))
                closeButton
                    .wrappedInAnyView()
                defaultStat("APP.GENERAL.VALUE", amount)
                defaultStat("APP.GENERAL.SIZE", "\(size ?? "-") \(token?.symbol ?? "")")
                defaultStat(headerText("APP.TRADE.UNREALIZED_PNL"), unrealizedPNLAmount?.createView().themeFont(fontSize: .medium))
                defaultStat(headerText("APP.TRADE.REALIZED_PNL"), realizedPNLAmount?.createView().themeFont(fontSize: .medium))
                let marginHeader = HStack {
                    headerText("APP.GENERAL.MARGIN")
                    Text(marginMode ?? "")
                        .themeColor(foreground: .textSecondary)
                        .themeFont(fontType: .plus, fontSize: .smallest)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .border(borderWidth: 1, cornerRadius: 6, borderColor: ThemeColor.SemanticColor.layer4.color)
                }
                defaultStat(marginHeader, valueText(margin))
                defaultStat("APP.TRADE.LIQUIDATION", liquidationPrice)
                defaultStat("APP.GENERAL.AVG_ENTRY", openPrice)
                defaultStat("APP.TRADE.AVG_CLOSE", closePrice)
                defaultStat(headerText("APP.TRADE.FUNDING_PAYMENTS_SHORT"), funding?.createView().themeFont(fontSize: .medium))
            }
        }
    }

    private func createPendingPositionsHeader(parentStyle: ThemeStyle) -> some View {
        Text(localizerPathKey: "APP.TRADE.UNOPENED_ISOLATED_POSITIONS")
            .themeFont(fontSize: .larger)
            .themeColor(foreground: .textSecondary)
            .leftAligned()
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            guard self.isSignedIn else {
                return PlatformButtonViewModel(
                    content: Text(DataLocalizer.localize(path: "APP.GENERAL.SIGN_IN_TO_VIEW")).wrappedViewModel,
                    action: { self.onboardAction?() }
                )
                .createView(parentStyle: parentStyle)
                .frame(width: UIScreen.main.bounds.width - 16)
                .wrappedInAnyView()
            }

            return AnyView(
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        if !self.hasOpenPosition {
                            PlaceholderViewModel(
                                text: DataLocalizer.localize(path: "APP.TRADE.POSITIONS_EMPTY_STATE"),
                                subText: DataLocalizer.localize(path: "APP.TRADE.POSITIONS_SHOW_HERE"),
                                icon: .asset(name: "circle_stack", bundle: .dydxView),
                                useUpdatedStyle: true
                            )
                                .createView()
                                .padding(.vertical, 20)
                        } else {
                            self.createCollection(parentStyle: style)
                            self.tpSlGroupViewModel?.createView(parentStyle: parentStyle)
                        }
                    }

                    if let pendingPosition = self.pendingPosition {
                        VStack(spacing: 16) {
                            self.createPendingPositionsHeader(parentStyle: style)
                            pendingPosition.createView(parentStyle: style)
                        }
                    }
                }
                .themeColor(background: .layer2)
                .frame(width: UIScreen.main.bounds.width - 32)
            )
        }
    }
}

#if DEBUG
struct dydxMarketPositionView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketPositionViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketPositionView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketPositionViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
