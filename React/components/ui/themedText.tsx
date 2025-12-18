import React from "react";
import { Text } from "react-native";
import { useTheme } from "../../providers/themeProvider";
import { Theme } from "../../../rn_style/themes/theme";

type ThemedTextProps = {
  color?: keyof Theme["colors"];
  fontSize?: keyof Theme["fontSizes"];
  fontFamily?: keyof Theme["fonts"];
  children: string;
};

export const ThemedText = ({
  children,
  color = "textPrimary",
  fontSize = "medium",
  fontFamily = "base",
}: ThemedTextProps) => {
  const { theme } = useTheme();

  return (
    <Text
      style={{
        color: theme.colors[color],
        fontSize: theme.fontSizes[fontSize],
        fontFamily: theme.fonts[fontFamily],
      }}
    >
      {children}
    </Text>
  );
};
