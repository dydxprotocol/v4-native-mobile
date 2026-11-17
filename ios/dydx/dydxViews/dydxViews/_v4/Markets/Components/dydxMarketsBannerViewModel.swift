//
//  dydxMarketsHeaderView.swift
//  dydxViews
//
//  Created by Rui Huang on 9/1/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxMarketsBannerViewModel: PlatformViewModel {
    public var text: String
    public var linkText: String?
    public var navigationAction: (() -> Void)

    static var previewValue: dydxMarketsBannerViewModel = {
        let vm = dydxMarketsBannerViewModel(text: "Upcoming USDC migration from Noble to Injective.",
                                            linkText: "Learn more",
                                            navigationAction: {})
        return vm
    }()

    public init(text: String, linkText: String? = nil, navigationAction: @escaping (() -> Void)) {
        self.text = text
        self.linkText = linkText
        self.navigationAction = navigationAction
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _ in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            return dydxMarketsBannerView(viewModel: self)
                .wrappedInAnyView()
        }
    }
}

private struct dydxMarketsBannerView: View {
    var viewModel: dydxMarketsBannerViewModel

    private var message: Text {
        let text = Text(viewModel.text)
            .foregroundColor(ThemeColor.SemanticColor.textPrimary.color)
        guard let linkText = viewModel.linkText else { return text }
        return text + Text(" ") + Text(linkText)
            .foregroundColor(ThemeColor.SemanticColor.colorPurple.color)
    }

    var body: some View {
        Button(action: viewModel.navigationAction) {
            HStack(alignment: .top, spacing: 8) {
                PlatformIconViewModel(type: .asset(name: "icon_info", bundle: .dydxView),
                                      clip: .noClip,
                                      size: .init(width: 16, height: 16),
                                      templateColor: .colorPurple)
                    .createView()
                message
                    .themeFont(fontType: .base, fontSize: .small)
                    .multilineTextAlignment(.leading)
                    .leftAligned()
            }
            .padding(.leading, 20)
            .padding(.trailing, 16)
            .padding(.vertical, 12)
            .themeColor(background: .layer1)
            .overlay(alignment: .leading) {
                ThemeColor.SemanticColor.colorPurple.color
                    .frame(width: 4)
            }
            .clipShape(.rect(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
