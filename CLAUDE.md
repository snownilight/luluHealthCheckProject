# CLAUDE.md

## Build and Run Commands

### Backend (Spring Boot 3 + Maven)
- **Build application**: `mvn clean package`
- **Run in development mode**: `mvn spring-boot:run`
- **Run tests**: `mvn test`
- **Run individual test**: `mvn -Dtest=ClassNameTest test`

### Frontend (Flutter)
- **Get dependencies**: `flutter pub get`
- **Run application**: `flutter run`
- **Run tests**: `flutter test`
- **Build APK (Android)**: `flutter build apk`
- **Build iOS**: `flutter build ios`

---

## Code Guidelines & Styles

### 1. General Philosophy
- **Reference Guidelines**: Always refer to the behavioral guidelines in [GEMINI.md](file:///C:/Users/snown/.gemini/GEMINI.md) during the development process.
- **Compassionate & Preventive Care**: Focus on reliability, clean event flow, and prompt failure alerting.
- **Simplicity First**: Write readable, maintainable code. Keep abstractions to a minimum.
- **Surgical Changes**: Avoid touching unrelated components. Keep diffs focused and minimal.

### 2. Backend (Java 21 + Spring Boot 3)
- Use **Lombok** to eliminate boilerplate (`@Data`, `@Getter`, `@Setter`, `@Builder`, `@RequiredArgsConstructor`).
- **Naming Conventions**:
  - Variable/Method: `camelCase`
  - Class/Interface: `PascalCase`
  - Constants: `UPPER_SNAKE_CASE`
- Always return standard wrapper responses via `ApiResponse<T>`.

### 3. Frontend (Flutter + Dart)
- **Naming Conventions**:
  - Variable/Method: `camelCase`
  - Class/Widget: `PascalCase`
  - File/Directory: `lower_with_underscores` (e.g., `home_dashboard_screen.dart`)
- **State Management**: Use clean separation of state from UI (e.g., Riverpod or Provider as chosen).

### 4. Git Commit Rules
- Follow **Conventional Commits** combined with Jira ticket tracking (e.g., `feat(ui): [PET-010] Add water timer countdown`).
- See [GIT-COMMIT.md](docs/GIT-COMMIT.md) for full details.

---

## Development Workflow
Follow these steps strictly:
1. Only do one task at a time.
2. Wait for user's task assignment (Step 1).
3. Read `working.md` to get the task content.
4. Create the task branch (e.g., `PET-006`) and implement.
5. Add edge-case tests and verify everything passes.
6. Fix any bugs or compile issues.
7. Update `working.md`.
8. Commit and merge into `dev`, then push both branches to GitHub.
9. Move the task to "Done" on your GitHub Projects board using the Classic PAT.
