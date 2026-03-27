export type Theme = {
  id: string;
  colors: {
    textPrimary: string;
    textSecondary: string;
    textTertiary: string;

    layer0: string;
    layer1: string;
    layer2: string;
    layer3: string;
    layer4: string;
    layer5: string;
    layer6: string;
    layer7: string;

    purple: string;
    green: string;
    yellow: string;
    red: string;
    black: string;
    white: string;

    fadedPurple: string;
    fadedGreen: string;
    fadedRed: string;
    fadedYellow: string;

    borderDefault: string;
    borderDestructive: string;
    borderButton: string;

    gradientGrayStart: string;
    gradientGrayEnd: string;
    gradientGreenStart: string;
    gradientGreenEnd: string;
    gradientRedStart: string;
    gradientRedEnd: string;
  };
  fontSizes: {
    largest: number;
    larger: number;
    large: number;
    medium: number;
    small: number;
    smaller: number;
    smallest: number;
  };
  fonts: {
    minus: string;
    base: string;
    plus: string;
    number: string;
  };
};
