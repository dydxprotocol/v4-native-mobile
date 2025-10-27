package exchange.dydx.trading.integration.react

import com.facebook.react.bridge.LifecycleEventListener
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.module.annotations.ReactModule

interface SharedNativeModuleDelegate {
    fun onTrackingEvent(
        eventName: String,
        eventParams: Map<String, String>
    )
}

@ReactModule(name = SharedNativeModule.NAME)
internal class SharedNativeModule(
    private val reactContext: ReactApplicationContext
) : ReactContextBaseJavaModule(reactContext), LifecycleEventListener {
    companion object Companion {
        private const val NAME = "SharedNativeModule"
    }

    override fun getName(): String = NAME

    var delegate: SharedNativeModuleDelegate? = null

    init {
        reactContext.addLifecycleEventListener(this)
    }

    @ReactMethod
    fun onTrackingEvent(eventName: String, eventParams: ReadableMap) {
        val params: Map<String, String> = eventParams.toHashMap()
            .mapValues { it.value.toString() }
        delegate?.onTrackingEvent(eventName = eventName, eventParams = params)
    }

    override fun onHostDestroy() {
        print("Host is being destroyed, cleaning up resources.")
    }

    override fun onHostPause() {
        print("Host is paused, saving state if necessary.")
    }

    override fun onHostResume() {
        print("Host is resumed, ready to handle events.")
    }
}
