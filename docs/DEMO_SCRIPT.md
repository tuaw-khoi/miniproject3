# ReceiptFlow — detailed 1:52 presentation

The repository includes `receiptflow-detailed-demo.webm`, a clearly labelled
mobile web presentation recorded at 430×840. It demonstrates the UI and
explains the native implementation without claiming that browser JavaScript is
running ML Kit or SQLite. A physical-device recording remains the final proof
for camera, flash, focus and offline OCR performance.

| Time | Action | Narration |
| --- | --- | --- |
| 0:00–0:06 | Animated title card | Introduce ReceiptFlow as an offline Flutter Android expense tracker. |
| 0:06–0:13 | Dashboard | Explain monthly/today totals, weekly bars and recent expenses. |
| 0:13–0:29 | Sample receipt and review | Explain camera/crop/ML Kit, synthetic input and mandatory review before save. |
| 0:29–0:39 | Save and transaction list | Explain local SQLite persistence and ordering by date. |
| 0:39–0:58 | Search, category filter and detail | Demonstrate query/filter behavior plus edit/delete and private image lifecycle. |
| 0:58–1:13 | Donut and weekly chart | Explain category aggregation and interactive CustomPainter charts. |
| 1:13–1:26 | Manual entry | Show merchant, amount, date and category validation without OCR. |
| 1:26–1:40 | Settings | Explain vi/en localization, light/dark themes and isolated demo data. |
| 1:40–1:47 | CSV and build status | Explain filtered UTF-8 CSV, formula neutralization, 51 tests and GitHub APK. |
| 1:47–1:52 | Closing card | Summarize the stack and offline/privacy goals. |

## Physical-device checklist

- [ ] Record manufacturer, model, Android version and APK checksum.
- [ ] Fresh install, airplane mode before first OCR; model must work without download.
- [ ] Allow camera; deny permission and recover via Android Settings.
- [ ] Toggle supported flash; tap focus on small receipt text.
- [ ] Capture portrait receipt, rotate/crop; cancel crop without saving anything.
- [ ] Background/resume camera without crash or retained camera indicator.
- [ ] Review and correct amount/date/merchant; save once despite rapid taps.
- [ ] Edit, restart, reopen image; delete removes transaction and image.
- [ ] Check Vietnamese/English and dark mode with large system text.
- [ ] Benchmark repeated OCR on the same set and distinguish first/warm runs.

## Build and device commands

```bash
adb devices
flutter build apk --release
adb install -r build/app/outputs/flutter-apk/app-release.apk
adb shell screenrecord --time-limit 180 /sdcard/receiptflow-demo.mp4
adb pull /sdcard/receiptflow-demo.mp4 docs/receiptflow-demo.mp4
```

Student name/code and the official report template must be supplied before academic submission. No identity is inferred from the GitHub account.
