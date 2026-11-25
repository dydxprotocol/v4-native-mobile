//
//  dydxInjectiveDepositView.swift
//  dydxViews
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxInjectiveDepositViewModel: PlatformViewModel {
    public enum State {
        case empty
        case ready
        case sending
        case failed
        case sent
    }

    @Published public var state: State = .empty
    @Published public var amount: String?
    @Published public var errorMessage: String?
    @Published public var sendAction: (() -> Void)?
    @Published public var doneAction: (() -> Void)?

    public init(state: State = .empty, amount: String? = nil, errorMessage: String? = nil) {
        self.state = state
        self.amount = amount
        self.errorMessage = errorMessage
    }

    public static var previewValue: dydxInjectiveDepositViewModel {
        dydxInjectiveDepositViewModel(state: .ready, amount: "1,250.00")
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformUI.PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _ in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            return dydxInjectiveDepositView(viewModel: self).wrappedInAnyView()
        }
    }
}

private struct dydxInjectiveDepositView: View {
    @ObservedObject var viewModel: dydxInjectiveDepositViewModel

    // TODO(localization): move the copy in this view to v4-localization keys
    private var titleText: String {
        viewModel.state == .sent ? "USDC sent to dYdX" : "Complete your deposit"
    }

    private var bodyText: String {
        switch viewModel.state {
        case .empty:
            return "No USDC is waiting on Injective."
        case .ready, .sending, .failed:
            return "\(viewModel.amount ?? "--") USDC is waiting on Injective. Send it to dYdX to start trading."
        case .sent:
            return "It will reach your trading account in a few moments."
        }
    }

    private var buttonText: String {
        switch viewModel.state {
        case .ready: return "Send USDC to dYdX"
        case .sending: return "Sending…"
        case .failed: return "Try again"
        case .empty, .sent: return "Done"
        }
    }

    private var icon: some View {
        let isError = viewModel.state == .failed
        let name = isError ? "icon_error" : "icon_transfer_deposit"
        return Image(name, bundle: .dydxView)
            .resizable()
            .templateColor(isError ? .colorRed : .colorPurple)
            .scaledToFit()
            .frame(width: 32, height: 32)
            .padding(.all, 20)
            .themeColor(background: .layer3)
            .clipShape(.circle)
    }

    private var button: some View {
        let isSendAction = viewModel.state == .ready || viewModel.state == .failed
        let content = Text(buttonText)
            .themeFont(fontType: .base, fontSize: .medium)
            .themeColor(foreground: viewModel.state == .sending ? .textTertiary : .textPrimary)
        return PlatformButtonViewModel(content: content.wrappedViewModel,
                                       type: .defaultType(),
                                       state: viewModel.state == .sending ? .disabled : .primary,
                                       action: { (isSendAction ? viewModel.sendAction : viewModel.doneAction)?() })
            .createView()
    }

    var body: some View {
        VStack(spacing: 24) {
            icon
            VStack(spacing: 8) {
                Text(titleText)
                    .themeFont(fontType: .plus, fontSize: .largest)
                    .themeColor(foreground: .textPrimary)
                    .multilineTextAlignment(.center)
                Text(bodyText)
                    .themeFont(fontType: .base, fontSize: .small)
                    .themeColor(foreground: .textTertiary)
                    .multilineTextAlignment(.center)
                if viewModel.state == .failed, let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .themeFont(fontType: .base, fontSize: .small)
                        .themeColor(foreground: .colorRed)
                        .multilineTextAlignment(.center)
                }
            }
            button
        }
        .padding(.horizontal, 24)
        .padding(.top, 48)
        .padding(.bottom, max((viewModel.safeAreaInsets?.bottom ?? 0), 24))
        .themeColor(background: .layer4)
        .makeSheet(sheetStyle: .fitSize)
        .ignoresSafeArea(edges: [.bottom])
    }
}

#Preview("Ready") {
    dydxInjectiveDepositViewModel.previewValue.createView()
}

#Preview("Large amount") {
    dydxInjectiveDepositViewModel(state: .ready, amount: "123,456,789.12").createView()
}

#Preview("Sending") {
    dydxInjectiveDepositViewModel(state: .sending, amount: "1.00").createView()
}

#Preview("Failed") {
    dydxInjectiveDepositViewModel(
        state: .failed,
        amount: "1,250.00",
        errorMessage: "Not enough INJ to pay for gas. Send at least 0.00045 INJ to inj17w0adeg64ky0daxwd2ugyuneellmjgnxf5vkec."
    ).createView()
}

#Preview("Sent") {
    dydxInjectiveDepositViewModel(state: .sent, amount: "1,250.00").createView()
}

#Preview("Empty") {
    dydxInjectiveDepositViewModel(state: .empty).createView()
}
