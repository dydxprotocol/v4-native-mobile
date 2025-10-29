//
//  dydxTakeProfitStopLossStatusViewModel.swift
//  dydxUI
//
//  Created by Michael Maguire on 4/23/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxTakeProfitStopLossStatusViewModel: PlatformViewModel {

    @Published public var triggerPriceText: String?
    @Published public var limitPrice: String?
    @Published public var amount: String?
    @Published public var action: (() -> Void)?
    public let triggerSide: TriggerSide

    public init(triggerSide: TriggerSide, triggerPriceText: String? = nil, limitPrice: String? = nil, amount: String? = nil, action: (() -> Void)? = nil) {
        self.triggerSide = triggerSide
        self.triggerPriceText = triggerPriceText
        self.limitPrice = limitPrice
        self.amount = amount
        self.action = action

    }

    public static var previewValue: dydxTakeProfitStopLossStatusViewModel {
        dydxTakeProfitStopLossStatusViewModel(triggerSide: .stopLoss, triggerPriceText: "0.000001")
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return HStack {
                VStack(alignment: .leading) {
                    Text(DataLocalizer.shared?.localize(path: self.triggerSide.titleStringKey, params: nil) ?? "")
                        .themeColor(foreground: .textTertiary)
                        .themeFont(fontSize: .smaller)
                    Text(self.triggerPriceText ?? "")
                        .themeColor(foreground: .textPrimary)
                        .themeFont(fontSize: .medium)
                }
                Spacer()
                Button(action: self.action ?? {}) {
                    PlatformIconViewModel(
                        type: .system(name: "pencil"),
                        size: .init(width: 12, height: 12),
                        templateColor: .textTertiary
                    ).createView(parentStyle: style)
                }
                .padding(8)
                .border(borderWidth: 1, cornerRadius: 6, borderColor: ThemeColor.SemanticColor.layer3.color)
            }.wrappedInAnyView()
        }
    }
}

#if DEBUG
struct dydxTakeProfitStopLossStatusViewModel_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTakeProfitStopLossStatusViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTakeProfitStopLossStatusViewModel_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTakeProfitStopLossStatusViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif

extension dydxTakeProfitStopLossStatusViewModel {
    public enum TriggerSide {
        case takeProfit, stopLoss

        var titleStringKey: String {
            switch self {
            case .takeProfit:
                return "APP.TRADE.TAKE_PROFIT"
            case .stopLoss:
                return "APP.TRADE.STOP_LOSS"
            }
        }
    }
}
