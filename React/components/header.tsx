import React from "react";
import { Image, TouchableOpacity, View } from "react-native";
import { ThemedText } from "./ui/themedText";
import { ChevronLeft } from "lucide-react-native";

import { LeaderboardNativeModule } from "../../LeaderboardNativeModule";
import { useTheme } from "../providers/themeProvider";
import Svg, { SvgXml } from "react-native-svg";

type HeaderProps = {
  title: string;
};

export const Header = ({ title }: HeaderProps) => {
  const { theme } = useTheme();

  return (
    <View
      style={{
        height: 64,
        width: "100%",
        alignItems: "center",
        justifyContent: "center",
        position: "relative",
      }}
    >
      <TouchableOpacity
        onPress={() => LeaderboardNativeModule.onNavigateBack()}
        style={{ position: "absolute", left: 16 }}
      >
        <Image
          source={require("../../rn_style/assets/chevron_left.png")}
          style={{ width: 20, height: 20, tintColor: theme.colors.textPrimary }}
        />
      </TouchableOpacity>
      <ThemedText fontSize="largest">{title}</ThemedText>
    </View>
  );
};
