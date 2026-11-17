package exchange.dydx.trading.feature.shared.banner

import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import exchange.dydx.abacus.protocols.LocalizerProtocol
import exchange.dydx.trading.common.DydxViewModel
import exchange.dydx.trading.common.navigation.DydxRouter
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flowOf
import javax.inject.Inject

private const val USDC_MIGRATION_BLOG_URL = "https://www.dydx.xyz/blog/usdc-migration-to-injective"

@HiltViewModel
class DydxUsdcMigrationBannerViewModel @Inject constructor(
    private val localizer: LocalizerProtocol,
    private val router: DydxRouter,
) : ViewModel(), DydxViewModel {

    val state: Flow<DydxUsdcMigrationBannerView.ViewState?> = flowOf(createViewState())

    private fun createViewState(): DydxUsdcMigrationBannerView.ViewState =
        DydxUsdcMigrationBannerView.ViewState(
            text = localizer.localize("APP.NOTIFICATIONS.USDC_MIGRATION"),
            linkText = localizer.localize("APP.GENERAL.LEARN_MORE"),
            onTapAction = {
                router.navigateTo(route = USDC_MIGRATION_BLOG_URL)
            },
        )
}
