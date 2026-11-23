//
//  dydxInjectiveDepositViewBuilder.swift
//  dydxPresenters
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import dydxStateManager
import dydxFormatter
import Combine
import Abacus

public class dydxInjectiveDepositViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let presenter = dydxInjectiveDepositViewPresenter()
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        return dydxInjectiveDepositViewController(presenter: presenter, view: view, configuration: .default) as? T
    }
}

private class dydxInjectiveDepositViewController: HostingViewController<PlatformView, dydxInjectiveDepositViewModel> {
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        request?.path == "/transfer/deposit/injective"
    }
}

private class dydxInjectiveDepositViewPresenter: HostedViewPresenter<dydxInjectiveDepositViewModel> {
    override init() {
        super.init()

        viewModel = dydxInjectiveDepositViewModel()
        viewModel?.sendAction = { [weak self] in
            self?.send()
        }
        viewModel?.doneAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/action/dismiss"), animated: true, completion: nil)
        }
    }

    override func start() {
        super.start()

        AbacusStateManager.shared.state.account
            .map { $0?.injectiveBalances?.usdc ?? 0 }
            .removeDuplicates()
            .sink { [weak self] usdc in
                guard let viewModel = self?.viewModel, viewModel.state != .sending, viewModel.state != .sent else { return }
                viewModel.amount = dydxFormatter.shared.raw(number: NSNumber(value: usdc), digits: 2)
                if viewModel.state != .failed {
                    viewModel.state = usdc > 0 ? .ready : .empty
                }
            }
            .store(in: &subscriptions)
    }

    private func send() {
        viewModel?.state = .sending
        viewModel?.errorMessage = nil
        AbacusStateManager.shared.commitInjectiveDeposit { [weak self] success, error, _ in
            if success {
                self?.viewModel?.state = .sent
                HapticFeedback.shared?.notify(type: .success)
            } else {
                // TODO(localization): show error?.localizedMessage once the gas sponsorship error keys exist
                self?.viewModel?.errorMessage = error?.message ?? "Something went wrong. Please try again."
                self?.viewModel?.state = .failed
                HapticFeedback.shared?.notify(type: .error)
            }
        }
    }
}
