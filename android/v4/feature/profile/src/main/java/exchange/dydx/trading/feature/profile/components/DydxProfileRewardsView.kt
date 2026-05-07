package exchange.dydx.trading.feature.profile.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.Icon
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import exchange.dydx.abacus.protocols.LocalizerProtocol
import exchange.dydx.platformui.designSystem.theme.ThemeColor
import exchange.dydx.platformui.designSystem.theme.ThemeFont
import exchange.dydx.platformui.designSystem.theme.ThemeShapes
import exchange.dydx.platformui.designSystem.theme.color
import exchange.dydx.platformui.designSystem.theme.dydxDefault
import exchange.dydx.platformui.designSystem.theme.themeColor
import exchange.dydx.platformui.designSystem.theme.themeFont
import exchange.dydx.platformui.theme.DydxThemedPreviewSurface
import exchange.dydx.platformui.theme.MockLocalizer
import exchange.dydx.trading.common.component.DydxComponent
import exchange.dydx.trading.feature.shared.R

@Preview
@Composable
fun Preview_DydxProfileRewardsView() {
    DydxThemedPreviewSurface {
        DydxProfileRewardsView.Content(Modifier, DydxProfileRewardsView.ViewState.preview)
    }
}

object DydxProfileRewardsView : DydxComponent {
    data class ViewState(
        val localizer: LocalizerProtocol,
        val title: String,
        val activeBadgeText: String,
        val bodyText: String,
        val countdownLabel: String,
        val countdownText: String,
        val onTapAction: (() -> Unit)? = null,
    ) {
        companion object {
            val preview = ViewState(
                localizer = MockLocalizer(),
                title = "Liquidation Rebates",
                activeBadgeText = "Active",
                bodyText = "With the Liquidation Rebate Program, eligible traders liquidated on non-BTC perpetual pairs have the opportunity to earn DYDX rebates on a portion of their losses. Reminder to claim previous loss rebates and check eligibility here.",
                countdownLabel = "Month May Countdown",
                countdownText = "0d 9h 51m 46s",
            )
        }
    }

    @Composable
    override fun Content(modifier: Modifier) {
        val viewModel: DydxProfileRewardsViewModel = hiltViewModel()

        val state = viewModel.state.collectAsStateWithLifecycle(initialValue = null).value
        Content(modifier, state)
    }

    @Composable
    fun Content(modifier: Modifier, state: ViewState?, @Suppress("UNUSED_PARAMETER") detailed: Boolean = false) {
        if (state == null) {
            return
        }

        Column(
            modifier = modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(14.dp))
                .background(color = ThemeColor.SemanticColor.layer_3.color)
                .clickable(enabled = state.onTapAction != null) { state.onTapAction?.invoke() },
        ) {
            Row(
                modifier = Modifier
                    .padding(horizontal = ThemeShapes.HorizontalPadding)
                    .padding(vertical = 12.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text(
                    text = state.title,
                    style = TextStyle.dydxDefault
                        .themeFont(fontSize = ThemeFont.FontSize.small)
                        .themeColor(foreground = ThemeColor.SemanticColor.text_secondary),
                    modifier = Modifier.weight(1f),
                )

                Text(
                    text = state.activeBadgeText,
                    style = TextStyle.dydxDefault
                        .themeFont(fontSize = ThemeFont.FontSize.mini)
                        .themeColor(foreground = ThemeColor.SemanticColor.color_green),
                    modifier = Modifier
                        .border(
                            width = 1.dp,
                            color = ThemeColor.SemanticColor.color_green.color,
                            shape = RoundedCornerShape(4.dp),
                        )
                        .padding(horizontal = 6.dp, vertical = 4.dp),
                )
            }

            Column(
                modifier = Modifier
                    .padding(horizontal = ThemeShapes.HorizontalPadding)
                    .padding(bottom = 16.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                Text(
                    text = state.bodyText,
                    style = TextStyle.dydxDefault
                        .themeFont(fontSize = ThemeFont.FontSize.small)
                        .themeColor(foreground = ThemeColor.SemanticColor.text_tertiary),
                )

                Row(
                    modifier = Modifier
                        .clip(RoundedCornerShape(20.dp))
                        .background(ThemeColor.SemanticColor.layer_4.color)
                        .padding(horizontal = 12.dp, vertical = 8.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Icon(
                        painter = painterResource(id = R.drawable.icon_clock),
                        contentDescription = null,
                        modifier = Modifier.size(14.dp),
                        tint = ThemeColor.SemanticColor.color_purple.color,
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = state.countdownLabel,
                        style = TextStyle.dydxDefault
                            .themeFont(fontSize = ThemeFont.FontSize.small)
                            .themeColor(foreground = ThemeColor.SemanticColor.color_purple),
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Text(
                        text = state.countdownText,
                        style = TextStyle.dydxDefault
                            .themeFont(fontSize = ThemeFont.FontSize.small)
                            .themeColor(foreground = ThemeColor.SemanticColor.text_primary),
                    )
                }
            }
        }
    }
}
