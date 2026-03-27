import React, {
  createContext,
  useContext,
  useState,
  useEffect,
  ReactNode,
} from "react";
import { Theme } from "../../rn_style/themes/theme";
import { darkTheme } from "../../rn_style/themes/darkTheme";
import { DydxTheme, getTheme } from "../../rn_style/themes/currentTheme";

type ThemeContextType = {
  theme: Theme;
  setTheme: (themeName: DydxTheme) => void;
};

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

type ThemeProviderProps = {
  children: ReactNode;
  initialTheme?: DydxTheme;
};

export const ThemeProvider: React.FC<ThemeProviderProps> = ({
  children,
  initialTheme = "dark",
}) => {
  // Initialize with current global theme
  const [theme, setThemeState] = useState<Theme>(getTheme(initialTheme));

  const setTheme = (themeName: DydxTheme) => {
    const newTheme = getTheme(themeName);
    setThemeState(newTheme);
  };

  return (
    <ThemeContext.Provider value={{ theme, setTheme }}>
      {children}
    </ThemeContext.Provider>
  );
};

export const useTheme = (): ThemeContextType => {
  const context = useContext(ThemeContext);
  if (context === undefined) {
    throw new Error("useTheme must be used within a ThemeProvider");
  }
  return context;
};
