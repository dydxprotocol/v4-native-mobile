import { NativeModules } from 'react-native';

// Define type for native module
interface SharedNativeModuleType {
  trackEvent: (eventName: string, eventParams: Record<string, string>) => void;
  localize: (path: string, params?: Record<string, string>) => Promise<string>;
}

// Safely cast NativeModules
export const { SharedNativeModule } = NativeModules as {
  SharedNativeModule: SharedNativeModuleType;
};

