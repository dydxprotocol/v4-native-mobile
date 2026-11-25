package exchange.dydx.trading.feature.shared.banner

import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import exchange.dydx.abacus.output.account.InjectiveBalances
import exchange.dydx.abacus.protocols.LocalizerProtocol
import exchange.dydx.dydxstatemanager.AbacusStateManagerProtocol
import exchange.dydx.trading.common.DydxViewModel
import exchange.dydx.trading.common.formatter.DydxFormatter
import exchange.dydx.trading.common.navigation.DydxRouter
import exchange.dydx.trading.common.navigation.TransferRoutes
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map
import javax.inject.Inject

private const val USDC_MIGRATION_BLOG_URL = "https://www.dydx.xyz/blog/usdc-migration-to-injective"

@HiltViewModel
class DydxUsdcMigrationBannerViewModel @Inject constructor(
    private val localizer: LocalizerProtocol,
    private val abacusStateManager: AbacusStateManagerProtocol,
    private val formatter: DydxFormatter,
    private val router: DydxRouter,
) : ViewModel(), DydxViewModel {

    val state: Flow<DydxUsdcMigrationBannerView.ViewState?> =
        abacusStateManager.state.account
            .map { it?.injectiveBalances }
            .distinctUntilChanged()
            .map { createViewState(it) }

    private fun createViewState(balances: InjectiveBalances?): DydxUsdcMigrationBannerView.ViewState =
        if (balances?.hasPendingDeposit == true) {
            // TODO(localization): move the copy to v4-localization keys
            DydxUsdcMigrationBannerView.ViewState(
                text = "${formatter.raw(balances.usdc, digits = 2)} USDC is waiting on Injective. Send it to dYdX to start trading.",
                linkText = "Complete deposit",
                onTapAction = {
                    router.navigateTo(
                        route = TransferRoutes.transfer_deposit_injective,
                        presentation = DydxRouter.Presentation.Modal,
                    )
                },
            )
        } else {
            DydxUsdcMigrationBannerView.ViewState(
                text = localizer.localize("APP.NOTIFICATIONS.USDC_MIGRATION"),
                linkText = localizer.localize("APP.GENERAL.LEARN_MORE"),
                onTapAction = {
                    router.navigateTo(route = USDC_MIGRATION_BLOG_URL)
                },
            )
        }
}
