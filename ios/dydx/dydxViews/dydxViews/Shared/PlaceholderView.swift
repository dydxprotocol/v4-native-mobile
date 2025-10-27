//
//  PlaceholderView.swift
//  dydxViews
//
//  Created by Rui Huang on 9/13/23.
//

import SwiftUI
import PlatformUI
import Utilities

public class PlaceholderViewModel: PlatformViewModel {
    @Published public var text: String?
    @Published public var subText: String?
    @Published public var icon: PlatformIconViewModel.IconType?
    private let useUpdatedStyle: Bool

    public init(
        text: String? = nil,
        subText: String? = nil,
        icon: PlatformIconViewModel.IconType? = nil,
        useUpdatedStyle: Bool = false
    ) {
        self.text = text
        self.subText = subText
        self.icon = icon
        self.useUpdatedStyle = useUpdatedStyle
    }

    public static var previewValue: PlaceholderViewModel {
        let vm = PlaceholderViewModel()
        vm.text = "Test String"
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            if useUpdatedStyle {
                return VStack(alignment: .center) {
                    if let icon = self.icon {
                        PlatformIconViewModel(
                            type: icon,
                            size: .init(width: 24, height: 24),
                            templateColor: .textTertiary
                        )
                            .createView(parentStyle: parentStyle)
                            .opacity(0.75)
                    }
                    Text(self.text ?? "")
                        .themeColor(foreground: .textTertiary)
                        .themeFont(fontType: .plus, fontSize: .small)
                    Text(self.subText ?? "")
                        .themeColor(foreground: .textTertiary)
                        .themeFont(fontSize: .smaller)
                        .opacity(0.75)
                }
                .wrappedInAnyView()
            }

            let main = Text(self.text ?? "")
               .themeFont(fontSize: .small)
               .themeColor(foreground: .textTertiary)
               .centerAligned()
               .frame(maxWidth: .infinity)
               .padding(.vertical, 8)
               .wrappedViewModel

            return AnyView(
                 PlatformTableViewCellViewModel(main: main)
                    .createView(parentStyle: style)
                    .frame(width: UIScreen.main.bounds.width - 32)
                    .themeColor(background: .layer3)
                    .cornerRadius(16)
            )
        }
    }
}

#if DEBUG
struct PlaceHolderView_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return PlaceholderViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct PlaceHolderView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return PlaceholderViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
