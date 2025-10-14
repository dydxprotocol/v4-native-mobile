<div align="center">
  <img src='https://github.com/dydxprotocol/v4-native-mobile/blob/main/ios/dydxV4/dydxV4/Assets.xcassets/AppIcon.appiconset/App%20icon%403x.png' alt='icon'  width="100"  height="100" />
</div>

<h1 align="center">v4-native-mobile</h1>

<div align="center">
  <a href='https://github.com/dydxprotocol/v4-native-mobile/blob/main/LICENSE'>
    <img src='https://img.shields.io/badge/License-AGPL_v3-blue.svg' alt='License' />
  </a>
</div>

This is the repo for the native iOS and Android app for dYdX v4.

# Quick Setup

> ./bootstrap.sh

This will set up the project dependencies.

For iOS, open "ios/dydx/dydx.xcworkspace" from Xcode, and select the "dydxV4" scheme to build.
For Android, open "android" folder from Android Studio. 

# Platform Specific Setup:

Refer to the README of the [iOS](https://github.com/dydxprotocol/v4-native-mobile/tree/main/ios) and [Android](https://github.com/dydxprotocol/v4-native-mobile/tree/main/android) folder.

# React Native Setup:

For debug shared component written in React Native, run the following:

```zsh
npm run start
```

To bundle the React Native components, run:

```zsh
npm run bundle_ios
npm run bundle_android
```

_______
*By using, recording, referencing, or downloading (i.e., any “action”) any information contained on this page or in any dYdX Trading Inc. ("dYdX") database or documentation, you hereby and thereby agree to the [v4 Terms of Use](https://dydx.exchange/v4-terms) and [Privacy Policy](https://dydx.exchange/privacy) governing such information, and you agree that such action establishes a binding agreement between you and dYdX.*

*This documentation provides information on how to use dYdX v4 software (”dYdX Chain”). dYdX does not deploy or run v4 software for public use, or operate or control any dYdX Chain infrastructure. dYdX is not responsible for any actions taken by other third parties who use v4 software. dYdX services and products are not available to persons or entities who reside in, are located in, are incorporated in, or have registered offices in the United States or Canada, or Restricted Persons (as defined in the dYdX [Terms of Use](https://dydx.exchange/terms)). The content provided herein does not constitute, and should not be considered, or relied upon as, financial advice, legal advice, tax advice, investment advice or advice of any other nature, and you agree that you are responsible to conduct independent research, perform due diligence and engage a professional advisor prior to taking any financial, tax, legal or investment action related to the foregoing content. The information contained herein, and any use of v4 software, are subject to the [v4 Terms of Use](https://dydx.exchange/v4-terms).*
