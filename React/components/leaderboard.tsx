import React, { useState } from "react";
import { View } from "react-native";
import { useTheme } from "../providers/themeProvider";
import { Header } from "./header";
import { useLocalizedString } from "../../useLocalizedString";
import { SceneMap, TabView } from "react-native-tab-view";
import { ThemedText } from "./ui/themedText";

type LeaderboardProps = {
  address: string | null;
};

const renderScene = SceneMap({
  fees: () => (
    <View>
      <ThemedText>Fees</ThemedText>
    </View>
  ),
  rebates: () => (
    <View>
      <ThemedText>Rebates</ThemedText>
    </View>
  ),
});

const routes = [
  { key: "fees", title: "PNL Competition" },
  { key: "rebates", title: "Rebates" },
];

export const Leaderboard = ({ address }: LeaderboardProps) => {
  const { theme } = useTheme();
  const [index, setIndex] = useState(0);

  const leaderboardTitle = useLocalizedString("APP.GENERAL.TRADING_REWARDS");
  return (
    <View
      style={{
        height: "100%",
        width: "100%",
        backgroundColor: theme.colors.layer1,
      }}
    >
      <Header title={leaderboardTitle ?? ""} />
      <TabView
        navigationState={{ index, routes }}
        renderScene={renderScene}
        onIndexChange={setIndex}
      />
    </View>
  );
};
