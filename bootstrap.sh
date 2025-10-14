#!/bin/sh

set -e

PROJECT_DIR=$(pwd)
ROOT_DIR=$(pwd)/../

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

##########################################################
# React Native
##########################################################

brew install npm
npm install

##########################################################
# iOS
##########################################################

cp ios/scripts/pre-commit .git/hooks

# Install Xcode
XCODE=/Applications/Xcode.app
if [ ! -d "$XCODE" ]; then
	./ios/scripts/update_xcode.sh
fi

brew install cocoapods
brew install java
brew install SwiftLint
brew install gradle
brew install xcode-kotlin
brew install gh
xcode-kotlin install

sudo ln -sfn /usr/local/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk

# Install templates
cd ios/scripts
./install_templates.sh

cd "$ROOT_DIR"

if [ ! -d "v4-localization" ]; then
	git clone git@github.com:dydxprotocol/v4-localization.git
else
	cd v4-localization
	git pull
	cd ..
fi

if [ ! -d "v4-web" ]; then
	git clone git@github.com:dydxprotocol/v4-web.git
else
	cd v4-web
	git pull
	cd ..
fi

##########################################################
# Android
##########################################################

# Install Xcode
ANDROID_STUDIO=/Applications/Android\ Studio.app
if [ ! -d "$ANDROID_STUDIO" ]; then
        brew install --cask android-studio
fi

open $PROJECT_DIR/ios/dydx/dydx.xcworkspace

