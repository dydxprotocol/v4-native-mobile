package exchange.dydx.trading.feature.transfer.fiat

import android.R.attr.value
import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import exchange.dydx.abacus.protocols.LocalizerProtocol
import exchange.dydx.abacus.protocols.localizeWithParams
import exchange.dydx.trading.common.AppConfig
import exchange.dydx.trading.common.DydxViewModel
import exchange.dydx.trading.common.featureflags.RemoteFlags
import exchange.dydx.trading.common.formatter.DydxFormatter
import exchange.dydx.trading.common.navigation.DydxRouter
import exchange.dydx.trading.feature.shared.R
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map
import javax.inject.Inject

@HiltViewModel
class DydxFiatDepositViewModel @Inject constructor(
    private val localizer: LocalizerProtocol,
    private val router: DydxRouter,
    private val appConfig: AppConfig,
    private val formatter: DydxFormatter,
    private val remoteFlags: RemoteFlags,
) : ViewModel(), DydxViewModel {

    private val valueState = MutableStateFlow("")

    val state: Flow<DydxFiatDepositView.ViewState?> =
        valueState
            .map { createViewState(it) }
            .distinctUntilChanged()

    private fun createViewState(currentValue: String): DydxFiatDepositView.ViewState {
        val feePercent = remoteFlags.getParamStoreValue("moonpay_fee_percent", 0.0)
        val minAmount = remoteFlags.getParamStoreValue("moonpay_min_deposit", 0.0)

        val minDollar = formatter.dollar(minAmount, digits = 2)
        return DydxFiatDepositView.ViewState(
            localizer = localizer,
            formatter = formatter,
            value = currentValue,
            onEditAction = { value ->
                valueState.value = value
            },
            backButtonAction = {
                router.navigateBack()
            },
            // USDC migration (v9.9): MoonPay delivered USDC to the user's Noble address, which is now rejected.
            // There is no deposit action until MoonPay targets Injective.
            ctaEnabled = false,
            providerName = "MoonPay",
            providerIcon = R.drawable.icon_moonpay,
            providerSubtitle = localizer.localize("APP.DEPOSIT_WITH_FIAT.MOONPAY_SUPPORT_ANDROID"),
            fee = formatter.percent(feePercent / 100, digits = 2),
            amountSubtitle = localizer.localizeWithParams(
                path = "APP.DEPOSIT_WITH_FIAT.MINIMUM_MOONPAY_DEPOSIT",
                params = mapOf("MIN" to (minDollar ?: "-")),
            ),
        )
    }
}
