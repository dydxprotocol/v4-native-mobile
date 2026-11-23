package exchange.dydx.dydxstatemanager.protocolImplementations

import exchange.dydx.abacus.protocols.DYDXChainTransactionsProtocol
import exchange.dydx.abacus.protocols.QueryType
import exchange.dydx.abacus.protocols.TransactionType
import exchange.dydx.trading.integration.cosmos.CosmosV4ClientProtocol
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.contentOrNull
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import kotlinx.serialization.json.put
import kotlinx.serialization.json.putJsonObject
import java.util.Base64
import javax.inject.Inject

class AbacusChainImp @Inject constructor(
    private val cosmosClient: CosmosV4ClientProtocol,
    private val injectiveSigner: InjectiveSigner,
) : DYDXChainTransactionsProtocol {

    override fun connectNetwork(
        paramsInJson: String,
        callback: (response: String?) -> Unit,
    ) {
        cosmosClient.connectNetwork(paramsInJson) { response ->
            callback(response)
        }
    }

    override fun get(
        type: QueryType,
        paramsInJson: String?,
        callback: (response: String?) -> Unit,
    ) {
        if (type == QueryType.GetInjectivePublicKey) {
            callback(injectiveResponse("publicKey", injectiveSigner.compressedPublicKey()))
            return
        }
        cosmosClient.call(type.rawValue, paramsInJson) { response ->
            callback(response)
        }
    }

    override fun transaction(
        type: TransactionType,
        paramsInJson: String?,
        callback: (response: String?) -> Unit,
    ) {
        if (type == TransactionType.SignInjectiveDirect) {
            val signDoc = paramsInJson?.let {
                Json.parseToJsonElement(it).jsonObject["signDoc"]?.jsonPrimitive?.contentOrNull
            }
            val signature = signDoc?.let { injectiveSigner.sign(Base64.getDecoder().decode(it)) }
            callback(injectiveResponse("signature", signature))
            return
        }
        cosmosClient.call(type.rawValue, paramsInJson) { response ->
            callback(response)
        }
    }

    private fun injectiveResponse(field: String, value: ByteArray?): String {
        return buildJsonObject {
            if (value != null) {
                put(field, Base64.getEncoder().encodeToString(value))
            } else {
                putJsonObject("error") { put("message", "Injective key unavailable") }
            }
        }.toString()
    }
}
