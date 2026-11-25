package exchange.dydx.dydxstatemanager

import exchange.dydx.dydxstatemanager.protocolImplementations.InjectiveSigner
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test
import java.util.Base64

// Expected values come from cosmjs (v4-client-js) using the same mnemonic and sign doc
class InjectiveSignerTest {
    private val mnemonic = "test test test test test test test test test test test junk"
    private val signDoc =
        "0aea010ae7010a292f6962632e6170706c69636174696f6e732e7472616e736665722e76312e4d73675472616e7366657212b9010a087472616e73666572120b6368616e6e656c2d3235381a3b0a3065726332303a307861303043353966463561303830443262393534643063373565343645323261306333373132333561120732353030303030222a696e6a313777306164656736346b7930646178776432756779756e65656c6c6d6a676e786635766b65632a2b6479647831347a7a7565617a656830686a36376367686866396a7970736c6366397368326e356b366172743200388080d09de9ceb8fd18127e0a5e0a540a2d2f696e6a6563746976652e63727970746f2e763162657461312e657468736563703235366b312e5075624b657912230a21038318535b54105d4a7aae60c08fc45f9687181b4fdfc625bd1a753fa7397fed7512040a0208011803121c0a160a03696e6a120f34353030303030303030303030303010d0bb1b1a0d696e6a6563746976652d383838209fcb0a"

    @Test
    fun derivesInjectiveKeyAndSignsLikeCosmjs() {
        val signer = InjectiveSigner()

        assertEquals("inj17w0adeg64ky0daxwd2ugyuneellmjgnxf5vkec", signer.connect(mnemonic))
        assertEquals("A4MYU1tUEF1Keq5gwI/EX5aHGBtP38YlvRp1P6c5f+11", base64(signer.compressedPublicKey()))
        assertEquals(
            "hrnFP/Yawppx1mvExBw6pdF1iflF/H/zgQN5uJEfoPllo0OYDPNFz+ZQswzxMwdOmd5jlIdNjMCL3h6ifk8Mtw==",
            base64(signer.sign(signDoc.chunked(2).map { it.toInt(16).toByte() }.toByteArray())),
        )

        signer.disconnect()
        assertNull(signer.address)
        assertNull(signer.compressedPublicKey())
        assertNull(signer.sign(ByteArray(1)))
    }

    private fun base64(bytes: ByteArray?): String? = bytes?.let { Base64.getEncoder().encodeToString(it) }
}
