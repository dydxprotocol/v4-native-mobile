//
//  dydxMarketInfoPagingViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 10/10/22.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Combine
import dydxStateManager
import Abacus

protocol dydxMarketInfoPagingViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxMarketInfoPagingViewModel? { get }
}

class dydxMarketInfoPagingViewPresenter: HostedViewPresenter<dydxMarketInfoPagingViewModel>, dydxMarketInfoPagingViewPresenterProtocol {
    @Published var marketId: String?

    private let accountPresenter = SharedAccountPresenter()
    private let candlesViewPresenter = dydxMarketPriceCandlesViewPresenter()
    private let depthViewPresenter = dydxMarketDepthChartViewPresenter()
    private let fundingViewPresenter = dydxMarketFundingChartViewPresenter()
    private let tradesViewPresenter = dydxMarketTradesViewPresenter()
    private let orderbookPresenter = dydxMarketOrderbookPresenter()

    private lazy var childPresenters: [TileType: HostedViewPresenterProtocol] = [
        .price: candlesViewPresenter,
        .depth: depthViewPresenter,
        .recent: tradesViewPresenter,
        .funding: fundingViewPresenter
    ]

    private var tiles: [MarketInfoPagingTile] {
        [
            MarketInfoPagingTile(type: .price, text: DataLocalizer.localize(path: "APP.GENERAL.PRICE_CHART_SHORT")),
            MarketInfoPagingTile(type: .depth, text: DataLocalizer.localize(path: "APP.GENERAL.DEPTH_CHART_SHORT")),
            MarketInfoPagingTile(type: .recent, text: DataLocalizer.localize(path: "APP.TRADE.TRADES")),
            MarketInfoPagingTile(type: .funding, text: DataLocalizer.localize(path: "APP.GENERAL.FUNDING_RATE_CHART_SHORT"))
        ]
        .filterNils()
    }

    override init() {
        let viewModel = dydxMarketInfoPagingViewModel()

        // Account
        accountPresenter.$viewModel.assign(to: &viewModel.account.$sharedAccountViewModel)
        // Candle
        candlesViewPresenter.$viewModel.assign(to: &viewModel.$priceCandles)
        // Depth
        depthViewPresenter.$viewModel.assign(to: &viewModel.$depth)
        // Funding
        fundingViewPresenter.$viewModel.assign(to: &viewModel.$funding)
        // Trades
        tradesViewPresenter.$viewModel.assign(to: &viewModel.$trades)
        // Orderbook
        orderbookPresenter.$viewModel.assign(to: &viewModel.$orderbook)

        super.init()

        self.viewModel = viewModel

        updateTiles()
    }

    override func start() {
        super.start()

        accountPresenter.start()

        $marketId
            .sink { [weak self] marketId in
                self?.candlesViewPresenter.marketId = marketId
                self?.depthViewPresenter.marketId = marketId
                self?.fundingViewPresenter.marketId = marketId
                self?.tradesViewPresenter.marketId = marketId
                self?.orderbookPresenter.marketId = marketId
            }
            .store(in: &subscriptions)

        resetPresentersForVisibilityChange()
    }

    private func resetPresentersForVisibilityChange() {
        for presenter in childPresenters {
            if presenter.key == viewModel?.tileSelection {
                presenter.value.start()
            } else {
                presenter.value.stop()
            }
        }
    }

    private func updateTiles() {
        // Tiles
        viewModel?.tiles.allTiles = tiles.map { $0.text }
        viewModel?.tileSelection = .price
        viewModel?.tiles.onSelectionChanged = { [weak self] index in
            guard let tile = self?.tiles[index] else {
                return
            }
            self?.viewModel?.tileSelection = tile.type
            self?.resetPresentersForVisibilityChange()
        }
        self.resetPresentersForVisibilityChange()
    }
}

// MARK: Tiles

private struct MarketInfoPagingTile {
    let type: TileType
    let text: String
}
