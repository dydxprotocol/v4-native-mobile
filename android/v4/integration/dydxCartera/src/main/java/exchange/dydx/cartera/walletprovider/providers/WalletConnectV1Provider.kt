package exchange.dydx.dydxCartera.walletprovider.providers

import android.net.Uri
import exchange.dydx.dydxCartera.typeddata.WalletTypedDataProviderProtocol
import exchange.dydx.dydxCartera.walletprovider.EthereumAddChainRequest
import exchange.dydx.dydxCartera.walletprovider.WalletConnectCompletion
import exchange.dydx.dydxCartera.walletprovider.WalletConnectedCompletion
import exchange.dydx.dydxCartera.walletprovider.WalletOperationCompletion
import exchange.dydx.dydxCartera.walletprovider.WalletOperationProviderProtocol
import exchange.dydx.dydxCartera.walletprovider.WalletOperationStatus
import exchange.dydx.dydxCartera.walletprovider.WalletRequest
import exchange.dydx.dydxCartera.walletprovider.WalletStatusDelegate
import exchange.dydx.dydxCartera.walletprovider.WalletStatusImp
import exchange.dydx.dydxCartera.walletprovider.WalletStatusProtocol
import exchange.dydx.dydxCartera.walletprovider.WalletTransactionRequest
import exchange.dydx.dydxCartera.walletprovider.WalletUserConsentProtocol

class WalletConnectV1Provider : WalletOperationProviderProtocol {
    private var _walletStatus = WalletStatusImp()
        set(value) {
            field = value
            walletStatusDelegate?.statusChanged(value)
        }

    override val walletStatus: WalletStatusProtocol?
        get() = _walletStatus

    override var walletStatusDelegate: WalletStatusDelegate? = null
    override var userConsentDelegate: WalletUserConsentProtocol? = null

    override fun handleResponse(uri: Uri): Boolean {
        return false
    }

    override fun connect(request: WalletRequest, completion: WalletConnectCompletion) {
    }

    override fun disconnect() {
    }

    override fun signMessage(
        request: WalletRequest,
        message: String,
        connected: WalletConnectedCompletion?,
        status: WalletOperationStatus?,
        completion: WalletOperationCompletion
    ) {
        TODO("Not yet implemented")
    }

    override fun sign(
        request: WalletRequest,
        typedDataProvider: WalletTypedDataProviderProtocol?,
        connected: WalletConnectedCompletion?,
        status: WalletOperationStatus?,
        completion: WalletOperationCompletion
    ) {
        TODO("Not yet implemented")
    }

    override fun send(
        request: WalletTransactionRequest,
        connected: WalletConnectedCompletion?,
        status: WalletOperationStatus?,
        completion: WalletOperationCompletion
    ) {
        TODO("Not yet implemented")
    }

    override fun addChain(
        request: WalletRequest,
        chain: EthereumAddChainRequest,
        connected: WalletConnectedCompletion?,
        status: WalletOperationStatus?,
        completion: WalletOperationCompletion
    ) {
        TODO("Not yet implemented")
    }
}
