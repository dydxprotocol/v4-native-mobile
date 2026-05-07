//
//  dydxProfileRewardsViewPresenter.swift
//  dydxPresenters
//
//  Created by Rui Huang on 9/18/23.
//

import Utilities
import dydxViews
import ParticlesKit
import PlatformUI

public protocol dydxProfileRewardsViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxProfileRewardsViewModel? { get }
}

public class dydxProfileRewardsViewPresenter: HostedViewPresenter<dydxProfileRewardsViewModel>, dydxProfileRewardsViewPresenterProtocol {
    private static let liquidationRebatesUrl = "https://dydx.trade/DYDX"

    override init() {
        super.init()

        viewModel = dydxProfileRewardsViewModel()
        viewModel?.tapAction = { [weak self] in
            self?.openLiquidationRebatesUrl()
        }
    }

    private func openLiquidationRebatesUrl() {
        guard let url = URL(string: Self.liquidationRebatesUrl),
              URLHandler.shared?.canOpenURL(url) ?? false else {
            return
        }
        URLHandler.shared?.open(url, completionHandler: nil)
    }
}
