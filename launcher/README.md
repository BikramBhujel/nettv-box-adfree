# Apple TV style home screen for the NetTV box

The launcher itself is [cleanyourtv](https://github.com/Gathin23/cleanyourtv) by Gathin (MIT). This folder only holds my settings and tile artwork for the NETTV-1000.

## Build

1. Clone cleanyourtv and install JDK 17 and the Android SDK (platform 34).
2. Copy `tiles/*.xml` into `cleanyourtv/launcher/app/src/main/res/drawable/`.
3. Merge `config-snippet.xml` into `cleanyourtv/launcher/app/src/main/res/values/config.xml`.
4. Build: `cd cleanyourtv/launcher && ./gradlew assembleRelease`
5. Install and make it Home:

```bash
adb -s <box ip:port> install -r app/build/outputs/apk/release/app-release.apk
adb -s <box ip:port> shell cmd package set-home-activity --user 0 com.gathin.tvhome/.MainActivity
```

Keep the NetTV launcher installed and enabled. It handles your login and subscription in the background.

## Tile icons

The symbols are from Google's [Material Symbols](https://github.com/google/material-design-icons) (Apache 2.0), rounded and filled, drawn as Android vector drawables.
