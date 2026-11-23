//
//  AbacusChainImp.swift
//  dydxStateManager
//
//  Created by John Huang on 7/17/23.
//

import Foundation
import Abacus
import dydxCartera
import Utilities

final public class AbacusChainImp: Abacus.DYDXChainTransactionsProtocol {
    public func connectNetwork(paramsInJson: String, callback: @escaping (String?) -> Void) {
        CosmoJavascript.shared.connectNetwork(paramsInJson: paramsInJson) { result in
            let result = result as? String
            Console.shared.log("AbacusChainImp.connectNetwork \(paramsInJson), result: \(result ?? "nil")")
            callback(result)
        }
    }

    public func transaction(type: TransactionType, paramsInJson: String?, callback: @escaping (String?) -> Void) {
        if type == .signinjectivedirect {
            let signDoc = paramsInJson?.jsonDictionary?["signDoc"] as? String
            let signature = signDoc.flatMap { Data(base64Encoded: $0) }.flatMap { InjectiveSigner.shared.sign(signDoc: $0) }
            callback(injectiveResponse(field: "signature", value: signature))
            return
        }
        CosmoJavascript.shared.call(functionName: type.rawValue, paramsInJson: paramsInJson) { result in
            let result = result as? String
            Console.shared.log("AbacusChainImp.transaction \(type.rawValue), param \(paramsInJson ?? "nil"), result: \(result ?? "nil")")
            callback(result)
        }
    }

    public func get(type: QueryType, paramsInJson: String?, callback: @escaping (String?) -> Void) {
        if type == .getinjectivepublickey {
            callback(injectiveResponse(field: "publicKey", value: InjectiveSigner.shared.compressedPublicKey))
            return
        }
        CosmoJavascript.shared.call(functionName: type.rawValue, paramsInJson: paramsInJson) { result in
            let result = result as? String
            Console.shared.log("AbacusChainImp.get \(type.rawValue), param \(paramsInJson ?? "nil"), result: \(result ?? "nil")")
            callback(result)
        }
    }

    private func injectiveResponse(field: String, value: Data?) -> String? {
        let response: [String: Any] = value.map { [field: $0.base64EncodedString()] }
            ?? ["error": ["message": "Injective key unavailable"]]
        return response.jsonString
    }
}
