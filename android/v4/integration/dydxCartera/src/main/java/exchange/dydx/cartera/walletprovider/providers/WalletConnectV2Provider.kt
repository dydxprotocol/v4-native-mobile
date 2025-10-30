package exchange.dydx.dydxCartera.walletprovider.providers

import android.app.Application
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.util.Log
import com.reown.android.Core
import com.reown.android.CoreClient
import com.reown.android.relay.ConnectionType
import com.reown.appkit.client.AppKit
import com.reown.appkit.client.Modal
import com.reown.appkit.client.models.request.SentRequestResult
import com.reown.appkit.presets.AppKitChainsPresets
import com.reown.appkit.presets.AppKitChainsPresets.ethToken
import com.reown.appkit.utils.EthUtils
import exchange.dydx.dydxCartera.CarteraErrorCode
import exchange.dydx.dydxCartera.WalletConnectModalConfig
import exchange.dydx.dydxCartera.WalletConnectV2Config
import exchange.dydx.dydxCartera.WalletConnectionType
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
import kotlinx.coroutines.Dispatchers.IO
import kotlinx.coroutines.launch
import timber.log.Timber
import java.util.concurrent.TimeUnit

class WalletConnectV2Provider(
    private val walletConnectV2Config: WalletConnectV2Config?,
    private val modalConfig: WalletConnectModalConfig?,
    private val application: Application
) : WalletOperationProviderProtocol {
    private var _walletStatus = WalletStatusImp()
        set(value) {
            field = value
            walletStatusDelegate?.statusChanged(value)
        }
    override val walletStatus: WalletStatusProtocol
        get() = _walletStatus

    override var walletStatusDelegate: WalletStatusDelegate? = null
    override var userConsentDelegate: WalletUserConsentProtocol? = null

    private val connectCompletions: MutableList<WalletConnectCompletion> = mutableListOf()
    private val operationCompletions: MutableMap<String, WalletOperationCompletion> = mutableMapOf()

    private var requestingWallet: WalletRequest? = null
    private var currentSession: Modal.Model.ApprovedSession? = null

    private var currentPairing: Core.Model.Pairing? = null

    // expiry must be between current timestamp + MIN_INTERVAL and current timestamp + MAX_INTERVAL (MIN_INTERVAL: 300, MAX_INTERVAL: 604800)
    private val requestExpiry: Long
        get() = (System.currentTimeMillis() / 1000) + 400

    private val nilDelegate = object : AppKit.ModalDelegate {
        override fun onSessionApproved(approvedSession: Modal.Model.ApprovedSession) {
        }

        override fun onSessionRejected(rejectedSession: Modal.Model.RejectedSession) {
        }

        override fun onSessionUpdate(updatedSession: Modal.Model.UpdatedSession) {
        }

        override fun onSessionExtend(session: Modal.Model.Session) {
        }

        override fun onSessionEvent(sessionEvent: Modal.Model.SessionEvent) {
        }

        override fun onSessionDelete(deletedSession: Modal.Model.DeletedSession) {
        }

        override fun onSessionRequestResponse(response: Modal.Model.SessionRequestResponse) {
        }

        override fun onProposalExpired(proposal: Modal.Model.ExpiredProposal) {
        }

        override fun onRequestExpired(request: Modal.Model.ExpiredRequest) {
        }

        override fun onConnectionStateChange(state: Modal.Model.ConnectionState) {
        }

        override fun onError(error: Modal.Model.Error) {
        }
    }

    private val dappDelegate = object : AppKit.ModalDelegate {
        override fun onSessionApproved(approvedSession: Modal.Model.ApprovedSession) {
            // Triggered when Dapp receives the session approval from wallet
            Log.d(tag(this@WalletConnectV2Provider), "onSessionApproved")

            CoroutineScope(Dispatchers.Main).launch {
                val requestChainId = requestingWallet?.chainId
                val walletChainIds = approvedSession.chainIds() ?: emptyList()
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
                _walletStatus.connectedWallet = fromApprovedSession(approvedSession, requestingWallet?.wallet)

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

        override fun onSessionRejected(rejectedSession: Modal.Model.RejectedSession) {
            // Triggered when Dapp receives the session rejection from wallet
            Log.d(tag(this@WalletConnectV2Provider), "onSessionRejected: $rejectedSession")

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

        override fun onSessionUpdate(updatedSession: Modal.Model.UpdatedSession) {
            // Triggered when Dapp receives the session update from wallet
            Log.d(tag(this@WalletConnectV2Provider), "onSessionUpdate")
        }

        override fun onSessionExtend(session: Modal.Model.Session) {
            // Triggered when Dapp receives the session extend from wallet
            Log.d(tag(this@WalletConnectV2Provider), "onSessionExtend")
        }

        override fun onSessionEvent(sessionEvent: Modal.Model.SessionEvent) {
            // Triggered when the peer emits events that match the list of events agreed upon session settlement
            Log.d(tag(this@WalletConnectV2Provider), "onSessionEvent")
        }

        override fun onSessionDelete(deletedSession: Modal.Model.DeletedSession) {
            // Triggered when Dapp receives the session delete from wallet
            Log.d(tag(this@WalletConnectV2Provider), "onSessionDelete: $deletedSession")

            CoroutineScope(Dispatchers.Main).launch {
                currentSession = null
            }
        }

        override fun onSessionRequestResponse(response: Modal.Model.SessionRequestResponse) {
            // Triggered when Dapp receives the session request response from wallet
            Log.d(tag(this@WalletConnectV2Provider), "onSessionRequestResponse: $response")

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

        override fun onConnectionStateChange(state: Modal.Model.ConnectionState) {
            // Triggered whenever the connection state is changed
            Log.d(tag(this@WalletConnectV2Provider), "onConnectionStateChange: $state")
        }

        override fun onError(error: Modal.Model.Error) {
            // Triggered whenever there is an issue inside the SDK

            Log.d(tag(this@WalletConnectV2Provider), "onError: $error")
        }

        override fun onProposalExpired(proposal: Modal.Model.ExpiredProposal) {
            Log.d(tag(this@WalletConnectV2Provider), "onProposalExpired: $proposal")
        }

        override fun onRequestExpired(request: Modal.Model.ExpiredRequest) {
            Log.d(tag(this@WalletConnectV2Provider), "onRequestExpired: $request")
        }
    }

    init {
        walletConnectV2Config?.let { walletConnectV2Config ->
            // Reference: https://docs.walletconnect.com/2.0/android/sign/dapp-usage
            val projectId = walletConnectV2Config.projectId
            val relayUrl = "relay.walletconnect.com"
            val serverUrl = "wss://$relayUrl?projectId=$projectId"
            val connectionType = ConnectionType.AUTOMATIC // or ConnectionType.MANUAL

            val metadata = Core.Model.AppMetaData(
                name = walletConnectV2Config.clientName,
                description = walletConnectV2Config.clientDescription,
                url = walletConnectV2Config.clientUrl,
                icons = walletConnectV2Config.iconUrls,
                redirect = "exchange.dydx.carteraexample",
            )

            CoreClient.initialize(
                metaData = metadata,
                relayServerUrl = serverUrl,
                connectionType = connectionType,
                application = application,
                onError = { error ->
                    Log.e(tag(this@WalletConnectV2Provider), error.throwable.stackTraceToString())
                },
            )

            AppKit.initialize(
                init = Modal.Params.Init(
                    core = CoreClient,
                    recommendedWalletsIds = modalConfig?.walletIds ?: emptyList(),
                    includeWalletIds = modalConfig?.walletIds ?: emptyList(),
                    coinbaseEnabled = false,
                ),
                onSuccess = {
                    // Callback will be called if initialization is successful
                    Timber.tag(tag(this)).d("WalletConnectModal initialized.")
                },
                onError = { error ->
                    // Error will be thrown if there's an issue during initialization
                    Timber.tag(tag(this))
                        .e(error.throwable.stackTraceToString())
                },
            )
        }
    }

    override fun handleResponse(uri: Uri): Boolean {
        return false
    }

    override fun connect(request: WalletRequest, completion: WalletConnectCompletion) {
        if (_walletStatus.state == WalletState.CONNECTED_TO_WALLET) {
            completion(walletStatus.connectedWallet, null)
        } else {
            requestingWallet = request

            AppKit.setDelegate(dappDelegate)

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

            CoroutineScope(IO).launch {
                doConnect(request = request) { pairing, error ->
                    CoroutineScope(Dispatchers.Main).launch {
                        if (error != null) {
                            currentPairing = null
                            _walletStatus.connectedWallet = null
                            _walletStatus.connectionDeeplink = null
                            _walletStatus.state = WalletState.IDLE
                            walletStatusDelegate?.statusChanged(_walletStatus)
                            completion(null, error)
                        } else if (pairing != null) {
                            currentPairing = pairing
                            _walletStatus.state = WalletState.CONNECTED_TO_SERVER
                            if (request.wallet != null) {
                                _walletStatus.connectedWallet =
                                    fromPairing(pairing, request.wallet)
                            }
                            _walletStatus.connectionDeeplink =
                                pairing.uri.replace("wc:", "wc://")

                            walletStatusDelegate?.statusChanged(_walletStatus)

                            // let dappDelegate call the completion
                            connectCompletions.add(completion)
                        } else {
                            currentPairing = null
                            _walletStatus.state = WalletState.IDLE
                            _walletStatus.connectedWallet = null
                            walletStatusDelegate?.statusChanged(_walletStatus)
                            completion(null, WalletError(CarteraErrorCode.CONNECTION_FAILED))
                        }
                    }
                }
            }
        }
    }

    override fun disconnect() {
        currentPairing?.let {
            CoreClient.Pairing.disconnect(Core.Params.Disconnect(it.topic)) { error ->
                Log.e(tag(this@WalletConnectV2Provider), error.throwable.stackTraceToString())
            }
            currentPairing = null
        }

        _walletStatus.state = WalletState.IDLE
        _walletStatus.connectedWallet = null
        _walletStatus.connectionDeeplink = null
        walletStatusDelegate?.statusChanged(_walletStatus)

        connectCompletions.clear()
        operationCompletions.clear()

        AppKit.setDelegate(nilDelegate)
    }

    override fun signMessage(
        request: WalletRequest,
        message: String,
        connected: WalletConnectedCompletion?,
        status: WalletOperationStatus?,
        completion: WalletOperationCompletion
    ) {
        fun requestParams(): com.reown.appkit.client.models.request.Request? {
            val account = currentSession?.account()
            val namespace = currentSession?.namespace()
            val chainId = request.chainId ?: currentSession?.chainId()
            return if (account != null && namespace != null && chainId != null) {
                com.reown.appkit.client.models.request.Request(
                    method = "personal_sign",
                    params = "[\"${message}\", \"${account}\"]",
                    expiry = requestExpiry,
                )
            } else {
                null
            }
        }

        connectAndMakeRequest(request, { requestParams() }, connected, completion)
    }

    override fun sign(
        request: WalletRequest,
        typedDataProvider: WalletTypedDataProviderProtocol?,
        connected: WalletConnectedCompletion?,
        status: WalletOperationStatus?,
        completion: WalletOperationCompletion
    ) {
        fun requestParams(): com.reown.appkit.client.models.request.Request? {
            val account = currentSession?.account()
            val namespace = currentSession?.namespace()
            val chainId = request.chainId ?: currentSession?.chainId()
            val message = typedDataProvider?.typedDataAsString?.replace("\"", "\\\"")

            return if (account != null && namespace != null && chainId != null && message != null) {
                com.reown.appkit.client.models.request.Request(
                    method = "eth_signTypedData",
                    params = "[\"${account}\", \"${message}\"]",
                    expiry = requestExpiry,
                )
            } else {
                null
            }
        }

        connectAndMakeRequest(request, { requestParams() }, connected, completion)
    }

    override fun send(
        request: WalletTransactionRequest,
        connected: WalletConnectedCompletion?,
        status: WalletOperationStatus?,
        completion: WalletOperationCompletion
    ) {
        fun requestParams(): com.reown.appkit.client.models.request.Request? {
            val account = currentSession?.account()
            val namespace = currentSession?.namespace()
            val chainId = request.walletRequest.chainId ?: currentSession?.chainId()
            val message = request.ethereum?.toJsonRequest()
            return if (account != null && namespace != null && chainId != null && message != null) {
                com.reown.appkit.client.models.request.Request(
                    method = "eth_sendTransaction",
                    params = "[$message]",
                    expiry = requestExpiry,
                )
            } else {
                null
            }
        }

        connectAndMakeRequest(request.walletRequest, { requestParams() }, connected, completion)
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

    private fun doConnect(request: WalletRequest, completion: (pairing: Core.Model.Pairing?, error: WalletError?) -> Unit) {
        val namespace: String = "eip155" /*Namespace identifier, see for reference: https://github.com/ChainAgnostic/CAIPs/blob/master/CAIPs/caip-2.md#syntax*/
        val chain: String = if (request.chainId != null) {
            "eip155:${request.chainId}"
        } else {
            "eip155:5"
        }
        val chains: List<String> = listOf(chain)
        val methods: List<String> = listOf(
            "personal_sign",
            "eth_sendTransaction",
            "eth_signTypedData",
            //   "wallet_addEthereumChain"
        )
        val events: List<String> = listOf(
            "accountsChanged",
            "chainChanged",
        )
        val proposal = Modal.Model.Namespace.Proposal(chains, methods, events)
        val requiredNamespaces: Map<String, Modal.Model.Namespace.Proposal> = mapOf(namespace to proposal) /*Required namespaces to setup a session*/

        val pairings = CoreClient.Pairing.getPairings()
        for (pairing in pairings) {
            CoreClient.Pairing.disconnect(pairing.topic)
        }
        val pairing = CoreClient.Pairing.create() { error ->
            Log.e(tag(this@WalletConnectV2Provider), error.throwable.stackTraceToString())
        }

        val expiry = (System.currentTimeMillis() / 1000) + TimeUnit.SECONDS.convert(7, TimeUnit.DAYS)
        val properties: Map<String, String> = mapOf("sessionExpiry" to "$expiry")

        if (pairing != null) {
            val connectParams =
                Modal.Params.ConnectParams(
                    sessionNamespaces = requiredNamespaces,
                    properties = properties,
                    pairing = pairing,
                )

            AppKit.connect(
                connectParams = connectParams,
                onSuccess = { value ->
                    Log.d(tag(this), "Connected to wallet: $value")
                    completion(pairing, null)
                },
                onError = { error: Modal.Model.Error ->
                    Log.e(tag(this), error.throwable.stackTraceToString())
                    completion(
                        null,
                        WalletError(
                            CarteraErrorCode.CONNECTION_FAILED,
                            "SignClient.connect error",
                            error.throwable.stackTraceToString(),
                        ),
                    )
                },
            )

            openPeerDeeplink(request, pairing)
        }
    }

    private fun connectAndMakeRequest(
        request: WalletRequest,
        requestParams: (() -> com.reown.appkit.client.models.request.Request?),
        connected: WalletConnectedCompletion?,
        completion: WalletOperationCompletion
    ) {
        connect(request) { info, error ->
            if (error != null) {
                completion(null, error)
            } else if (currentSession != null) {
                if (connected != null) {
                    connected(info)
                }

                val params = requestParams()
                if (params != null) {
                    reallyMakeRequest(request, params) { result, requestError ->
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
        request: WalletRequest,
        requestParams: com.reown.appkit.client.models.request.Request,
        completion: WalletOperationCompletion
    ) {
        AppKit.request(
            request = requestParams,
            onSuccess = { sendRequest: SentRequestResult ->
                val sendRequest = sendRequest as SentRequestResult.WalletConnect
                Log.d(tag(this@WalletConnectV2Provider), "Wallet request made.")
                operationCompletions[sendRequest.sessionTopic] = completion
            },
            onError = {
                Log.e(tag(this@WalletConnectV2Provider), it.stackTraceToString())
                val isSuccessCalled = operationCompletions.values.contains(completion)
                if (!isSuccessCalled) {
                    completion(
                        null,
                        WalletError(
                            CarteraErrorCode.CONNECTION_FAILED,
                            "SignClient.request error",
                            it.stackTraceToString(),
                        ),
                    )
                }
            },
        )

        openPeerDeeplink(request, currentPairing)
    }

    private fun fromPairing(pairing: Core.Model.Pairing, wallet: Wallet): WalletInfo {
        return WalletInfo(
            address = "address",
            chainId = "0",
            wallet = wallet,
            peerName = pairing.peerAppMetaData?.name,
            peerImageUrl = pairing.peerAppMetaData?.icons?.firstOrNull(),
        )
    }

    private fun fromApprovedSession(session: Modal.Model.ApprovedSession, wallet: Wallet?): WalletInfo {
        val session = session as Modal.Model.ApprovedSession.WalletConnectSession
        return WalletInfo(
            address = session.account(),
            chainId = session.chainId(),
            wallet = wallet,
            peerName = session.metaData?.name,
            peerImageUrl = session.metaData?.icons?.firstOrNull(),
        )
    }

    private fun openPeerDeeplink(request: WalletRequest, pairing: Core.Model.Pairing?) {
        if (request.wallet == null) {
            Log.d(tag(this@WalletConnectV2Provider), "Wallet is null")
            return
        }
        if (pairing == null) {
            Log.d(tag(this@WalletConnectV2Provider), "Pairing is null")
            return
        }
        // val deeplinkPairingUri = it.replace("wc:", "wc://")
        val uri = WalletConnectUtils.createUrl(
            wallet = request.wallet,
            deeplink = pairing.uri,
            type = WalletConnectionType.WalletConnectV2,
            context = request.context,
        )
        if (uri != null) {
            try {
                val intent = Intent(Intent.ACTION_VIEW, uri)
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                application.startActivity(intent)
            } catch (exception: ActivityNotFoundException) {
                Log.d(tag(this@WalletConnectV2Provider), "There is no app to handle deep link")
            }
        } else {
            Log.d(tag(this@WalletConnectV2Provider), "Imvalid deeplink uri")
        }
    }
}

private fun Modal.Model.ApprovedSession.chainId(): String? {
    val session = this as Modal.Model.ApprovedSession.WalletConnectSession
    val split = session.accounts.first().split(":")
    return if (split.count() > 1) {
        split[1]
    } else {
        null
    }
}

private fun Modal.Model.ApprovedSession.chainIds(): List<String>? {
    val session = this as Modal.Model.ApprovedSession.WalletConnectSession
    return session.accounts.mapNotNull {
        val split = it.split(":")
        if (split.count() > 1) {
            split[1]
        } else {
            null
        }
    }
}

private fun Modal.Model.ApprovedSession.namespace(): String? {
    val session = this as Modal.Model.ApprovedSession.WalletConnectSession
    val split = session.accounts.first().split(":")
    return if (split.count() > 0) {
        split[0]
    } else {
        null
    }
}

private fun Modal.Model.ApprovedSession.account(): String? {
    val session = this as Modal.Model.ApprovedSession.WalletConnectSession
    val split = session.accounts.first().split(":")
    return if (split.count() > 2) {
        split[2]
    } else {
        null
    }
}
