import React from "react";
import { TouchableOpacity, Text, View } from "react-native";
import { useTheme } from "../providers/themeProvider";
import { LeaderboardNativeModule } from "../../LeaderboardNativeModule";

type LeaderboardProps = {
  address: string | null;
};

export const Leaderboard = ({ address }: LeaderboardProps) => {
  const { theme } = useTheme();

  return (
    <View
      style={{
        paddingTop: 100,
        height: "100%",
        width: "100%",
        backgroundColor: theme.colors.layer0,
      }}
    >
      <Text
        style={{ color: theme.colors.purple, fontSize: 20, fontWeight: "bold" }}
      >
        This is the leader
      </Text>
      <TouchableOpacity
        style={{ backgroundColor: theme.colors.purple }}
        onPress={() => LeaderboardNativeModule.onNavigateBack()}
      >
        <Text style={{ color: theme.colors.white }}>Test</Text>
      </TouchableOpacity>
      {address ? (
        <Text
          style={{
            color: theme.colors.fadedGreen,
            fontSize: 16,
            marginTop: 20,
          }}
        >
          Address: {address}
        </Text>
      ) : (
        <Text
          style={{
            color: theme.colors.fadedGreen,
            fontSize: 16,
            marginTop: 20,
          }}
        >
          No address
        </Text>
      )}
    </View>
  );
};
