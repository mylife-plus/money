# 💰 Moneyapp

A personal finance tracker built with Flutter — track your spending, manage investments, and visualise your portfolio over time.

---

## Features

### 📊 Spending Tracker
- Log income and expense transactions with categories, hashtags, and MCC codes
- Filter by date range, activity type, hashtag, and amount
- Sort transactions by date or amount
- Upload transactions in bulk via CSV

### 📈 Investment Portfolio
- Track investments via deposits, withdrawals, and trades
- View cumulative portfolio value on an interactive graph
- Supports time ranges: 1d, 2d, 7d, 2w, 1m, 3m, 6m, 1y, 2y, 5y, All
- Graph uses carry-forward pricing for accurate historical valuations
- Filter portfolio by investment, activity type, or amount range
- Manually record price snapshots per investment

### 🔧 Settings
- Multi-currency support with a dedicated currency selection screen
- Upload investments and transactions from file
- Manage hashtag groups and MCC codes

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State Management | GetX |
| Local Database | SQLite via `sqflite` |
| Persistent Storage | `shared_preferences` |
| UI Scaling | `flutter_screenutil` |
| Charts | `fl_chart` |
| Fonts | Google Fonts |
| Image Picker | `image_picker` |
| Color Picker | `flutter_colorpicker` |

---

## Project Structure

```
lib/
├── constants/        # Colors, icons, theme, app-wide constants
├── controllers/      # GetX controllers (home, investment, hashtag, mcc, ui)
├── data/             # Local data sources and database helpers
├── models/           # Data models
├── routes/           # App routes and navigation
├── screens/          # UI screens (home, investments, settings, onboarding, etc.)
├── services/         # Currency and other services
├── utils/            # Utility functions
└── widgets/          # Reusable widgets (charts, toggles, app bars, etc.)
```

---

## Getting Started

### Prerequisites
- Flutter SDK `^3.9.2`
- Dart SDK (included with Flutter)
- Xcode (iOS) or Android Studio (Android)

### Run the app

```bash
flutter pub get
flutter run
```

### iOS (additional step)
```bash
cd ios && pod install && cd ..
flutter run
```

---

## Platform Support

| Platform | Supported |
|---|---|
| iOS | ✅ |
| Android | ✅ |
| macOS | ✅ |
| Web | ✅ |
| Windows | ✅ |
| Linux | ✅ |

---

## Notes

- `ITSAppUsesNonExemptEncryption` is set to `false` in `ios/Runner/Info.plist` — no export compliance popup on App Store submission.
- The app uses `sqflite` for local-only storage; no data leaves the device.

