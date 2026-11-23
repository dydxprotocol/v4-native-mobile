//
//  InjectiveSigner.swift
//  dydxCartera
//

import BigInt
import CommonCrypto
import CryptoKit
import Foundation
import Web3

/// Holds the Injective ethsecp256k1 key derived from the dYdX mnemonic so Abacus can sign
/// Injective transactions without the JS client.
public final class InjectiveSigner {
    public static let shared = InjectiveSigner()

    private static let hardened: UInt32 = 0x8000_0000
    private static let derivationPath: [UInt32] = [44 | hardened, 60 | hardened, 0 | hardened, 0, 0]
    private static let curveOrder = BigUInt("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141", radix: 16)!

    private let lock = NSLock()
    private var _privateKey: EthereumPrivateKey?
    private var privateKey: EthereumPrivateKey? {
        get { lock.withLock { _privateKey } }
        set { lock.withLock { _privateKey = newValue } }
    }

    public var evmAddress: String? {
        privateKey?.address.hex(eip55: false)
    }

    public var compressedPublicKey: Data? {
        privateKey.map { Data(Self.compress($0.publicKey.rawPublicKey)) }
    }

    @discardableResult
    public func connect(mnemonic: String) -> String? {
        privateKey = try? Self.deriveKey(mnemonic: mnemonic)
        return evmAddress
    }

    public func disconnect() {
        privateKey = nil
    }

    /// keccak256 of the sign doc, signed as a 64-byte low-s r || s
    public func sign(signDoc: Data) -> Data? {
        guard let signature = try? privateKey?.sign(message: Array(signDoc)) else { return nil }
        return Data(signature.r + signature.s)
    }

    // BIP39 seed, then BIP32 derivation along m/44'/60'/0'/0/0
    private static func deriveKey(mnemonic: String) throws -> EthereumPrivateKey {
        let master = try split(hmac(key: Data("Bitcoin seed".utf8), data: seed(mnemonic: mnemonic)))
        let derived = try derivationPath.reduce(master) { parent, index in
            let parentData: Data
            if index & hardened != 0 {
                parentData = Data([0]) + parent.key
            } else {
                let parentPublicKey = try EthereumPrivateKey(privateKey: Array(parent.key)).publicKey.rawPublicKey
                parentData = Data(compress(parentPublicKey))
            }
            let child = split(hmac(key: parent.chainCode, data: parentData + bigEndian(index)))
            let childKey = (BigUInt(child.key) + BigUInt(parent.key)) % curveOrder
            return (key: leftPadded(childKey.serialize(), to: 32), chainCode: child.chainCode)
        }
        return try EthereumPrivateKey(privateKey: Array(derived.key))
    }

    private static func seed(mnemonic: String) throws -> Data {
        let password = mnemonic.decomposedStringWithCompatibilityMapping
        let salt = Array("mnemonic".utf8)
        var seed = [UInt8](repeating: 0, count: 64)
        let status = password.withCString { passwordPointer in
            CCKeyDerivationPBKDF(
                CCPBKDFAlgorithm(kCCPBKDF2),
                passwordPointer, password.utf8.count,
                salt, salt.count,
                CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA512), 2048,
                &seed, seed.count
            )
        }
        guard status == kCCSuccess else { throw EthereumPrivateKey.Error.internalError }
        return Data(seed)
    }

    private static func hmac(key: Data, data: Data) -> Data {
        Data(HMAC<SHA512>.authenticationCode(for: data, using: SymmetricKey(data: key)))
    }

    private static func split(_ data: Data) -> (key: Data, chainCode: Data) {
        (key: Data(data.prefix(32)), chainCode: Data(data.suffix(32)))
    }

    private static func bigEndian(_ value: UInt32) -> Data {
        withUnsafeBytes(of: value.bigEndian) { Data($0) }
    }

    private static func leftPadded(_ data: Data, to length: Int) -> Data {
        Data(repeating: 0, count: max(0, length - data.count)) + data
    }

    // 64-byte x || y to 33-byte SEC1 compressed form
    private static func compress(_ rawPublicKey: [UInt8]) -> [UInt8] {
        [rawPublicKey[63] & 1 == 0 ? 0x02 : 0x03] + rawPublicKey[0..<32]
    }
}
