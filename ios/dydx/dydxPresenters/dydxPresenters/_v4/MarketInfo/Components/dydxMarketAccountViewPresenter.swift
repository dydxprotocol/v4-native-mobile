//
//  dydxMarketAccountViewPresenter.swift
//  dydxPresenters
//
//  Created by Sam Newby on 2025-10-24.
//

import dydxViews
import RoutingKit

protocol dydxMarketAccountViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxMarketAccountViewModel? { get }
}

class dydxMarketAccountPresenter: HostedViewPresenter<dydxMarketAccountViewModel>, dydxMarketAccountViewPresenterProtocol {
    private let sharedAccountPresenter = SharedAccountPresenter()

    override init() {
        let viewModel = dydxMarketAccountViewModel()

        sharedAccountPresenter.$viewModel.assign(to: &viewModel.$sharedAccountViewModel)

        super.init()

        self.viewModel = viewModel

        viewModel.depositAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/transfer/deposit", params: nil), animated: true, completion: nil)
        }
    }

    override func start() {
        super.start()

        sharedAccountPresenter.start()
    }
}
