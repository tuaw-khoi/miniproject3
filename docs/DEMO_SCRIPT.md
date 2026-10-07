# ReceiptFlow — 2–3 minute demo

Use a synthetic/non-sensitive printed receipt. Record the actual Android screen; do not present a mockup as an app recording.

| Time | Action | Narration |
| --- | --- | --- |
| 0:00–0:15 | Show home and enable airplane mode | ReceiptFlow stores expenses locally and runs OCR on device. |
| 0:15–0:50 | Open camera, toggle flash, tap focus, capture, crop/rotate | The image is cropped before processing. |
| 0:50–1:20 | Show recognized amount/date/merchant; correct a field and select category | Parser distinguishes total, cash tendered and change. Review is required. |
| 1:20–1:40 | Save, open transaction and receipt image | SQLite and private image storage persist the expense. |
| 1:40–2:05 | Open insights, tap donut legend and weekly bars | Canvas charts animate and respond to selection. |
| 2:05–2:25 | Search/filter and share CSV; change to English | Filters control exported records. |
| 2:25–2:45 | Close and reopen application | Saved data remains offline. Show repo and APK links. |

If only an emulator is available, record gallery/sample OCR and label the video **emulator demonstration**. Physical camera, flash and tap-focus verification remain pending until tested on a phone.

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
