//
//  dydxMarketTpSlGroupView.swift
//  dydxUI
//
//  Created by Rui Huang on 16/01/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketTpSlGroupViewModel: PlatformViewModel {
    @Published public var takeProfitStatusViewModel: dydxTakeProfitStopLossStatusViewModel?
    @Published public var stopLossStatusViewModel: dydxTakeProfitStopLossStatusViewModel?
    @Published public var takeProfitStopLossAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxMarketTpSlGroupViewModel {
        let vm = dydxMarketTpSlGroupViewModel()
        vm.takeProfitStatusViewModel = .previewValue
        vm.stopLossStatusViewModel = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            if self.takeProfitStatusViewModel == nil && self.stopLossStatusViewModel == nil {
                return Button(action: takeProfitStopLossAction ?? {}) {
                    HStack {
                        PlatformIconViewModel(
                            type: .system(name: "plus"),
                            size: .init(width: 16, height: 16),
                            templateColor: .textSecondary
                        ).createView()
                        Text(DataLocalizer.localize(path: "APP.TRADE.SET_TAKE_PROFIT_STOP_LOSS_TRIGGERS"))
                            .themeColor(foreground: .textSecondary)
                            .themeFont(fontSize: .small)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .themeColor(background: .layer1)
                .cornerRadius(12, corners: .allCorners)
                .wrappedInAnyView()
            }

            let view =  HStack(spacing: 20) {
                if self.takeProfitStatusViewModel != nil {
                    self.takeProfitStatusViewModel?.createView(parentStyle: style)
                } else {
                    self.createAddButton(
                        label: DataLocalizer.localize(path: "APP.TRADE.TAKE_PROFIT"),
                        buttonLabel: DataLocalizer.localize(path: "APP.TRADE.ADD_TP"),
                        style: style
                    )
                }

                if self.stopLossStatusViewModel != nil {
                    self.stopLossStatusViewModel?.createView(parentStyle: parentStyle)
                } else {
                    self.createAddButton(
                        label: DataLocalizer.localize(path: "APP.TRADE.STOP_LOSS"),
                        buttonLabel: DataLocalizer.localize(path: "APP.TRADE.ADD_SL"),
                        style: style
                    )
                }
            }
                .frame(maxHeight: .infinity)

            return AnyView(view)
        }
    }

    private func createAddButton(label: String, buttonLabel: String, style: ThemeStyle) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(label)
                    .themeColor(foreground: .textTertiary)
                    .themeFont(fontSize: .smaller)
                Text("--")
                    .themeColor(foreground: .textTertiary)
                    .themeFont(fontSize: .smaller)
            }
            Spacer()
            Button(action: takeProfitStopLossAction ?? {}) {
                HStack {
                    PlatformIconViewModel(
                        type: .system(name: "plus"),
                        size: .init(width: 12, height: 12),
                        templateColor: .textTertiary
                    ).createView(parentStyle: style)
                    Text(buttonLabel)
                        .themeColor(foreground: .textTertiary)
                        .themeFont(fontSize: .smaller)
                }
            }
            .padding(8)
            .border(borderWidth: 1, cornerRadius: 6, borderColor: ThemeColor.SemanticColor.layer3.color)
        }
    }
}

#if DEBUG
struct dydxMarketTpSlGroupView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketTpSlGroupViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketTpSlGroupView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketTpSlGroupViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
