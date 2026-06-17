# Frontend Environment

The Flutter app reads runtime endpoints and Google OAuth client configuration from `--dart-define` values.

## Variables

| Name | Purpose | Local default |
| --- | --- | --- |
| `API_BASE_URL` | Spring Boot REST API base URL | Web: `http://localhost:8080`, Android emulator: `http://10.0.2.2:8080` |
| `WEBSOCKET_URL` | STOMP WebSocket endpoint | Web: `ws://localhost:8080/ws-pet`, Android emulator: `ws://10.0.2.2:8080/ws-pet` |
| `GOOGLE_SIGN_IN_CLIENT_ID` | Google OAuth web client ID used by `google_sign_in` | Empty |

## Example

```bash
flutter run -d chrome \
  --dart-define=API_BASE_URL=http://localhost:8080 \
  --dart-define=WEBSOCKET_URL=ws://localhost:8080/ws-pet \
  --dart-define=GOOGLE_SIGN_IN_CLIENT_ID=YOUR_WEB_OAUTH_CLIENT_ID.apps.googleusercontent.com
```

For Android emulator builds, use the emulator host address unless your backend is reachable elsewhere:

```bash
flutter run -d emulator-5554 \
  --dart-define=API_BASE_URL=http://10.0.2.2:8080 \
  --dart-define=WEBSOCKET_URL=ws://10.0.2.2:8080/ws-pet \
  --dart-define=GOOGLE_SIGN_IN_CLIENT_ID=YOUR_WEB_OAUTH_CLIENT_ID.apps.googleusercontent.com
```
