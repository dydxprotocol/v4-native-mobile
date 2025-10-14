package exchange.dydx.trading.feature.profile.components

import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import exchange.dydx.abacus.output.LaunchIncentive
import exchange.dydx.abacus.output.LaunchIncentivePoints
import exchange.dydx.abacus.protocols.LocalizerProtocol
import exchange.dydx.dydxstatemanager.AbacusStateManagerProtocol
import exchange.dydx.trading.common.DydxViewModel
import exchange.dydx.trading.common.featureflags.DydxBoolFeatureFlag
import exchange.dydx.trading.common.featureflags.DydxFeatureFlags
import exchange.dydx.trading.common.featureflags.RemoteFlags
import exchange.dydx.trading.common.formatter.DydxFormatter
import exchange.dydx.trading.common.navigation.DydxRouter
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import javax.inject.Inject

@HiltViewModel
class DydxProfileLaunchIncentivesViewModel @Inject constructor(
    private val localizer: LocalizerProtocol,
    private val abacusStateManager: AbacusStateManagerProtocol,
    private val formatter: DydxFormatter,
    private val router: DydxRouter,
    private val featureFlags: DydxFeatureFlags,
    private val remoteFlags: RemoteFlags,
) : ViewModel(), DydxViewModel {
    val state: Flow<DydxProfileLaunchIncentivesView.ViewState?> =
        combine(
            abacusStateManager.state.launchIncentive,
            abacusStateManager.state.launchIncentivePoints,
        ) { launchIncentive, launchIncentivePoints ->
            createViewState(launchIncentive, launchIncentivePoints)
        }
            .distinctUntilChanged()

    private fun createViewState(
        launchIncentive: LaunchIncentive?,
        launchIncentivePoints: LaunchIncentivePoints?
    ): DydxProfileLaunchIncentivesView.ViewState {
        val season = launchIncentive?.currentSeason
        val points = formatter.raw(
            season?.let { launchIncentivePoints?.points?.get(it) }?.incentivePoints,
            6
        )
        return DydxProfileLaunchIncentivesView.ViewState(
            localizer = localizer,
            season = season,
            points = points,
            aboutAction = {
                val url = abacusStateManager.environment?.links?.incentiveProgram
                if (url != null) {
                    router.navigateTo(url)
                }
            },
            leaderboardAction = {
                val url = abacusStateManager.environment?.links?.incentiveProgramLeaderboard
                if (url != null) {
                    router.navigateTo(url)
                }
            },
            isSep2025 = featureFlags.isFeatureEnabled(DydxBoolFeatureFlag.ff_rewards_sep_2025),
            rewards_dollar_amount = remoteFlags.getParamStoreValue("rewards_dollar_amount", "-"),
            rebate_percent = remoteFlags.getParamStoreValue("rewards_fee_rebate_percent", "-"),
            )
    }
}
