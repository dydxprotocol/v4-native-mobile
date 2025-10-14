package exchange.dydx.trading.feature.vault.depositwithdraw.deposit

import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import exchange.dydx.abacus.functional.vault.VaultFormValidationResult
import exchange.dydx.abacus.output.account.Subaccount
import exchange.dydx.abacus.protocols.LocalizerProtocol
import exchange.dydx.abacus.protocols.ParserProtocol
import exchange.dydx.dydxstatemanager.AbacusStateManagerProtocol
import exchange.dydx.dydxstatemanager.clientState.wallets.DydxWalletInstance
import exchange.dydx.trading.common.DydxViewModel
import exchange.dydx.trading.common.formatter.DydxFormatter
import exchange.dydx.trading.common.navigation.DydxRouter
import exchange.dydx.trading.common.navigation.OnboardingRoutes
import exchange.dydx.trading.common.navigation.VaultRoutes
import exchange.dydx.trading.feature.shared.analytics.VaultAnalytics
import exchange.dydx.trading.feature.shared.analytics.VaultAnalyticsInputType
import exchange.dydx.trading.feature.shared.views.AmountText
import exchange.dydx.trading.feature.shared.views.InputCtaButton
import exchange.dydx.trading.feature.vault.VaultInputStage
import exchange.dydx.trading.feature.vault.VaultInputState
import exchange.dydx.trading.feature.vault.depositwithdraw.components.VaultAmountBox
import exchange.dydx.trading.feature.vault.depositwithdraw.createViewModel
import exchange.dydx.trading.feature.vault.displayedError
import exchange.dydx.trading.feature.vault.hasBlockingError
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import java.math.RoundingMode
import javax.inject.Inject

@HiltViewModel
class DydxVaultDepositViewModel @Inject constructor(
    private val localizer: LocalizerProtocol,
    private val abacusStateManager: AbacusStateManagerProtocol,
    private val formatter: DydxFormatter,
    private val parser: ParserProtocol,
    private val inputState: VaultInputState,
    private val router: DydxRouter,
    private val vaultAnalytics: VaultAnalytics,
) : ViewModel(), DydxViewModel {

    val state: Flow<DydxVaultDepositView.ViewState?> =
        combine(
            abacusStateManager.state.selectedSubaccount,
            inputState.result,
            abacusStateManager.state.currentWallet,
        ) { subaccount, result, currentWallet ->
            createViewState(subaccount, result, currentWallet)
        }

    private fun createViewState(
        subaccount: Subaccount?,
        result: VaultFormValidationResult?,
        currentWallet: DydxWalletInstance?
    ): DydxVaultDepositView.ViewState {
        val roundedFreeCollateral = formatter.decimalLocaleAgnostic(subaccount?.freeCollateral?.current, digits = 2, rounding = RoundingMode.DOWN)
        return DydxVaultDepositView.ViewState(
            localizer = localizer,
            transferAmount = VaultAmountBox.ViewState(
                localizer = localizer,
                formatter = formatter,
                parser = parser,
                value = parser.asString(inputState.amount.value),
                maxAmount = parser.asDouble(roundedFreeCollateral),
                maxAction = {
                    inputState.amount.value = parser.asDouble(roundedFreeCollateral)
                },
                title = localizer.localize("APP.VAULTS.ENTER_AMOUNT_TO_DEPOSIT"),
                footer = localizer.localize("APP.GENERAL.CROSS_FREE_COLLATERAL"),
                footerBefore = AmountText.ViewState(
                    localizer = localizer,
                    formatter = formatter,
                    amount = parser.asDouble(roundedFreeCollateral),
                    tickSize = 2,
                    requiresPositive = true,
                ),
                footerAfter = AmountText.ViewState(
                    localizer = localizer,
                    formatter = formatter,
                    amount = result?.summaryData?.freeCollateral,
                    tickSize = 2,
                    requiresPositive = true,
                ),
                onEditAction = { amount ->
                    inputState.amount.value = parser.asDouble(amount)
                },
            ),
            validation = result?.displayedError?.createViewModel(localizer),
            ctaButton = InputCtaButton.ViewState(
                localizer = localizer,
                ctaButtonState = if (result?.hasBlockingError == true || inputState.amount.value == null) {
                    InputCtaButton.State.Disabled(localizer.localize("APP.VAULTS.PREVIEW_DEPOSIT"))
                } else {
                    if (currentWallet == null) {
                        InputCtaButton.State.Enabled(localizer.localize("APP.TURNKEY_ONBOARD.SIGN_IN_TITLE"))
                    } else {
                        InputCtaButton.State.Enabled(localizer.localize("APP.VAULTS.PREVIEW_DEPOSIT"))
                    }
                },
                ctaAction = {
                    if (currentWallet == null) {
                        router.navigateTo(
                            route = OnboardingRoutes.welcome,
                            presentation = DydxRouter.Presentation.Modal,
                        )
                        return@ViewState
                    }
                    inputState.stage.value = VaultInputStage.CONFIRM
                    router.navigateTo(route = VaultRoutes.confirmation, presentation = DydxRouter.Presentation.Push)

                    vaultAnalytics.logPreview(
                        type = VaultAnalyticsInputType.DEPOSIT,
                        amount = inputState.amount.value ?: 0.0,
                    )
                },
            ),
        )
    }
}
