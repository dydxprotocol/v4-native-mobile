import { NativeModules } from "react-native";

interface LeaderboardNativeModuleType {
  onNavigateBack: () => void;
}

export const { LeaderboardNativeModule } = NativeModules as {
  LeaderboardNativeModule: LeaderboardNativeModuleType;
};
