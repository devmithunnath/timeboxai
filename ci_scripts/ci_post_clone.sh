#!/bin/sh

# Fail this script if any subcommand fails.
set -e

# The default execution directory of this script is the ci_scripts directory.
# cd to the root of our repository.
cd ..

# Clone Flutter
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Install Flutter dependencies
flutter pub get

# Install CocoaPods dependencies.
cd macos
pod install
cd ..

exit 0
