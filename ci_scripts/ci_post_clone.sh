#!/bin/sh

# Fail this script if any subcommand fails.
set -e

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

# Create the ephemeral directory if it doesn't exist
echo "Ensuring ephemeral directory exists..."
mkdir -p macos/Flutter/ephemeral

# Generate Flutter build files by running Flutter's tool directly
echo "Generating Flutter configuration files..."
flutter build macos --debug --config-only

# Alternative: Use Flutter's tool command to generate the files
if [ ! -f "macos/Flutter/ephemeral/Flutter-Generated.xcconfig" ]; then
  echo "Config-only didn't work, trying assemble..."
  cd macos
  flutter assemble --output=Flutter/ephemeral -dmacos debug_macos_bundle_flutter_assets
  cd ..
fi

# Verify the files exist
echo "Verifying generated files..."
if [ -f "macos/Flutter/ephemeral/Flutter-Generated.xcconfig" ]; then
  echo "✓ Flutter-Generated.xcconfig exists"
  cat macos/Flutter/ephemeral/Flutter-Generated.xcconfig
else
  echo "✗ Flutter-Generated.xcconfig NOT found"
  echo "Contents of macos/Flutter/ephemeral:"
  ls -la macos/Flutter/ephemeral || echo "Directory doesn't exist!"
  exit 1
fi

# Install CocoaPods dependencies
echo "Running pod install in macos directory..."
cd macos
pod install --repo-update
cd ..

echo "ci_post_clone.sh completed successfully."
exit 0