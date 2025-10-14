package exchange.dydx.dydxCartera.walletprovider

import exchange.dydx.dydxCartera.CarteraErrorCode

data class WalletError(
    val code: CarteraErrorCode,
    val title: String? = null,
    val message: String? = null
)
