# 程式碼風格規範 (Code Style)

本專案包含 Java (Spring Boot) 後端與 Flutter (Dart) 前端，請遵循以下規範以確保程式碼一致性。

---

## 1. 後端規範 (Java 21 + Spring Boot 3)

### 基礎規範
- 使用 **Lombok** 以簡化程式碼（如 `@Data`, `@Getter`, `@Setter`, `@Builder`, `@RequiredArgsConstructor`）。
- 依賴注入應優先使用建構子注入（利用 `@RequiredArgsConstructor`）而非 `@Autowired`。

### 命名規範
- **變數與函式**：使用 `camelCase`（例如：`waterIntakeMl`、`calculateDailyAverage()`）
- **類別/介面/列舉**：使用 `PascalCase`（例如：`CareLogService`、`EventType`）
- **常數**：使用 `UPPER_SNAKE_CASE`（例如：`REDIS_KEY_PREFIX`、`MAX_WEIGHT_LIMIT`）
- **布林值變數**：使用 `is`、`has`、`should` 前綴（例如：`isActive`、`hasWaterTimerExpired`）

### 控制器與 API 設計
- 回傳格式一律使用統一封裝的 `ApiResponse<T>`，包含 `success`, `message`, `data` 等欄位。
- 遵循 RESTful API 風格，並適當處理全域異常 (`GlobalExceptionHandler`)。

---

## 2. 前端規範 (Flutter + Dart)

### 基礎規範
- 遵守 Dart 官方推薦風格 ([Effective Dart](https://dart.dev/effective-dart))。
- 善用 `const` 構造函式以提升 Flutter 渲染效能。
- 檔案命名必須與元件/類別名稱對應，使用底線分隔。

### 命名規範
- **檔案與目錄**：使用 `lower_with_underscores`（例如：`home_dashboard.dart`、`screens/`）
- **變數與函式**：使用 `camelCase`（例如：`currentWeight`、`updateWaterIntake()`）
- **類別/Widget/Mixin**：使用 `PascalCase`（例如：`CareLogTimeline`、`WeightChart`）
- **常數**：使用 `lowerCamelCase`（Dart 官方推薦，例如：`apiBaseUrl`、`primaryColor`）
- **布林值變數**：使用 `is`、`has`、`should` 前綴（例如：`isLoading`、`hasError`）

### 專案結構與狀態管理
- UI Widget 應保持輕量（Single Responsibility Principle），並將邏輯抽離至 State Management 層。
- 定義明確的 UI 主題（Theme）與配色，嚴禁直接在 Widget 內寫死顏色與字型大小（Magic Numbers / Colors）。
