//
//  dydxMarketTileView.swift
//  dydxViews
//
//  Created by Rui Huang on 10/10/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import UIKit
import PlatformUI
import Utilities

public class dydxMarketTilesViewModel: PlatformViewModel {
    @Published public var allTiles: [String] = []
    @Published public var onSelectionChanged: ((Int) -> Void)?

    public init() { }

    public static var previewValue: dydxMarketTilesViewModel = {
        let vm = dydxMarketTilesViewModel()
        vm.allTiles = [
            "Account",
            "Price"
        ]
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return dydxMarketTilesView(
                tiles: allTiles,
                onSelectedTileChange: { tile in
                    if let selectedTileIndex = self.allTiles.firstIndex(of: tile) {
                        self.onSelectionChanged?(selectedTileIndex)
                    }
                },
                selectedTile: allTiles.first ?? ""
            )
            .padding(.horizontal, 16)
            .wrappedInAnyView()
        }
    }
}

struct dydxMarketTilesView: View {
    let tiles: [String]
    let onSelectedTileChange: ((String) -> Void)?

    @State var selectedTile: String

    init(tiles: [String], onSelectedTileChange: ((String) -> Void)?, selectedTile: String) {
        self.tiles = tiles
        self.onSelectedTileChange = onSelectedTileChange
        self.selectedTile = selectedTile
    }

    var body: some View {
        Picker("Market Views", selection: $selectedTile) {
            ForEach(self.tiles, id: \.self) { item in
                Text(item)
                    .themeFont(fontType: .base, fontSize: .small)
                    .tag(item)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: selectedTile, initial: true) { _, new in
            onSelectedTileChange?(new)
        }
    }
}

#if DEBUG
struct dydxMarketTileView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxMarketTilesViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxMarketTileView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxMarketTilesViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
