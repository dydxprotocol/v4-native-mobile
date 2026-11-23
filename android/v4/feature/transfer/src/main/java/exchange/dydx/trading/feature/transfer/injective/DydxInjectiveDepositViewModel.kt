package exchange.dydx.trading.feature.transfer.injective

import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import exchange.dydx.dydxstatemanager.AbacusStateManagerProtocol
import exchange.dydx.trading.common.DydxViewModel
import exchange.dydx.trading.common.formatter.DydxFormatter
import exchange.dydx.trading.common.navigation.DydxRouter
import exchange.dydx.trading.feature.transfer.injective.DydxInjectiveDepositView.Status
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map
import javax.inject.Inject

@HiltViewModel
class DydxInjectiveDepositViewModel @Inject constructor(
    private val abacusStateManager: AbacusStateManagerProtocol,
    private val formatter: DydxFormatter,
    private val router: DydxRouter,
) : ViewModel(), DydxViewModel {

    private data class Submission(val status: Status, val errorMessage: String? = null)

    private val submission = MutableStateFlow<Submission?>(null)

    val state: Flow<DydxInjectiveDepositView.ViewState?> =
        combine(
            abacusStateManager.state.account
                .map { it?.injectiveBalances?.usdc ?: 0.0 }
                .distinctUntilChanged(),
            submission,
        ) { usdc, submission ->
            DydxInjectiveDepositView.ViewState(
                status = submission?.status ?: if (usdc > 0.0) Status.Ready else Status.Empty,
                amount = formatter.raw(usdc, digits = 2),
                errorMessage = submission?.errorMessage,
                sendAction = { send() },
                closeAction = { router.navigateBack() },
            )
        }

    private fun send() {
        submission.value = Submission(Status.Sending)
        abacusStateManager.commitInjectiveDeposit { success, error, _ ->
            submission.value = if (success) {
                Submission(Status.Sent)
            } else {
                // TODO(localization): show error?.localizedMessage once the gas sponsorship error keys exist
                Submission(Status.Failed, error?.message ?: "Something went wrong. Please try again.")
            }
        }
    }
}
