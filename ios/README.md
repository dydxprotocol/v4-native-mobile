<div align="center">
  <img src='https://github.com/dydxprotocol/v4-native-mobile/blob/main/ios/dydxV4/dydxV4/Assets.xcassets/AppIcon.appiconset/App%20icon%403x.png' alt='icon'  width="100"  height="100" />
</div>
<h1 align="center">v4-native-mobile: iOS</h1>

<div align="center">
  <a href='https://github.com/dydxprotocol/v4-native-main/blob/main/LICENSE'>
    <img src='https://img.shields.io/badge/License-AGPL_v3-blue.svg' alt='License' />
  </a>
</div>

This is the native iOS app for dYdX v4.

# Repo Dependencies

### v4-abacus

This project requires the latest packages from v4-abacus.

To update the app to the latest v4-abacus:

```zsh
cd v4-native-mobile/ios/scripts
./bump_abacus.sh 
```

### v4-client

This project requires the latest packages from v4-client.

To update the app to the latest v4-client:

```zsh
cd v4-native-mobile/ios/scripts
./update_client_api.sh 
```

### v4-localization and v4-web

This project requires v4-localization

https://github.com/dydxprotocol/v4-localization

This project requires v4-web

https://github.com/dydxprotocol/v4-web

The Xcode project expects those two repos to be cloned side-by-side to the main mobile repo.

Other dependencies are specified by the Cocoapods and Swift Package Manager configurations in the project.

# API Keys & Secrets
Unzip the `secrets.zip` from the `iOS Secrets` vault in the dYdX 1Password account. Ask a team member for access.
Add the `secrets/` folder to the v4-native-mobile/ios/scripts folder.

> `mv {REPLACE_WITH_PATH_TO_UNZIPPED}/secrets {REPLACE_WITH_REPO}/scripts`

# Tools Setup

Always use latest Xcode.
https://apps.apple.com/us/app/xcode/id497799835?mt=12

Install dYdX code template with the following script

```zsh
cd v4-native-mobile/ios/scripts
./install_templates.sh 
```

_______
*By using, recording, referencing, or downloading (i.e., any “action”) any information contained on this page or in any dYdX Trading Inc. ("dYdX") database or documentation, you hereby and thereby agree to the [v4 Terms of Use](https://dydx.exchange/v4-terms) and [Privacy Policy](https://dydx.exchange/privacy) governing such information, and you agree that such action establishes a binding agreement between you and dYdX.*

*This documentation provides information on how to use dYdX v4 software (”dYdX Chain”). dYdX does not deploy or run v4 software for public use, or operate or control any dYdX Chain infrastructure. dYdX is not responsible for any actions taken by other third parties who use v4 software. dYdX services and products are not available to persons or entities who reside in, are located in, are incorporated in, or have registered offices in the United States or Canada, or Restricted Persons (as defined in the dYdX [Terms of Use](https://dydx.exchange/terms)). The content provided herein does not constitute, and should not be considered, or relied upon as, financial advice, legal advice, tax advice, investment advice or advice of any other nature, and you agree that you are responsible to conduct independent research, perform due diligence and engage a professional advisor prior to taking any financial, tax, legal or investment action related to the foregoing content. The information contained herein, and any use of v4 software, are subject to the [v4 Terms of Use](https://dydx.exchange/v4-terms).*
