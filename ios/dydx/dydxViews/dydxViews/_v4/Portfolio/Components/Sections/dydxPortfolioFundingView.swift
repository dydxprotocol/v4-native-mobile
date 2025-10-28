//
//  dydxPortfolioFundingView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/5/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public enum FundingStatus {
    case earned
    case paid

    var directionText: String {
        switch self {
        case .earned:
            return DataLocalizer.localize(path: "APP.GENERAL.FUNDING_EARNED", params: nil)
        case .paid:
            return DataLocalizer.localize(path: "APP.GENERAL.FUNDING_PAID", params: nil)
        }
    }

    var templateColor: ThemeColor.SemanticColor {
        switch self {
        case .earned:
            return ThemeSettings.positiveColor
        case .paid:
            return  ThemeSettings.negativeColor
        }
    }

    var statusIcon: String {
        switch self {
        case .earned:
            return "icon_funding_earned"
        case .paid:
            return "icon_funding_paid"
        }
    }
}

public class dydxPortfolioFundingItemViewModel: PlatformViewModel {

    public init(amount: SignedAmountViewModel? = nil, rate: SignedAmountViewModel? = nil, time: Date? = nil, sideText: SideTextViewModel = SideTextViewModel(), status: FundingStatus = .paid, position: String? = nil, token: TokenTextViewModel? = TokenTextViewModel(), logoUrl: URL? = nil, onTapAction: (() -> Void)? = nil) {
        self.amount = amount
        self.rate = rate
        self.time = time
        self.sideText = sideText
        self.status = status
        self.position = position
        self.token = token
        self.logoUrl = logoUrl
        self.onTapAction = onTapAction
    }

    public var amount: SignedAmountViewModel?
    public var rate: SignedAmountViewModel?
    public var time: Date?
    public var sideText = SideTextViewModel()
    public var status: FundingStatus = .paid
    public var position: String?
    public var token: TokenTextViewModel?
    public var logoUrl: URL?
    public var onTapAction: (() -> Void)?

    public static var previewValue: dydxPortfolioFundingItemViewModel {
        let item = dydxPortfolioFundingItemViewModel(amount: .previewValue,
                                                     rate: .previewValue,
                                                     time: Date(),
                                                     sideText: .previewValue,
                                                     status: .paid,
                                                     position: "$2300.0",
                                                     token: .previewValue,
                                                     logoUrl: URL(string: "https://media.dydx.exchange/currencies/eth.png")
        )
        return item
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
                                               trailing: trailing.wrappedViewModel)
                .createView(parentStyle: parentStyle)
                .onTapGesture { [weak self] in
                    self?.onTapAction?()
                }
            )
        }
    }

    private func createLogo(parentStyle: ThemeStyle) -> some View {
        let mainIcon = PlatformIconViewModel(type: .url(url: logoUrl), clip: .defaultCircle)
        let overlayIcon = PlatformIconViewModel(type: .asset(name: status.statusIcon, bundle: Bundle.dydxView),
                                                clip: .circle(background: .layer0, spacing: 4),
                                                size: CGSize(width: 12, height: 12),
                                                templateColor: status.templateColor)
        return PlatformOverlayIconViewModel(mainIcon: mainIcon,
                                     overlayIcon: overlayIcon)
        .createView(parentStyle: parentStyle)
    }

    private func createMain(parentStyle: ThemeStyle) -> some View {
        VStack(alignment: .leading) {
            HStack(spacing: 2) {
                Text(position ?? "")
                    .themeColor(foreground: .textPrimary)
                    .themeFont(fontSize: .medium)
                Text(token?.symbol ?? "")
                    .themeColor(foreground: .textPrimary)
                    .themeFont(fontSize: .medium)
                sideText.createView(parentStyle: parentStyle.themeFont(fontSize: .medium))
            }
            Text(time?.englishDatetimeString ?? "")
                .themeColor(foreground: .textTertiary)
                .themeFont(fontSize: .smallest)
        }
    }

    private func createTrailing(parentStyle: ThemeStyle) -> some View {
        VStack(alignment: .trailing) {
            amount?.createView(parentStyle: parentStyle.themeFont(fontType: .number, fontSize: .small))

            rate?.createView(parentStyle: parentStyle.themeFont(fontType: .number, fontSize: .smaller))
        }
    }
}

public class dydxPortfolioFundingViewModel: PlatformListViewModel {
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
            text: DataLocalizer.localize(path: "APP.TRADE.FUNDING_EMPTY_STATE"),
            subText: DataLocalizer.localize(path: "APP.TRADE.FUNDING_SHOW_HERE"),
            icon: .system(name: "xmark.rectangle.portrait.fill"),
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

    public static var previewValue: dydxPortfolioFundingViewModel {
        let vm = dydxPortfolioFundingViewModel()
        vm.items = [
            dydxPortfolioFundingItemViewModel.previewValue,
            dydxPortfolioFundingItemViewModel.previewValue
        ]
        return vm
    }
}

#if DEBUG
struct dydxPortfolioFundingView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxPortfolioFundingViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxPortfolioFundingView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxPortfolioFundingViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
