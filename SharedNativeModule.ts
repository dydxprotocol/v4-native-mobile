import { NativeModules } from 'react-native';

// Define type for native module
interface SharedNativeModuleType {
  onTrackingEvent: (eventName: string, eventParams: Record<string, string>) => void;
}

// Safely cast NativeModules
export const { SharedNativeModule } = NativeModules as {
  SharedNativeModule: SharedNativeModuleType;
};

