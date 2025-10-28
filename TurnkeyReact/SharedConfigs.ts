

export type TurnkeyConfigs = {
  googleClientId: string,
  appScheme: string,
  turnkeyUrl: string,
  turnkeyOrgId: string,
  backendApiUrl: string,
  deploymentUri: string,
  tosUrl: string,
  privacyUrl: string,
  theme: "light" | "dark" | "classicDark" | undefined,
  enableAppleLoginIn: boolean,
  isSamsungDevice: boolean,
};