package exchange.dydx.trading.feature.transfer.injective

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import exchange.dydx.platformui.components.buttons.PlatformButton
import exchange.dydx.platformui.components.buttons.PlatformButtonState
import exchange.dydx.platformui.components.icons.PlatformImage
import exchange.dydx.platformui.designSystem.theme.ThemeColor
import exchange.dydx.platformui.designSystem.theme.ThemeFont
import exchange.dydx.platformui.designSystem.theme.ThemeShapes
import exchange.dydx.platformui.designSystem.theme.color
import exchange.dydx.platformui.designSystem.theme.dydxDefault
import exchange.dydx.platformui.designSystem.theme.themeColor
import exchange.dydx.platformui.designSystem.theme.themeFont
import exchange.dydx.platformui.theme.DydxThemedPreviewSurface
import exchange.dydx.trading.common.component.DydxComponent
import exchange.dydx.trading.feature.shared.R
import exchange.dydx.trading.feature.shared.views.HeaderView

@Preview
@Composable
fun Preview_DydxInjectiveDepositView_Ready() {
    DydxThemedPreviewSurface {
        DydxInjectiveDepositView.Content(Modifier, DydxInjectiveDepositView.ViewState.preview)
    }
}

@Preview
@Composable
fun Preview_DydxInjectiveDepositView_LargeAmount() {
    DydxThemedPreviewSurface {
        DydxInjectiveDepositView.Content(
            Modifier,
            DydxInjectiveDepositView.ViewState.preview.copy(amount = "123,456,789.12"),
        )
    }
}

@Preview
@Composable
fun Preview_DydxInjectiveDepositView_Sending() {
    DydxThemedPreviewSurface {
        DydxInjectiveDepositView.Content(
            Modifier,
            DydxInjectiveDepositView.ViewState.preview.copy(status = DydxInjectiveDepositView.Status.Sending, amount = "1.00"),
        )
    }
}

@Preview
@Composable
fun Preview_DydxInjectiveDepositView_Failed() {
    DydxThemedPreviewSurface {
        DydxInjectiveDepositView.Content(
            Modifier,
            DydxInjectiveDepositView.ViewState.preview.copy(
                status = DydxInjectiveDepositView.Status.Failed,
                errorMessage = "Not enough INJ to pay for gas. Send at least 0.00045 INJ to inj17w0adeg64ky0daxwd2ugyuneellmjgnxf5vkec.",
            ),
        )
    }
}

@Preview
@Composable
fun Preview_DydxInjectiveDepositView_Sent() {
    DydxThemedPreviewSurface {
        DydxInjectiveDepositView.Content(
            Modifier,
            DydxInjectiveDepositView.ViewState.preview.copy(status = DydxInjectiveDepositView.Status.Sent),
        )
    }
}

@Preview
@Composable
fun Preview_DydxInjectiveDepositView_Empty() {
    DydxThemedPreviewSurface {
        DydxInjectiveDepositView.Content(
            Modifier,
            DydxInjectiveDepositView.ViewState.preview.copy(status = DydxInjectiveDepositView.Status.Empty, amount = null),
        )
    }
}

object DydxInjectiveDepositView : DydxComponent {
    enum class Status { Empty, Ready, Sending, Failed, Sent }

    data class ViewState(
        val status: Status,
        val amount: String?,
        val errorMessage: String? = null,
        val sendAction: () -> Unit = {},
        val closeAction: () -> Unit = {},
    ) {
        companion object {
            val preview = ViewState(
                status = Status.Ready,
                amount = "1,250.00",
            )
        }
    }

    @Composable
    override fun Content(modifier: Modifier) {
        val viewModel: DydxInjectiveDepositViewModel = hiltViewModel()

        val state = viewModel.state.collectAsStateWithLifecycle(initialValue = null).value
        Content(modifier, state)
    }

    // TODO(localization): move the copy in this view to v4-localization keys
    @Composable
    fun Content(modifier: Modifier, state: ViewState?) {
        if (state == null) {
            return
        }

        val title = if (state.status == Status.Sent) "USDC sent to dYdX" else "Complete your deposit"
        val body = when (state.status) {
            Status.Empty -> "No USDC is waiting on Injective."
            Status.Ready, Status.Sending, Status.Failed ->
                "${state.amount ?: "--"} USDC is waiting on Injective. Send it to dYdX to start trading."
            Status.Sent -> "It will reach your trading account in a few moments."
        }
        val buttonText = when (state.status) {
            Status.Ready -> "Send USDC to dYdX"
            Status.Sending -> "Sending…"
            Status.Failed -> "Try again"
            Status.Empty, Status.Sent -> "Done"
        }
        val isSendAction = state.status == Status.Ready || state.status == Status.Failed
        val isFailed = state.status == Status.Failed

        Column(
            modifier = modifier
                .fillMaxWidth()
                .themeColor(ThemeColor.SemanticColor.layer_3),
        ) {
            HeaderView(
                title = "",
                closeAction = state.closeAction,
            )

            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = ThemeShapes.HorizontalPadding)
                    .padding(bottom = ThemeShapes.VerticalPadding * 2),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(24.dp),
            ) {
                Box(
                    modifier = Modifier
                        .clip(CircleShape)
                        .themeColor(ThemeColor.SemanticColor.layer_4)
                        .padding(20.dp),
                ) {
                    PlatformImage(
                        icon = if (isFailed) R.drawable.icon_warning else R.drawable.icon_transfer_deposit,
                        modifier = Modifier.size(32.dp),
                        colorFilter = ColorFilter.tint(
                            if (isFailed) ThemeColor.SemanticColor.color_red.color else ThemeColor.SemanticColor.color_purple.color,
                        ),
                    )
                }

                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(8.dp),
                ) {
                    Text(
                        text = title,
                        style = TextStyle.dydxDefault
                            .themeFont(fontType = ThemeFont.FontType.plus, fontSize = ThemeFont.FontSize.large)
                            .themeColor(foreground = ThemeColor.SemanticColor.text_primary),
                        textAlign = TextAlign.Center,
                    )
                    Text(
                        text = body,
                        style = TextStyle.dydxDefault
                            .themeFont(fontSize = ThemeFont.FontSize.small)
                            .themeColor(foreground = ThemeColor.SemanticColor.text_tertiary),
                        textAlign = TextAlign.Center,
                    )
                    if (isFailed && state.errorMessage != null) {
                        Text(
                            text = state.errorMessage,
                            style = TextStyle.dydxDefault
                                .themeFont(fontSize = ThemeFont.FontSize.small)
                                .themeColor(foreground = ThemeColor.SemanticColor.color_red),
                            textAlign = TextAlign.Center,
                        )
                    }
                }

                PlatformButton(
                    modifier = Modifier.fillMaxWidth(),
                    text = buttonText,
                    state = if (state.status == Status.Sending) PlatformButtonState.Disabled else PlatformButtonState.Primary,
                ) {
                    if (isSendAction) state.sendAction() else state.closeAction()
                }
            }
        }
    }
}
