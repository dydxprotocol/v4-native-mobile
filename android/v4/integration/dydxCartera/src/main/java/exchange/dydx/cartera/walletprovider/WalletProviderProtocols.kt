package exchange.dydx.dydxCartera.walletprovider

import android.content.Context
import android.net.Uri
import exchange.dydx.dydxCartera.entities.Wallet
import exchange.dydx.dydxCartera.typeddata.WalletTypedDataProviderProtocol
import java.math.BigInteger

data class WalletRequest(
    val wallet: Wallet? = null,
    val address: String? = null,
    val chainId: String? = null,
    val context: Context,
    val useModal: Boolean = false,
) {
    val ethChain: String?
        get() {
            if (chainId == null) {
                return null
            }
            return "eip155:$chainId"
        }
}

data class WalletTransactionRequest(
    val walletRequest: WalletRequest,
    val ethereum: EthereumTransactionRequest?,
    val solana: ByteArray?
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as WalletTransactionRequest

        if (walletRequest != other.walletRequest) return false
        if (ethereum != other.ethereum) return false
        if (!solana.contentEquals(other.solana)) return false

        return true
    }

    override fun hashCode(): Int {
        var result = walletRequest.hashCode()
        result = 31 * result + (ethereum?.hashCode() ?: 0)
        result = 31 * result + (solana?.contentHashCode() ?: 0)
        return result
    }
}

data class EthereumTransactionRequest(
    val fromAddress: String,
    val toAddress: String?,
    val weiValue: BigInteger,
    val data: String,
    val nonce: Int?,
    val gasPriceInWei: BigInteger?,
    val maxFeePerGas: BigInteger?,
    val maxPriorityFeePerGas: BigInteger?,
    val gasLimit: BigInteger?,
    val chainId: String
)

data class EthereumAddChainRequest(
    val chainId: String,
)

typealias WalletConnectedCompletion = (info: WalletInfo?) -> Unit
typealias WalletOperationStatus = (requireAppSwitching: Boolean) -> Unit
typealias WalletOperationCompletion = (signed: String?, error: WalletError?) -> Unit
typealias WalletConnectCompletion = (info: WalletInfo?, error: WalletError?) -> Unit

interface WalletOperationProtocol {
    fun connect(request: WalletRequest, completion: WalletConnectCompletion)
    fun disconnect()
    fun signMessage(request: WalletRequest, message: String, connected: WalletConnectedCompletion?, status: WalletOperationStatus?, completion: WalletOperationCompletion)
    fun sign(request: WalletRequest, typedDataProvider: WalletTypedDataProviderProtocol?, connected: WalletConnectedCompletion?, status: WalletOperationStatus?, completion: WalletOperationCompletion)
    fun send(request: WalletTransactionRequest, connected: WalletConnectedCompletion?, status: WalletOperationStatus?, completion: WalletOperationCompletion)
    fun addChain(request: WalletRequest, chain: EthereumAddChainRequest, connected: WalletConnectedCompletion?, status: WalletOperationStatus?, completion: WalletOperationCompletion)
}

interface WalletUserConsentOperationProtocol : WalletOperationProtocol {
    var userConsentDelegate: WalletUserConsentProtocol?
}

interface WalletDeeplinkHandlingProtocol {
    fun handleResponse(uri: Uri): Boolean
}

interface WalletOperationProviderProtocol : WalletStatusProviding, WalletUserConsentOperationProtocol, WalletDeeplinkHandlingProtocol
