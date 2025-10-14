//
//  dydxSimpleUIFeesViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 19/01/2025.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import Combine
import Abacus
import dydxStateManager
import dydxFormatter

protocol dydxSimpleUIFeesViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxSimpleUIFeesViewModel? { get }
}

class dydxSimpleUIFeesViewPresenter: HostedViewPresenter<dydxSimpleUIFeesViewModel>, dydxSimpleUIFeesViewPresenterProtocol {
    @Published var tradeType: TradeSubmission.TradeType = .trade

    private var tradeSummaryPublisher: AnyPublisher<TradeInputSummary?, Never> {
        $tradeType
            .flatMapLatest { tradeType in
                switch tradeType {
                case .trade:
                    AbacusStateManager.shared.state.tradeInput
                        .map {  $0?.summary }
                        .eraseToAnyPublisher()
                case .closePosition:
                    AbacusStateManager.shared.state.closePositionInput
                        .map {  $0?.summary }
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    override init() {
        super.init()

        viewModel = dydxSimpleUIFeesViewModel()
    }

    override func start() {
        super.start()

        tradeSummaryPublisher
            .sink { [weak self] inputSummary in
                let tradeAmount = abs(inputSummary?.total?.doubleValue ?? 0)
                if tradeAmount > 0 {
                    let tradeFees = inputSummary?.fee?.doubleValue ?? 0
                    let slippage = inputSummary?.slippage?.doubleValue ?? 0
                    let totalFees = tradeFees + slippage
                    self?.viewModel?.totalFees = dydxFormatter.shared.dollar(number: totalFees, digits: 3)
                    let percentage = totalFees / tradeAmount
                    self?.viewModel?.feesPercentage = dydxFormatter.shared.percent(number: percentage, digits: 3)
                    self?.viewModel?.fees = dydxFormatter.shared.dollar(number: tradeFees, digits: 3)
                    self?.viewModel?.slippage = dydxFormatter.shared.dollar(number: slippage, digits: 3)
                } else {
                    self?.viewModel?.totalFees = nil
                    self?.viewModel?.feesPercentage = nil
                    self?.viewModel?.fees = nil
                    self?.viewModel?.slippage = nil
                }
            }
            .store(in: &subscriptions)
    }
}
