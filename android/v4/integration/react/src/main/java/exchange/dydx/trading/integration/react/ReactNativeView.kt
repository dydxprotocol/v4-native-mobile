package exchange.dydx.trading.integration.react

import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.os.Bundle
import android.view.ViewGroup
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.viewinterop.AndroidView
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.compose.LocalLifecycleOwner
import com.facebook.react.ReactApplication
import com.facebook.react.ReactRootView
import com.facebook.react.modules.core.DefaultHardwareBackBtnHandler
import exchange.dydx.abacus.protocols.LocalizerProtocol
import exchange.dydx.abacus.protocols.localizeWithParams

@Composable
fun ReactNativeView(
    modifier: Modifier = Modifier,
    moduleName: String, // matches AppRegistry.registerComponent(...)
    initialProps: Map<String, Any>? = null, // Optional, initial properties for the RN app
    localizerEntries: List<LocalizerEntry> = emptyList(), // Optional, for localization
    localizer: LocalizerProtocol,
) {
    val context = LocalContext.current
    val activity = remember(context) { context.findActivity() }
    val lifecycleOwner = LocalLifecycleOwner.current

    // Get the shared ReactInstanceManager from the Application's ReactNativeHost
    val reactInstanceManager = remember {
        val app = context.applicationContext as ReactApplication
        app.reactNativeHost.reactInstanceManager
    }

    // Keep one ReactRootView instance
    val reactRootView = remember {
        ReactRootView(context).apply {
            isFocusable = true
            isFocusableInTouchMode = true
            descendantFocusability = ViewGroup.FOCUS_AFTER_DESCENDANTS

            // Starting the RN app inside this view
            val initialPropsWithLocalizationData = Bundle()
            initialProps?.forEach { (key, value) ->
                when (value) {
                    is String -> initialPropsWithLocalizationData.putString(key, value)
                    is Int -> initialPropsWithLocalizationData.putInt(key, value)
                    is Boolean -> initialPropsWithLocalizationData.putBoolean(key, value)
                    is Double -> initialPropsWithLocalizationData.putDouble(key, value)
                    is Float -> initialPropsWithLocalizationData.putFloat(key, value)
                    is Long -> initialPropsWithLocalizationData.putLong(key, value)
                    else -> error("Unsupported prop type: ${value?.let { it::class.java }} for key: $key")
                }
            }
            val localizedValues = Bundle()
            localizerEntries.forEach { entry ->
                val localized = entry.localized ?: localizer.localizeWithParams(path = entry.path, params = entry.params)
                localizedValues.putString(entry.path, localized)
            }
            initialPropsWithLocalizationData.putBundle("strings", localizedValues)

            startReactApplication(reactInstanceManager, moduleName, initialPropsWithLocalizationData)
        }
    }

    AndroidView(
        factory = { reactRootView },
        modifier = modifier,
    )

    // Forward lifecycle
    DisposableEffect(lifecycleOwner, activity) {
        val observer = LifecycleEventObserver { _, event ->
            when (event) {
                Lifecycle.Event.ON_RESUME ->
                    reactInstanceManager.onHostResume(
                        activity,
                        object : DefaultHardwareBackBtnHandler {
                            override fun invokeDefaultOnBackPressed() {
                                activity.onBackPressed() // .onBackPressedDispatcher.onBackPressed()
                            }
                        },
                    )

                Lifecycle.Event.ON_PAUSE -> reactInstanceManager.onHostPause(activity)
                Lifecycle.Event.ON_DESTROY -> reactInstanceManager.onHostDestroy(activity)
                else -> Unit
            }
        }
        lifecycleOwner.lifecycle.addObserver(observer)

        onDispose {
            reactRootView.unmountReactApplication()
            lifecycleOwner.lifecycle.removeObserver(observer)
        }
    }
}

// Helper to find the Activity from a Context
private tailrec fun Context.findActivity(): Activity {
    return when (this) {
        is Activity -> this
        is ContextWrapper -> baseContext.findActivity()
        else -> error("No Activity in context chain")
    }
}

data class LocalizerEntry(
    val path: String,
    val params: Map<String, String>? = null,
    val localized: String? = null // This takes precedence over path and params
)
