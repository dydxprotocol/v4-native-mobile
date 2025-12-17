import React, { useEffect } from "react";
import { Text, View } from "react-native";

export const Leaderboard = () => {
  useEffect(() => {
    console.log("MOUNT");

    return () => {
      console.log("UNMOUNT");
    };
  }, []);

  return (
    <View
      style={{
        paddingTop: 100,
        height: "100%",
        width: "100%",
        backgroundColor: "red",
      }}
    >
      <Text style={{ color: "white", fontSize: 20, fontWeight: "bold" }}>
        This is the leaderboardkl
      </Text>
    </View>
  );
};
