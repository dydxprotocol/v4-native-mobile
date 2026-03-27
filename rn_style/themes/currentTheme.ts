import { darkTheme } from "./darkTheme";
import { lightTheme } from "./lightTheme";
import { classicDarkTheme } from "./classicDarkTheme";

export type DydxTheme = "dark" | "light" | "classicDark";

export const setDydXTheme = (theme: string) => {
  switch (theme) {
    case "dark":
      currentTheme = darkTheme;
      break;
    case "light":
      currentTheme = lightTheme;
      break;
    case "classicDark":
      currentTheme = classicDarkTheme;
      break;
    default:
      throw new Error(`Unknown theme: ${theme}`);
  }
};

export const getTheme = (theme: DydxTheme) => {
  switch (theme) {
    case "dark":
      return darkTheme;
    case "light":
      return lightTheme;
    case "classicDark":
      return classicDarkTheme;
  }
};

export var currentTheme = darkTheme;
