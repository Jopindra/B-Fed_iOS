#!/bin/bash
# Launch B-Fed on iPhone 17 iOS Simulator

set -e

echo "Building B-Fed for iPhone 17 Simulator..."
xcodebuild -scheme B-Fed -destination 'platform=iOS Simulator,name=iPhone 17' build

echo ""
echo "Build complete. Open Xcode and press ⌘R to run on iPhone 17."
