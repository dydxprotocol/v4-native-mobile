package exchange.dydx.trading.feature.shared.banner

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.Icon
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import exchange.dydx.platformui.designSystem.theme.ThemeColor
import exchange.dydx.platformui.designSystem.theme.ThemeFont
import exchange.dydx.platformui.designSystem.theme.color
import exchange.dydx.platformui.designSystem.theme.dydxDefault
import exchange.dydx.platformui.designSystem.theme.themeColor
import exchange.dydx.platformui.designSystem.theme.themeFont
import exchange.dydx.platformui.theme.DydxThemedPreviewSurface
import exchange.dydx.trading.common.component.DydxComponent
import exchange.dydx.trading.feature.shared.R

@Preview
@Composable
fun Preview_DydxUsdcMigrationBannerView() {
    DydxThemedPreviewSurface {
        DydxUsdcMigrationBannerView.Content(
            Modifier,
            DydxUsdcMigrationBannerView.ViewState.preview,
        )
    }
}

object DydxUsdcMigrationBannerView : DydxComponent {
    data class ViewState(
        val text: String,
        val linkText: String? = null,
        val onTapAction: () -> Unit = {},
    ) {
        companion object {
            val preview = ViewState(
                text = "Upcoming USDC migration from Noble to Injective.",
                linkText = "Learn more",
            )
        }
    }

    @Composable
    override fun Content(modifier: Modifier) {
        val viewModel: DydxUsdcMigrationBannerViewModel = hiltViewModel()

        val state = viewModel.state.collectAsStateWithLifecycle(initialValue = null).value
        Content(modifier, state)
    }

    @Composable
    fun Content(modifier: Modifier, state: ViewState?) {
        if (state == null) {
            return
        }

        val accentColor = ThemeColor.SemanticColor.color_purple.color
        val message = buildAnnotatedString {
            append(state.text)
            state.linkText?.let { linkText ->
                append(" ")
                withStyle(SpanStyle(color = accentColor)) {
                    append(linkText)
                }
            }
        }

        Row(
            modifier = modifier
                .height(IntrinsicSize.Min)
                .clip(RoundedCornerShape(8.dp))
                .background(color = ThemeColor.SemanticColor.layer_3.color)
                .clickable { state.onTapAction() },
            horizontalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            Box(
                modifier = Modifier
                    .width(4.dp)
                    .fillMaxHeight()
                    .background(color = accentColor),
            )

            Icon(
                painter = painterResource(id = R.drawable.icon_info),
                contentDescription = null,
                modifier = Modifier
                    .padding(top = 10.dp)
                    .size(16.dp),
                tint = accentColor,
            )

            Text(
                text = message,
                modifier = Modifier
                    .weight(1f)
                    .padding(top = 8.dp, bottom = 8.dp, end = 12.dp),
                style = TextStyle.dydxDefault
                    .themeFont(fontSize = ThemeFont.FontSize.small)
                    .themeColor(foreground = ThemeColor.SemanticColor.text_primary),
            )
        }
    }
}
