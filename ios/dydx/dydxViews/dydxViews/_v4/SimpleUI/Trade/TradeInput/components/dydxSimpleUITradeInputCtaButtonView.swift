//
//  dydxSimpleUITradeInputCtaButtonView.swift
//  dydxUI
//
//  Created by Rui Huang on 17/01/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxSimpleUITradeInputCtaButtonView: PlatformViewModel {
    public enum State {
        case enabled(String? = nil)
        case slider
        case disabled(String? = nil)

        var buttonDisabled: Bool {
            switch self {
            case .enabled: return false
            case .slider: return false
            case .disabled: return true
            }
        }
    }

    @Published public var ctaAction: (() -> Void)?
    @Published public var state: State = .disabled()
    @Published public var side: AppOrderSide = .BUY
    @Published public var isClosePosition: Bool = false

    public init() { }

    public static var previewValue: dydxSimpleUITradeInputCtaButtonView {
        let vm = dydxSimpleUITradeInputCtaButtonView()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let buttonType = PlatformButtonType.defaultType(
                fillWidth: true,
                pilledCorner: false,
                minHeight: 60,
                cornerRadius: 16)

            let buttonText: String?
            let sideColor: Color

            switch state {
            case .enabled(let text):
                buttonText = text
                sideColor = ThemeColor.SemanticColor.textTertiary.color
            case .slider:
                if isClosePosition {
                    sideColor = ThemeColor.SemanticColor.colorPurple.color
                    buttonText = DataLocalizer.localize(path: "APP.TRADE.SLIDE_TO_CLOSE")
                } else {
                    switch side {
                    case .BUY:
                        sideColor = Color(uiColor: UIColor(hex: "2CCC98")!)
                        buttonText = DataLocalizer.localize(path: "APP.TRADE.SLIDE_TO_BUY")
                    case .SELL:
                        sideColor = Color(uiColor: UIColor(hex: "E45555")!)
                        buttonText = DataLocalizer.localize(path: "APP.TRADE.SLIDE_TO_SELL")
                    default:
                        return AnyView(PlatformView.nilView)
                    }
                }
            case .disabled(let text):
                buttonText = text
                sideColor = ThemeColor.SemanticColor.textTertiary.color
            }

            if case .enabled(let text) = state {
                let buttonText = text ?? DataLocalizer.localize(path: "APP.TRADE.PREVIEW")
                let buttonContent =
                Text(buttonText)
                    .themeFont(fontType: .plus, fontSize: .medium)
                    .wrappedViewModel

                let view = PlatformButtonViewModel(content: buttonContent,
                                                   type: buttonType,
                                                   state: .primary) { [weak self] in
                    PlatformView.hideKeyboard()
                    self?.ctaAction?()
                }
                    .createView(parentStyle: style)
                return AnyView(view)

            } else if case .disabled = state {
                let buttonContent = Text(buttonText ?? DataLocalizer.localize(path: "APP.TRADE.ENTER_AMOUNT"))
                    .themeFont(fontType: .plus, fontSize: .medium)
                    .wrappedViewModel
                let view = PlatformButtonViewModel(content: buttonContent,
                                                   type: buttonType,
                                                   state: .disabled) {
                }
                    .createView(parentStyle: style)
                return AnyView(view)

            } else {
                let view = Group {
                    let styling = SlideButtonStyling(
                        indicatorSize: 60,
                        indicatorSpacing: 5,
                        indicatorColor: sideColor,
                        indicatorShape: .rectangular(cornerRadius: 16),
                        backgroundColor: sideColor.opacity(0.3),
                        textColor: sideColor,
                        indicatorImageOverride: Image("icon_slider_indicator", bundle: Bundle.dydxView),
                        textAlignment: .globalCenter,
                        textFadesOpacity: true,
                        textHiddenBehindIndicator: true,
                        textShimmers: true
                    )

                    SlideButton(styling: styling, action: {
                        DispatchQueue.main.async { [weak self] in
                            self?.ctaAction?()
                        }
                    }, label: {
                        Text(buttonText ?? "")
                            .themeFont(fontType: .plus, fontSize: .medium)
                    })
                    .disabled(self.state.buttonDisabled)
                }

                return AnyView(view)
            }
        }
    }
}

#if DEBUG
struct dydxSimpleUICtaButtonView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUITradeInputCtaButtonView.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxSimpleUICtaButtonView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxSimpleUITradeInputCtaButtonView.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
