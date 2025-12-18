import React, { useEffect, useState } from "react";
import { DeviceEventEmitter, SafeAreaView } from "react-native";
import { DydxTheme } from "../../rn_style/themes/currentTheme";
import { Leaderboard } from "../components/leaderboard";
import { ThemeProvider } from "../providers/themeProvider";

type LeaderboardScreenProps = {
  address: string | null;
  theme: DydxTheme;
};

export const LeaderboardScreen = ({
  address,
  theme,
}: LeaderboardScreenProps) => {
  const [currentAddress, setCurrentAddress] = useState<string | null>(address);

  useEffect(() => {
    // Listen for address changes from native
    const subscription = DeviceEventEmitter.addListener(
      "addressChanged",
      ({ address: newAddress }: { address: string | null }) => {
        setCurrentAddress(newAddress);
      }
    );

    return () => {
      subscription.remove();
    };
  }, []);

  return (
    <ThemeProvider initialTheme={theme}>
      <SafeAreaView>
        <Leaderboard address={currentAddress} />
      </SafeAreaView>
    </ThemeProvider>
  );
};
