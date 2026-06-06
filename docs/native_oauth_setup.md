# 原生平台 Google OAuth 設定指南 (Android & iOS)

本文件說明當本專案生成原生 Android 與 iOS 目錄（例如執行 `flutter create .`）後，如何配置 Google Sign-In 金鑰與憑證。

---

## 1. iOS 平台設定 (Info.plist)

在 iOS 上使用 Google Sign-In，您必須將 Google Cloud Console 產生的 **反向用戶端 ID (Reversed Client ID)** 註冊為 URL 協議。

### 編輯檔案：`ios/Runner/Info.plist`

請在 `<dict>` 標籤內加入以下 `CFBundleURLTypes` 配置（請將 `YOUR_REVERSED_CLIENT_ID` 替換為您從 Google Service-Info.plist 取得的實際數值）：

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- 貼上您的反向用戶端 ID，例如：com.googleusercontent.apps.1234567890-abcdefg -->
            <string>YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

---

## 2. Android 平台設定 (Gradle & Google Services)

在 Android 上，Google Sign-In 需要依賴 Google Play Services。

### 步驟 A：取得 SHA-1 指紋與設定 Firebase / Google Cloud
1. 執行以下指令以取得您本地開發金鑰的 SHA-1 指紋：
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
2. 將取得的 SHA-1 指紋填入 Google Cloud Console / Firebase 專案設定中。
3. 下載 `google-services.json` 檔案，並將其放置於：
   `android/app/google-services.json`

### 步驟 B：編輯專案根目錄 Gradle 檔 (`android/build.gradle`)
確保 `buildscript` 依賴中包含 Google Services 插件：

```gradle
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // 加入以下這一行
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

### 步驟 C：編輯 App 目錄 Gradle 檔 (`android/app/build.gradle`)
在檔案最底部套用 Google Services 插件：

```gradle
// 套用 Flutter 插件之後，在最底部加上這一行
apply plugin: 'com.google.gms.google-services'
```
