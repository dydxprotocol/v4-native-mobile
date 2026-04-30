package exchange.dydx.trading.feature.profile.components

import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import exchange.dydx.abacus.protocols.LocalizerProtocol
import exchange.dydx.dydxstatemanager.localizeWithParams
import exchange.dydx.trading.common.DydxViewModel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.delay
import java.time.Duration
import java.time.ZoneOffset
import java.time.ZonedDateTime
import java.time.format.TextStyle
import java.util.Locale
import javax.inject.Inject

@HiltViewModel
class DydxProfileRewardsViewModel @Inject constructor(
    val localizer: LocalizerProtocol,
) : ViewModel(), DydxViewModel {

    val state: Flow<DydxProfileRewardsView.ViewState?> = flow {
        while (true) {
            val now = ZonedDateTime.now(ZoneOffset.UTC)
            emit(
                DydxProfileRewardsView.ViewState(
                    localizer = localizer,
                    title = localizer.localize("APP.GENERAL.LIQUIDATION_REBATES"),
                    activeBadgeText = localizer.localize("APP.GENERAL.ACTIVE"),
                    bodyText = buildBodyText(),
                    countdownLabel = localizer.localizeWithParams(
                        path = "APP.REWARDS_SURGE_APRIL_2025.MONTH_COUNTDOWN",
                        params = mapOf("MONTH" to currentMonthName(now)),
                    ),
                    countdownText = formatCountdown(remainingUntilNextMonthUtc(now)),
                ),
            )
            delay(1000L)
        }
    }.distinctUntilChanged()

    private fun buildBodyText(): String {
        val body = localizer.localize("APP.REWARDS_SURGE_APRIL_2025.LIQUIDATION_REBATES_BODY")
        val subBody = localizer.localizeWithParams(
            path = "APP.REWARDS_SURGE_APRIL_2025.LIQUIDATION_REBATES_SUB_BODY",
            params = mapOf(
                "LOSS_REBATES_LINK" to localizer.localize("APP.REWARDS_SURGE_APRIL_2025.LOSS_REBATES"),
                "CHECK_ELIGIBILITY_LINK" to localizer.localize("APP.GENERAL.HERE"),
            ),
        )
        return "$body $subBody"
    }

    private fun currentMonthName(now: ZonedDateTime): String {
        return now.month.getDisplayName(TextStyle.FULL, Locale.ENGLISH)
    }

    private fun remainingUntilNextMonthUtc(now: ZonedDateTime): Duration {
        val nextMonthStart = now
            .plusMonths(1)
            .withDayOfMonth(1)
            .withHour(0)
            .withMinute(0)
            .withSecond(0)
            .withNano(0)
        val duration = Duration.between(now, nextMonthStart)
        return if (duration.isNegative) Duration.ZERO else duration
    }

    private fun formatCountdown(duration: Duration): String {
        val totalSeconds = duration.seconds
        val days = totalSeconds / 86_400
        val hours = (totalSeconds % 86_400) / 3_600
        val minutes = (totalSeconds % 3_600) / 60
        val seconds = totalSeconds % 60
        return "${days}d ${hours}h ${minutes}m ${seconds}s"
    }
}
