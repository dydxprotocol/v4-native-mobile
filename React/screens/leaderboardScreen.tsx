import React, { useEffect, useState } from "react";
import { Text, View, DeviceEventEmitter } from "react-native";
import { ThemeProvider } from "../providers/themeProvider";
import { DydxTheme } from "../../rn_style/themes/currentTheme";
import { Leaderboard } from "../components/leaderboard";

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
      <Leaderboard address={currentAddress} />
    </ThemeProvider>
  );
};
