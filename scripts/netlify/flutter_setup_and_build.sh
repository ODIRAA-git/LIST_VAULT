#!/usr/bin/env bash
set -euo pipefail

# Clone Flutter stable to $HOME/flutter (adjust channel or tag if you need a specific version)
git clone --depth 1 https://github.com/flutter/flutter.git -b stable "$HOME/flutter"

export PATH="$HOME/flutter/bin:$PATH"

# Ensure web artifacts are available and pub packages are fetched
flutter --version
flutter precache --web
flutter pub get

# Build web output to build/web (Netlify publish path)
flutter build web --release
