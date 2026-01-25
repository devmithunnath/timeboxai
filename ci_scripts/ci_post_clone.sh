#!/bin/sh

# Fail this script if any subcommand fails.
set -e

echo "DEBUGGING: Forcing failure to verify script execution"
exit 1

# The default execution directory of this script is the ci_scripts directory.
# cd to the root of our repository.
cd ..

echo "Starting ci_post_clone.sh..."
echo "Current directory: $(pwd)"

# Clone Flutter
echo "Cloning Flutter..."
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Detailed logs
echo "Flutter version:"
flutter --version
flutter doctor -v

# Precache artifacts
echo "Precaching Flutter artifacts for macOS and iOS..."
flutter precache --macos --ios

# Install Flutter dependencies
echo "Running flutter pub get..."
flutter pub get

# Verify generation of key files
echo "Verifying generated files in macos/Flutter/ephemeral..."
ls -la macos/Flutter/ephemeral || echo "Directory macos/Flutter/ephemeral not found!"

# Install CocoaPods dependencies.
echo "Running pod install in macos directory..."
cd macos
pod install --repo-update
cd ..

echo "ci_post_clone.sh completed successfully."
exit 0
