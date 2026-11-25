//
//  dydxCarteraTests.swift
//  dydxCarteraTests
//
//  Created by Rui Huang on 3/1/23.
//

import XCTest
@testable import dydxCartera

final class dydxCarteraTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    // Expected values come from cosmjs (v4-client-js) using the same mnemonic and sign doc
    func testInjectiveSignerMatchesCosmjs() throws {
        let signer = InjectiveSigner()
        let signDocHex = "0aea010ae7010a292f6962632e6170706c69636174696f6e732e7472616e736665722e76312e4d73675472616e7366657212b9010a087472616e73666572120b6368616e6e656c2d3235381a3b0a3065726332303a307861303043353966463561303830443262393534643063373565343645323261306333373132333561120732353030303030222a696e6a313777306164656736346b7930646178776432756779756e65656c6c6d6a676e786635766b65632a2b6479647831347a7a7565617a656830686a36376367686866396a7970736c6366397368326e356b366172743200388080d09de9ceb8fd18127e0a5e0a540a2d2f696e6a6563746976652e63727970746f2e763162657461312e657468736563703235366b312e5075624b657912230a21038318535b54105d4a7aae60c08fc45f9687181b4fdfc625bd1a753fa7397fed7512040a0208011803121c0a160a03696e6a120f34353030303030303030303030303010d0bb1b1a0d696e6a6563746976652d383838209fcb0a"
        let signDoc = Data(stride(from: 0, to: signDocHex.count, by: 2).map { offset in
            let start = signDocHex.index(signDocHex.startIndex, offsetBy: offset)
            return UInt8(signDocHex[start..<signDocHex.index(start, offsetBy: 2)], radix: 16)!
        })

        XCTAssertEqual(signer.connect(mnemonic: "test test test test test test test test test test test junk"), "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266")
        XCTAssertEqual(signer.compressedPublicKey?.base64EncodedString(), "A4MYU1tUEF1Keq5gwI/EX5aHGBtP38YlvRp1P6c5f+11")
        XCTAssertEqual(
            signer.sign(signDoc: signDoc)?.base64EncodedString(),
            "hrnFP/Yawppx1mvExBw6pdF1iflF/H/zgQN5uJEfoPllo0OYDPNFz+ZQswzxMwdOmd5jlIdNjMCL3h6ifk8Mtw=="
        )

        signer.disconnect()
        XCTAssertNil(signer.evmAddress)
        XCTAssertNil(signer.sign(signDoc: signDoc))
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
