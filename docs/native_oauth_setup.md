# Native Google OAuth and Firebase Setup

This project supports web, Android, and iOS Google Sign-In. Real credentials are not committed. Use the checked-in `.example` files as templates and inject public client IDs at build time.

## Flutter build-time configuration

Pass these values with `--dart-define` when running or building the Flutter app:

```bash
flutter run \
  --dart-define=API_BASE_URL=http://localhost:8080 \
  --dart-define=WEBSOCKET_URL=ws://localhost:8080/ws-pet \
  --dart-define=GOOGLE_SIGN_IN_CLIENT_ID=YOUR_WEB_OAUTH_CLIENT_ID.apps.googleusercontent.com
```

Defaults are still provided for local development:

- Web API: `http://localhost:8080`
- Android emulator API: `http://10.0.2.2:8080`
- Web WebSocket: `ws://localhost:8080/ws-pet`
- Android emulator WebSocket: `ws://10.0.2.2:8080/ws-pet`

## Android

1. Create an Android OAuth client in Google Cloud Console or Firebase.
2. Add the debug/release SHA-1 fingerprints for the Android app.
3. Download `google-services.json`.
4. Copy it to:

```text
frontend/android/app/google-services.json
```

Use [frontend/android/app/google-services.json.example](../frontend/android/app/google-services.json.example) as a shape reference. The real file is ignored by git.

The Google Services Gradle plugin is configured in `frontend/android/settings.gradle.kts` and is applied only when `google-services.json` exists, so local builds without secrets still work.

## iOS

1. Create an iOS OAuth client in Google Cloud Console or Firebase.
2. Download `GoogleService-Info.plist`.
3. Copy it to:

```text
frontend/ios/Runner/GoogleService-Info.plist
```

Use [frontend/ios/Runner/GoogleService-Info.plist.example](../frontend/ios/Runner/GoogleService-Info.plist.example) as a shape reference. The real file is ignored by git.

Set the reversed client ID in both xcconfig files before native iOS builds:

```text
GOOGLE_REVERSED_CLIENT_ID=com.googleusercontent.apps.YOUR_IOS_OAUTH_CLIENT_ID
```

The value is consumed by `frontend/ios/Runner/Info.plist` through `CFBundleURLTypes`.

## Backend Firebase Admin

The backend defaults to Firebase mock mode for local development and tests:

```properties
app.firebase.mock-enabled=${FIREBASE_MOCK_ENABLED:true}
app.firebase.config-path=${FIREBASE_CONFIG_PATH:classpath:firebase-service-account.json}
```

For real FCM notifications, copy [backend/src/main/resources/firebase-service-account.json.example](../backend/src/main/resources/firebase-service-account.json.example) to `backend/src/main/resources/firebase-service-account.json`, or point `FIREBASE_CONFIG_PATH` at a secure external location, then run with:

```bash
FIREBASE_MOCK_ENABLED=false
FIREBASE_CONFIG_PATH=file:/absolute/path/firebase-service-account.json
```
