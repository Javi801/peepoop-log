# PeePoop Log

A fully offline mobile app for tracking urination and defecation events.

PeePoop Log is built for personal health tracking — including use cases related to
traditional Chinese medicine observation. It lets you quickly log bathroom events
with date, time, optional descriptions, and customizable tags, and export
everything as CSV. **All data stays on your device**: no login, no cloud, no
analytics, no Google/Meta/Firebase services.

## Features

- **Record events** — log urination, defecation, or both in a single timestamped
  entry, each with its own optional description and tags.
- **Edit & delete** — update any record; delete individual records with
  confirmation, or wipe all app data from Settings.
- **Tags** — create, rename, recolor, and delete tags. Tags belong to one event
  type (urination or defecation), are reused across records, and are created
  automatically as you type. Duplicate tags (same normalized name + type) are
  rejected.
- **History & filters** — browse records chronologically and filter by date
  range, event type, tags, and sort order.
- **CSV export** — export one row per event through the system share sheet, no
  broad storage permissions required.
- **Offline & private** — works with no internet; data never leaves the device.

> **Not yet implemented:** the launcher home-screen widget for quick logging is
> part of the design (see [REQUIREMENTS.md](REQUIREMENTS.md) §3.12) but is not in
> the current build. See [Roadmap](#roadmap).

## Tech stack

| Concern            | Choice                                            |
| ------------------ | ------------------------------------------------- |
| Framework          | Flutter (Dart SDK `^3.12.0`, tested on Flutter 3.44) |
| Local database     | SQLite via [Drift](https://drift.simonbinder.eu/) (`drift` + `drift_flutter`) |
| Code generation    | `drift_dev` + `build_runner`                      |
| Sharing / export   | `share_plus`                                      |
| Lints              | `flutter_lints`                                   |
| Target platforms   | Android (incl. EMUI devices), iOS                 |

## Project structure

```text
lib/
  main.dart                  # entry point; opens the database and runs the app
  application/               # use cases / business logic (e.g. CSV export)
  data/
    db/                      # Drift database, tables, generated code
    models/                  # domain models (records, tags, event type, hex color)
    repositories/            # record & tag repositories
  presentation/
    app.dart                 # root widget
    navigation/              # bottom-nav home shell
    screens/                 # add_record, history, tags, export, settings, splash
    widgets/                 # shared UI widgets
    theme/                   # colors, typography, tokens, decorations
    localization/            # centralized user-facing strings
    util/                    # formatting helpers
test/                        # unit & widget tests mirroring lib/
docs/                        # design mockups
```

For deeper context see [ARCHITECTURE.md](ARCHITECTURE.md) (data model, layers,
SQLite schema) and [REQUIREMENTS.md](REQUIREMENTS.md) (functional/non-functional
requirements).

## Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.44 or newer
  (Dart `^3.12.0`).
- For Android: Android SDK + a device or emulator.
- For iOS: Xcode + a simulator or device (macOS only).

Verify your setup:

```bash
flutter doctor
```

### Install & run

```bash
# 1. Clone
git clone git@github.com:Javi801/peepoop-log.git
cd peepoop-log

# 2. Install dependencies
flutter pub get

# 3. Generate the Drift database code (required before the first run)
dart run build_runner build --delete-conflicting-outputs

# 4. Run on a connected device or emulator
flutter run
```


## Using the app

The app opens on a bottom navigation bar with five destinations:

1. **Add Record** (center **+** button) — pick the date & time, toggle
   **Urination** and/or **Defecation** (at least one is required), and add an
   optional description and tags for each selected type. Type a new tag name and
   press Enter to create it on the fly. Tap **Save Record**.
2. **History** — see all records grouped by day (Today / Yesterday / date). Tap a
   record to view details and edit or delete it. Use **Filters** to narrow by date
   range, event type, and tags, and to change the sort order.
3. **Tags** — manage tags grouped into **Pee** and **Poop**. Create, rename,
   recolor (random by default, editable as a 6-digit hex value), and delete tags.
   Usage counts are shown; deleting a tag removes it from records but keeps the
   records themselves.
4. **Export** — export your data as CSV. The export produces one row per event
   (a record with both urination and defecation yields two rows) and opens the
   system share sheet. Columns: `occurred_at,type,description,tags` (tags are
   semicolon-separated).
5. **Settings** — delete all app data (with confirmation), read the privacy
   statement, and view app/about information.

## Privacy

PeePoop Log handles sensitive health data and keeps it entirely on-device. It does
**not** use login, cloud storage, synchronization, Google or Meta services,
Firebase, analytics SDKs, advertising SDKs, or external tracking. There is no
in-app PIN/biometric lock — rely on your device's own security if you want an
extra layer. See the Privacy card in Settings.

## Roadmap

Planned / out of scope for the current MVP (see [ARCHITECTURE.md](ARCHITECTURE.md)
"Future Considerations" and [REQUIREMENTS.md](REQUIREMENTS.md) §7):

- Android launcher home-screen widget for quick logging (iOS later).
- CSV import.
- Statistics and trends.
- Structured observations (e.g. `color: yellow`, `pain: none`).

## License

See [LICENSE](LICENSE).
