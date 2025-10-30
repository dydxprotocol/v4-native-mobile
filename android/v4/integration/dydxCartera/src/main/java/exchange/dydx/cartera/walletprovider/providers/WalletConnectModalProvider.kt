package exchange.dydx.dydxCartera.walletprovider.providers

import android.app.Application
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import androidx.navigation.NavHostController
import com.reown.appkit.client.AppKit
import com.reown.appkit.client.Modal
import com.reown.appkit.client.models.request.SentRequestResult
import com.reown.appkit.presets.AppKitChainsPresets
import com.reown.appkit.presets.AppKitChainsPresets.ethToken
import com.reown.appkit.ui.openAppKit
import com.reown.appkit.utils.EthUtils
import exchange.dydx.dydxCartera.CarteraErrorCode
import exchange.dydx.dydxCartera.entities.Wallet
import exchange.dydx.dydxCartera.entities.toJsonRequest
import exchange.dydx.dydxCartera.tag
import exchange.dydx.dydxCartera.typeddata.WalletTypedDataProviderProtocol
import exchange.dydx.dydxCartera.typeddata.typedDataAsString
import exchange.dydx.dydxCartera.walletprovider.EthereumAddChainRequest
import exchange.dydx.dydxCartera.walletprovider.WalletConnectCompletion
import exchange.dydx.dydxCartera.walletprovider.WalletConnectedCompletion
import exchange.dydx.dydxCartera.walletprovider.WalletError
import exchange.dydx.dydxCartera.walletprovider.WalletInfo
import exchange.dydx.dydxCartera.walletprovider.WalletOperationCompletion
import exchange.dydx.dydxCartera.walletprovider.WalletOperationProviderProtocol
import exchange.dydx.dydxCartera.walletprovider.WalletOperationStatus
import exchange.dydx.dydxCartera.walletprovider.WalletRequest
import exchange.dydx.dydxCartera.walletprovider.WalletState
import exchange.dydx.dydxCartera.walletprovider.WalletStatusDelegate
import exchange.dydx.dydxCartera.walletprovider.WalletStatusImp
import exchange.dydx.dydxCartera.walletprovider.WalletStatusProtocol
import exchange.dydx.dydxCartera.walletprovider.WalletTransactionRequest
import exchange.dydx.dydxCartera.walletprovider.WalletUserConsentProtocol
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import timber.log.Timber

class WalletConnectModalProvider(
    private val application: Application,
) : WalletOperationProviderProtocol, AppKit.ModalDelegate {

    private var _walletStatus = WalletStatusImp()
        set(value) {
            field = value
            walletStatusDelegate?.statusChanged(value)
        }
    override val walletStatus: WalletStatusProtocol
        get() = _walletStatus

    override var walletStatusDelegate: WalletStatusDelegate? = null
    override var userConsentDelegate: WalletUserConsentProtocol? = null

    private var requestingWallet: WalletRequest? = null
    private var currentSession: Modal.Model.ApprovedSession.WalletConnectSession? = null

    private val connectCompletions: MutableList<WalletConnectCompletion> = mutableListOf()
    private val operationCompletions: MutableMap<String, WalletOperationCompletion> = mutableMapOf()

    // expiry must be between current timestamp + MIN_INTERVAL and current timestamp + MAX_INTERVAL (MIN_INTERVAL: 300, MAX_INTERVAL: 604800)
    private val requestExpiry: Long
        get() = (System.currentTimeMillis() / 1000) + 400

    private val ethNamespace = "eip155" // only support eth for now

    var nav: NavHostController? = null

    override fun handleResponse(uri: Uri): Boolean {
        return false
    }

    override fun connect(request: WalletRequest, completion: WalletConnectCompletion) {
        if (_walletStatus.state == WalletState.CONNECTED_TO_WALLET) {
            completion(walletStatus.connectedWallet, null)
        } else {
            requestingWallet = request

            if (request.chainId != null) {
                val testnetChain = Modal.Model.Chain(
                    chainName = "Ethereum",
                    chainNamespace = "eip155",
                    chainReference = request.chainId,
                    requiredMethods = EthUtils.ethRequiredMethods,
                    optionalMethods = EthUtils.ethOptionalMethods,
                    events = EthUtils.ethEvents,
                    token = ethToken,
                )
                AppKit.setChains(listOf(testnetChain))
            } else {
                AppKit.setChains(AppKitChainsPresets.ethChains.values.toList())
            }

            AppKit.setDelegate(this)

            connectCompletions.add(completion)

            nav?.openAppKit()
        }
    }

    override fun disconnect() {
        val currentSession = this.currentSession
        if (currentSession != null) {
            AppKit.disconnect(onSuccess = {
                Timber.tag(tag(this)).d("Disconnected from session ")
            }, onError = {
                Timber.tag(tag(this)).e(it.message)
            })
            this.currentSession = null
        }

        _walletStatus.state = WalletState.IDLE
        _walletStatus.connectedWallet = null
        _walletStatus.connectionDeeplink = null
        walletStatusDelegate?.statusChanged(_walletStatus)

        connectCompletions.clear()
        operationCompletions.clear()
    }

    override fun signMessage(
        request: WalletRequest,
        message: String,
        connected: WalletConnectedCompletion?,
        status: WalletOperationStatus?,
        completion: WalletOperationCompletion
    ) {
        fun requestParams(): com.reown.appkit.client.models.request.Request? {
            val account = _walletStatus.connectedWallet?.address
            return if (account != null) {
                com.reown.appkit.client.models.request.Request(
                    method = "personal_sign",
                    params = "[\"${message}\", \"${account}\"]",
                    expiry = requestExpiry,
                )
            } else {
                null
            }
        }

        connectAndMakeRequest(request, { requestParams() }, connected, status, completion)
    }

    override fun sign(
        request: WalletRequest,
        typedDataProvider: WalletTypedDataProviderProtocol?,
        connected: WalletConnectedCompletion?,
        status: WalletOperationStatus?,
        completion: WalletOperationCompletion
    ) {
        fun requestParams(): com.reown.appkit.client.models.request.Request? {
            val account = _walletStatus.connectedWallet?.address
            val message = typedDataProvider?.typedDataAsString?.replace("\"", "\\\"")

            return if (account != null && message != null) {
                com.reown.appkit.client.models.request.Request(
                    method = "eth_signTypedData",
                    params = "[\"${account}\", \"${message}\"]",
                    expiry = requestExpiry,
                )
            } else {
                null
            }
        }

        connectAndMakeRequest(request, { requestParams() }, connected, status, completion)
    }

    override fun send(
        request: WalletTransactionRequest,
        connected: WalletConnectedCompletion?,
        status: WalletOperationStatus?,
        completion: WalletOperationCompletion
    ) {
        fun requestParams(): com.reown.appkit.client.models.request.Request? {
            val account = _walletStatus.connectedWallet?.address
            val message = request.ethereum?.toJsonRequest()

            return if (account != null && message != null) {
                com.reown.appkit.client.models.request.Request(
                    method = "eth_sendTransaction",
                    params = "[$message]",
                    expiry = requestExpiry,
                )
            } else {
                null
            }
        }

        connectAndMakeRequest(request.walletRequest, { requestParams() }, connected, status, completion)
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

    private fun connectAndMakeRequest(
        request: WalletRequest,
        requestParams: (() -> com.reown.appkit.client.models.request.Request?),
        connected: WalletConnectedCompletion?,
        status: WalletOperationStatus?,
        completion: WalletOperationCompletion
    ) {
        connect(request) { info, error ->
            if (error != null) {
                completion(null, error)
            } else if (currentSession != null) {
                if (connected != null) {
                    connected(info)
                }

                Thread.sleep(1000)
                val params = requestParams()
                if (params != null) {
                    reallyMakeRequest(params, status) { result, requestError ->
                        CoroutineScope(Dispatchers.Main).launch {
                            completion(result, requestError)
                        }
                    }
                } else {
                    CoroutineScope(Dispatchers.Main).launch {
                        completion(null, WalletError(CarteraErrorCode.INVALID_SESSION))
                    }
                }
            } else {
                CoroutineScope(Dispatchers.Main).launch {
                    completion(null, WalletError(CarteraErrorCode.INVALID_SESSION))
                }
            }
        }
    }

    private fun reallyMakeRequest(
        requestParams: com.reown.appkit.client.models.request.Request,
        status: WalletOperationStatus?,
        completion: WalletOperationCompletion
    ) {
        AppKit.request(
            request = requestParams,
            onSuccess = { sendRequest ->
                /* callback that letting you know that you have successful request */
                Timber.d("Wallet request made.")
                val walletConnect = sendRequest as SentRequestResult.WalletConnect
                operationCompletions[walletConnect.sessionTopic] = completion
            },
            onError = { error ->
                /* callback that letting you know that you have error */
                Timber.e(error.stackTrace.toString())
                completion(
                    null,
                    WalletError(
                        code = CarteraErrorCode.CONNECTION_FAILED,
                        title = "WalletConnectModal.request error",
                        message = error.stackTrace.toString(),
                    ),
                )
            },
        )

        openPeerDeeplink(status)
    }

    // MARK: WalletConnectModal.ModalDelegate

    override fun onConnectionStateChange(state: Modal.Model.ConnectionState) {
        Timber.d("Connection state changed: $state")
    }

    override fun onError(error: Modal.Model.Error) {
        Timber.e("WalletConnectModal error: $error")
    }

    override fun onProposalExpired(proposal: Modal.Model.ExpiredProposal) {
        Timber.d("Proposal expired: $proposal")
    }

    override fun onRequestExpired(request: Modal.Model.ExpiredRequest) {
        Timber.d("Request expired: $request")
    }

    override fun onSessionApproved(approvedSession: Modal.Model.ApprovedSession) {
        val approvedSession = approvedSession as Modal.Model.ApprovedSession.WalletConnectSession
        Timber.d("Session approved: $approvedSession")

        CoroutineScope(Dispatchers.Main).launch {
            val approvedSsssion = approvedSession.namespaces[ethNamespace]

            val requestChainId = requestingWallet?.chainId
            val walletChainIds = approvedSsssion?.chains?.mapNotNull {
                val components = it.split(":")
                if (components.size > 1) components[1] else null
            } ?: emptyList()
            if (requestChainId != null && !walletChainIds.contains(requestChainId)) {
                for (connectCompletion in connectCompletions) {
                    connectCompletion.invoke(
                        null,
                        WalletError(
                            code = CarteraErrorCode.WALLET_MISMATCH,
                            message = CarteraErrorCode.WALLET_MISMATCH.message,
                        ),
                    )
                }
                connectCompletions.clear()
                return@launch
            }

            currentSession = approvedSession

            _walletStatus.state = WalletState.CONNECTED_TO_WALLET
            _walletStatus.connectedWallet =
                fromApprovedSession(approvedSession, requestingWallet?.wallet)
            _walletStatus.connectionDeeplink = approvedSession.metaData?.appLink ?: approvedSession.metaData?.redirect

            for (connectCompletion in connectCompletions) {
                connectCompletion.invoke(
                    _walletStatus.connectedWallet,
                    null,
                )
            }
            connectCompletions.clear()

            walletStatusDelegate?.statusChanged(_walletStatus)
        }
    }

    override fun onSessionDelete(deletedSession: Modal.Model.DeletedSession) {
        Timber.d("Session deleted: $deletedSession")

        when (deletedSession) {
            is Modal.Model.DeletedSession.Success -> {
                if (currentSession?.topic == deletedSession.topic) {
                    currentSession = null

                    _walletStatus.state = WalletState.IDLE
                    _walletStatus.connectedWallet = null
                    _walletStatus.connectionDeeplink = null

                    walletStatusDelegate?.statusChanged(_walletStatus)
                }
            }
            is Modal.Model.DeletedSession.Error -> {
                Timber.e("Session delete error: ${deletedSession.error}")
            }
        }
    }

    override fun onSessionEvent(sessionEvent: Modal.Model.SessionEvent) {
        Timber.d("Session event: $sessionEvent")
    }

    override fun onSessionExtend(session: Modal.Model.Session) {
        Timber.d("Session extended: $session")
    }

    override fun onSessionRejected(rejectedSession: Modal.Model.RejectedSession) {
        Timber.d("Session rejected: $rejectedSession")

        CoroutineScope(Dispatchers.Main).launch {
            currentSession = null

            _walletStatus.state = WalletState.IDLE
            _walletStatus.connectedWallet = null

            for (connectCompletion in connectCompletions) {
                connectCompletion.invoke(
                    null,
                    WalletError(
                        code = CarteraErrorCode.REFUSED_BY_WALLET,
                        message = rejectedSession.reason,
                    ),
                )
            }
            connectCompletions.clear()

            walletStatusDelegate?.statusChanged(_walletStatus)
        }
    }

    override fun onSessionRequestResponse(response: Modal.Model.SessionRequestResponse) {
        Timber.d("Session request response: $response")

        CoroutineScope(Dispatchers.Main).launch {
            val completion = operationCompletions[response.topic]
            if (completion != null) {
                when (response.result) {
                    is Modal.Model.JsonRpcResponse.JsonRpcResult -> {
                        val result =
                            response.result as Modal.Model.JsonRpcResponse.JsonRpcResult
                        completion.invoke(
                            result.result,
                            null,
                        )
                    }

                    is Modal.Model.JsonRpcResponse.JsonRpcError -> {
                        val error =
                            response.result as Modal.Model.JsonRpcResponse.JsonRpcError
                        completion.invoke(
                            null,
                            WalletError(
                                code = CarteraErrorCode.UNEXPECTED_RESPONSE,
                                message = error.message,
                            ),
                        )
                    }
                }

                operationCompletions.remove(response.topic)
            }
        }
    }

    override fun onSessionUpdate(updatedSession: Modal.Model.UpdatedSession) {
        Timber.d("Session updated: $updatedSession")
    }

    private fun fromApprovedSession(session: Modal.Model.ApprovedSession, wallet: Wallet?): WalletInfo {
        val session = session as Modal.Model.ApprovedSession.WalletConnectSession
        val account = session.accounts.firstOrNull()
        var address: String? = null
        var chainId: String? = null
        if (account != null) {
            val comps = account.split(":")
            if (comps.size == 3) {
                address = comps[2]
                chainId = comps[1]
            }
        }
        return WalletInfo(
            address = address,
            chainId = chainId,
            wallet = wallet,
            peerName = session.metaData?.name,
            peerImageUrl = session.metaData?.icons?.firstOrNull(),
        )
    }

    private fun openPeerDeeplink(status: WalletOperationStatus?) {
        if (currentSession == null) {
            Timber.d("Current session is null")
            return
        }

        val deeplinkPairingUri = currentSession?.metaData?.redirect ?: currentSession?.metaData?.appLink
        if (deeplinkPairingUri != null) {
            try {
                val uri = Uri.parse(deeplinkPairingUri)
                val intent = Intent(Intent.ACTION_VIEW, uri)
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                application.startActivity(intent)
            } catch (exception: ActivityNotFoundException) {
                Timber.e(exception)
            }
        } else {
            Timber.d("Invalid deeplink uri")
            status?.invoke(true) // tell the client user needs to manually switch to the wallet
        }
    }
}
