package exchange.dydx.dydxstatemanager.protocolImplementations

import exchange.dydx.abacus.utils.AbacusStringUtils
import org.web3j.crypto.Bip32ECKeyPair
import org.web3j.crypto.Bip32ECKeyPair.HARDENED_BIT
import org.web3j.crypto.ECKeyPair
import org.web3j.crypto.Keys
import org.web3j.crypto.MnemonicUtils
import org.web3j.crypto.Sign
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Holds the Injective ethsecp256k1 key derived from the dYdX mnemonic so Abacus can sign
 * Injective transactions without the JS client.
 */
@Singleton
class InjectiveSigner @Inject constructor() {
    private companion object {
        val DERIVATION_PATH = intArrayOf(44 or HARDENED_BIT, 60 or HARDENED_BIT, 0 or HARDENED_BIT, 0, 0)
    }

    private var keyPair: ECKeyPair? = null

    var address: String? = null
        private set

    fun connect(mnemonic: String): String? {
        val master = Bip32ECKeyPair.generateKeyPair(MnemonicUtils.generateSeed(mnemonic, ""))
        val derived = Bip32ECKeyPair.deriveKeyPair(master, DERIVATION_PATH)
        keyPair = derived
        address = AbacusStringUtils.evmToInjectiveAddress(Keys.getAddress(derived))
        return address
    }

    fun disconnect() {
        keyPair = null
        address = null
    }

    fun compressedPublicKey(): ByteArray? {
        val privateKey = keyPair?.privateKey ?: return null
        return Sign.publicPointFromPrivate(privateKey).getEncoded(true)
    }

    // keccak256 of the sign doc, signed as a 64-byte low-s r || s
    fun sign(signDoc: ByteArray): ByteArray? {
        val signature = Sign.signMessage(signDoc, keyPair ?: return null, true)
        return signature.r + signature.s
    }
}
