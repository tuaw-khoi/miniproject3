# ReceiptFlow

An offline Android expense tracker built with Flutter, on-device Google ML Kit text recognition, SQLite and interactive charts drawn with `CustomPainter`.

**Mini-project 3 · Mobile Application Development**  
**Languages:** Tiếng Việt / English · **Currency:** VND

## Features

- Camera preview, torch toggle, tap-to-focus, framing guide, native crop and rotation.
- Gallery import and a bundled synthetic receipt processed by the real ML Kit model.
- Regex receipt parser for merchant, Vietnamese amounts and calendar dates; ambiguous or missing fields require review.
- Editable review before saving; manual entry, transaction detail, edit and delete.
- SQLite persistence, private receipt storage, cached thumbnails and orphan cleanup.
- Merchant/note search, category and date filters, UTF-8 CSV sharing.
- Animated, interactive donut and weekly bar charts using Flutter canvas, without chart packages.
- Vietnamese/English localization, light/dark/system themes and separate demo data.
- No login, cloud backend or paid OCR API. The Latin OCR model is bundled in the APK.

## Requirements

- Flutter **3.44.7**, Dart **3.12.2** (see `pubspec.lock`).
- Android SDK 36, Java 21, Android device/emulator **API 24+**.
- Linux SQLite library for database tests (`libsqlite3-0`).
- Internet is needed to download build dependencies, but receipt recognition works offline after installing the APK.

## Quick start

```bash
flutter pub get
flutter gen-l10n
flutter run
```

On the current workstation Flutter is installed at `~/development/flutter/bin`; add that directory to `PATH` if needed. The application starts with an empty personal database. Use **Settings → Demo data** to explore sample transactions; switching back restores the personal database.

**Tiếng Việt:** Vào **Quét hóa đơn** để chụp, chọn ảnh từ thư viện hoặc quét ảnh mẫu bằng ML Kit. Kiểm tra cửa hàng, số tiền, ngày và danh mục trước khi lưu. Ảnh mẫu là hóa đơn tổng hợp, không phải dữ liệu cá nhân.

## Mobile web demo and recording

The installable product is the Android APK. A small, clearly labelled mobile
web demo is included for browser-based presentations when an Android device is
not available. It uses the same visual language and sample transaction flow,
but does **not** claim to run the native OCR, SQLite or private-file features.

```bash
python3 -m http.server 4173
# Open http://127.0.0.1:4173/web_demo/ in a 430px-wide browser viewport.
```

The detailed 12-chapter browser walkthrough is
[`docs/receiptflow-detailed-demo.webm`](docs/receiptflow-detailed-demo.webm).
The five-page submission report is available as
[`docs/ReceiptFlow_Report.pdf`](docs/ReceiptFlow_Report.pdf). Regenerate the
video with `NODE_PATH=/tmp/receiptflow-playwright/node_modules node
scripts/record_web_demo.mjs` after installing Playwright and its FFmpeg helper.

## Verification

```bash
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
flutter test integration_test/app_test.dart -d <android-device-id>
```

The integration test uses its own temporary database. It checks real OCR, native thumbnail storage, SQLite reopening and transaction navigation. It emits `RECEIPTFLOW_BENCHMARK` JSON containing cold latency and warm median/p95 for the bundled fixture. Physical camera and flash require a real device.

Flutter 3.44.7's `flutter analyze` can fail in its analysis transport when the workspace path contains non-ASCII characters. `dart analyze --fatal-infos` runs the same Dart analysis successfully here; CI checks `flutter analyze` in an ASCII checkout.

## Signed APK

```bash
python3 scripts/setup_signing.py
flutter build apk --release
# build/app/outputs/flutter-apk/app-release.apk
```

The signing script creates a private key under `~/.config/receiptflow-signing/` and an ignored `android/key.properties`. Back up that directory privately to sign future updates with the same key. Release builds fail if signing has not been configured; they never silently use the Android debug key.

GitHub Actions checks formatting, analysis, tests and debug compilation on every main-branch push. The release workflow requires repository secrets `ANDROID_KEYSTORE_BASE64` and `ANDROID_KEY_PASSWORD`, representing that same private release key, before pushing a `v*` tag. It attaches the APK and checksum to GitHub Releases. Never commit these secrets.

## Architecture

```text
Flutter screens + generated vi/en localization
                    ↓
          Riverpod AppController
          ↙                    ↘
TransactionRepository      ReceiptImageStore
        ↓                    ↓
      SQLite          private files + thumbnails

Camera / Gallery → Crop / Rotate → ML Kit → ReceiptParser
                                              ↓
                                        Editable review
                                              ↓
                                            Save

Saved expenses → date/category aggregation → CustomPainter charts
```

Feature modules live under `lib/features/`; shared state and design tokens are in `lib/core/`. `ReceiptParser` and aggregation functions are plain Dart. There is no server API. `TransactionRepository`, `OcrService` and `ReceiptImageStore` isolate platform access.

Amounts are positive integer VND, dates are local calendar values (`YYYY-MM-DD`), and timestamps record creation/update time. Category identifiers remain stable across locale changes. OCR suggestions never bypass the review form. Heuristic warnings are not ML confidence scores.

## Project documents

- [Implementation and submission checklist](docs/IMPLEMENTATION_CHECKLIST.md)
- [Physical-device acceptance and demo script](docs/DEMO_SCRIPT.md)
- [Release notes](docs/RELEASE_NOTES.md)
- Technical report and screenshots are generated from verified application behavior before final submission.

## Limitations

Latin printed receipts are the initial target. Handwriting, heavy blur, non-VND currencies, perspective correction, line-item accounting and cloud synchronization are outside this version. OCR latency depends on the device and input image; sub-100 ms is a benchmark target, not a guaranteed claim. App data is device-local and is removed on uninstall; CSV is an export, not a full photo backup.

## License

MIT. Package licenses are available from **Settings → About ReceiptFlow**.
