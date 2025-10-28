package exchange.dydx.trading.integration.react

import com.facebook.react.ReactPackage
import exchange.dydx.trading.integration.analytics.tracking.Tracking
import exchange.dydx.utilities.utils.Logging
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

class SharedReactBridge @Inject constructor(
    private val logger: Logging,
    private val tracker: Tracking,
) : SharedNativeModuleDelegate {
    companion object {
        val reactPackage: ReactPackage = SharedReactPackage()
    }

    private val _isInitialized = MutableStateFlow(false)
    val isInitialized: StateFlow<Boolean> = _isInitialized.asStateFlow()

    private lateinit var context: com.facebook.react.bridge.ReactContext

    fun updateContext(context: com.facebook.react.bridge.ReactContext) {
        this.context = context
        _isInitialized.value = true

        val sharedNativeModule = context.getNativeModule(SharedNativeModule::class.java)
        sharedNativeModule?.delegate = this
    }

    override fun trackEvent(
        eventName: String,
        eventParams: Map<String, String>
    ) {
        tracker.log(event = eventName, data = eventParams)
    }
}
