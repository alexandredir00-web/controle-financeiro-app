#!/usr/bin/env bash
set -e

mkdir -p ~/.bubblewrap
cat <<'EOF' > ~/.bubblewrap/config.json
{
  "jdkPath": "/usr/lib/jvm/temurin-17-jdk-amd64",
  "androidSdkPath": "/usr/local/lib/android/sdk"
}
EOF

if [ ! -d "/usr/lib/jvm/temurin-17-jdk-amd64" ]; then
  JAVA_DIR=$(dirname "$(dirname "$(readlink -f "$(which java)")")")
  cat <<EOF > ~/.bubblewrap/config.json
{
  "jdkPath": "$JAVA_DIR",
  "androidSdkPath": "${ANDROID_HOME:-/usr/local/lib/android/sdk}"
}
EOF
fi

keytool -genkeypair -v -keystore release.keystore -alias financas \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -storepass senha123 -keypass senha123 \
  -dname "CN=Financas360, OU=App, O=Workana, L=Bacabal, S=MA, C=BR"

mkdir -p twa-app
cd twa-app

cat <<'EOF' > twa-manifest.json
{
  "packageId": "com.alexandredir00.financas360",
  "host": "alexandredir00-web.github.io",
  "name": "Financas 360",
  "launcherName": "Financas 360",
  "display": "standalone",
  "themeColor": "#206a4e",
  "navigationColor": "#206a4e",
  "navigationColorDark": "#164b37",
  "navigationDividerColor": "#206a4e",
  "navigationDividerColorDark": "#164b37",
  "backgroundColor": "#f3f6f4",
  "enableNotifications": false,
  "startUrl": "/controle-financeiro-app/index.html",
  "iconUrl": "https://cdn-icons-png.flaticon.com/512/2489/2489756.png",
  "splashScreenFadeOutDuration": 300,
  "signingKey": {
    "path": "../release.keystore",
    "alias": "financas"
  },
  "appVersionName": "1.0.0",
  "appVersionCode": 1,
  "shortcuts": [],
  "generatorApp": "bubblewrap-cli",
  "webManifestUrl": "https://alexandredir00-web.github.io/controle-financeiro-app/manifest.json",
  "fallbackType": "customtabs",
  "features": {
    "locationDelegation": {
      "enabled": false
    },
    "playBilling": {
      "enabled": false
    }
  },
  "alphaDependencies": {
    "enabled": false
  },
  "enableSiteSettingsShortcut": true,
  "isChromeOSOnly": false,
  "minSdkVersion": 21,
  "orientation": "portrait",
  "fingerprints": [],
  "additionalTrustedOrigins": [],
  "retainedBundles": [],
  "protocolHandlers": [],
  "fileHandlers": [],
  "launchHandlerClientMode": "",
  "displayOverride": []
}
EOF

yes | bubblewrap update --yes || true
yes | bubblewrap build --skipPwaValidation || true

APK_FOUND=$(find . -name "*.apk" -maxdepth 6 | head -n 1)
if [ -n "$APK_FOUND" ]; then
  cp "$APK_FOUND" /tmp/app-release-signed.apk
  ls -lh /tmp/app-release-signed.apk
else
  echo "Nenhum APK foi gerado pelo bubblewrap build."
  exit 1
fi
