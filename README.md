# Time Tracker Gothic

An atmospheric, dark-themed time tracking application built with **Flutter**, featuring local persistence via **Hive**, calendar-based views, weekly/monthly summaries, professional PDF exports, and bilingual support (English & German).

---

## Features

- **Gothic Dark Theme:** Immersive dark aesthetic with deep burgundy and muted gold accents (`#1D1A1A`, `#CBA135`, `#B84335`).
- **Advanced Time Tracking:** Log daily work hours, split shifts, breaks, sick days, vacation, and overtime.
- **German Labor Law Compliance (ArbZG § 4):** Optional toggle to automatically enforce statutory break rules (`>6h: 30m`, `>9h: 45m`) alongside company policies.
- **Flexible Work Schedules:** Support for custom weekly hours and custom working days per week (e.g., 4-day or 5-day work weeks).
- **Employment Start Date Anchoring:** Precise historical overtime calculations starting strictly from your hire date.
- **Professional PDF Timesheet Export:** Generate and save Daily, Weekly, and Monthly PDF reports complete with summary statistics, detailed entry tables, negative overtime formatting, and official employee/manager signature lines.
- **Calendar & Summaries:** Interactive calendar view via `table_calendar`, along with weekly and monthly summary screens.
- **Local Persistence:** Fast and reliable local storage using **Hive**.
- **Bilingual Support:** Fully localized in **English (EN)** and **German (DE)** using Flutter l10n.

---

## Tech Stack & Libraries

- **Framework:** [Flutter](https://flutter.dev) (Dart ^3.8.0)
- **Database:** [Hive / Hive Flutter](https://pub.dev/packages/hive) for NoSQL local storage.
- **Calendar:** [Table Calendar](https://pub.dev/packages/table_calendar) for date navigation and selection.
- **PDF Generation:** [pdf](https://pub.dev/packages/pdf) & [path_provider](https://pub.dev/packages/path_provider) for local timesheet export.
- **Localization:** `flutter_localizations` & `intl` for EN/DE multi-language support.

---

## Getting Started

### Prerequisites
- Make sure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed (Dart ^3.8.0).
- **Java (JDK 17):** Required for Android builds.
- An active device emulator or connected physical device (Android, iOS, or Desktop).

### Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/time_tracker_gothic.git
   cd time_tracker_gothic
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate Hive Adapters (if modifying models):**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

---

## Project Structure

```text
lib/
├── l10n/                 # Localization files (.arb & generated localizations)
├── models/               # Data models (TimeEntry, UserSettings, Hive adapters)
├── screens/              # UI Screens (HomeScreen, MonthlySummary, WeeklySummary, AboutMe)
├── services/             # Business logic (TimeCalculator, PdfReportService, UserSettingsService)
└── main.dart             # App entry point, theming, and routing
```

---

## License

This project is private and intended for personal/custom use.
