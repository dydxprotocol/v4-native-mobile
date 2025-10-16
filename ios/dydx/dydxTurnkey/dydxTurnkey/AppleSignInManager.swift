//
//  AppleSignInManager.swift
//  dydxTurnkey
//
//  Created by Rui Huang on 26/07/2025.
//

import AuthenticationServices
import UIKit

public class AppleSignInManager: NSObject, ASAuthorizationControllerDelegate,
                                 ASWebAuthenticationPresentationContextProviding {
    private var authSession: ASWebAuthenticationSession?

    public func signInWithApple(nonce: String,
                                publicKey: String,
                                restHost: String,
                                clientId: String,
                                completion: @escaping (String?, Error?) -> Void) {
        let redirectUri = restHost + "/v4/turnkey/appleLoginRedirect"

        var components = URLComponents(string: "https://appleid.apple.com/auth/authorize")!
        components.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
         //   URLQueryItem(name: "response_mode", value: "query"),
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
         //   URLQueryItem(name: "scope", value: "email"),
            URLQueryItem(name: "state", value: publicKey),
            URLQueryItem(name: "nonce", value: nonce)
        ]

        guard let authURL = components.url else {
            completion(nil, NSError(domain: "AppleSignInErrorDomain",
                                     code: 1001,
                                     userInfo: [NSLocalizedDescriptionKey: "Failed to generate authorization URL"]))
            return
        }

        authSession = ASWebAuthenticationSession(
            url: authURL,
            callback: ASWebAuthenticationSession.Callback.customScheme("dydx-t-v4"),
            completionHandler: { callbackURL, error in
                if let error = error {
                    completion(nil, error)
                    return
                }

                guard let url = callbackURL else {
                    completion(nil, NSError(domain: "AppleSignInErrorDomain",
                                            code: 1001,
                                            userInfo: [NSLocalizedDescriptionKey: "Invalid Apple auth callback"]))
                    return
                }

                let queryItems = URLComponents(string: url.absoluteString)?.queryItems
                let session = queryItems?.first(where: { $0.name == "appleLogin" })?.value
                completion(session, nil)
            }
        )

        authSession?.presentationContextProvider = self
        authSession?.prefersEphemeralWebBrowserSession = true
        authSession?.start()
    }

    // MARK: ASWebAuthenticationPresentationContextProviding

    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // Prefer the active foreground scene's key window if available
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
           let window = windowScene.keyWindow {
            return window
        }
        // Fallbacks for earlier iOS versions
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            return window
        }
        // As a last resort, create a temporary window (should rarely happen)
        return ASPresentationAnchor()
    }
}
