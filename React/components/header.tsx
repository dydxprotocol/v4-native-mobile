import React from "react";
import { View } from "react-native";

type HeaderProps = {
  title: string;
  onBack: () => void;
};

export const Header = ({ title, onBack }: HeaderProps) => {
  return <View></View>;
};
