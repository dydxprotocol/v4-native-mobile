package exchange.dydx.dydxCartera.walletprovider.userconsent

import exchange.dydx.dydxCartera.walletprovider.WalletTransactionRequest
import exchange.dydx.dydxCartera.walletprovider.WalletUserConsentCompletion
import exchange.dydx.dydxCartera.walletprovider.WalletUserConsentProtocol
import exchange.dydx.dydxCartera.walletprovider.WalletUserConsentStatus

class SkippedWalletUserConsent : WalletUserConsentProtocol {
    override fun showTransactionConsent(request: WalletTransactionRequest, completion: WalletUserConsentCompletion?) {
        completion?.invoke(WalletUserConsentStatus.CONSENTED)
    }
}
