# In-Class 08 / Fall Festival Roster

Kirtan Patel / Mobile App Development
Flutter 3.47.2 (stable) / Dart 3.13.2; device / OS: Android emulator `sdk gphone16k x86 64` (emulator-5554), Android 17 (API 37)
Setup/run commands:

```
flutter pub get
flutter devices
flutter run -d emulator-5554
```

Packages: `sqflite ^2.4.1`, `path_provider ^2.1.5`, `path ^1.9.0` (merged into the existing `dependencies:` block). The SDK constraint stayed at the generated project's `^3.13.2`, which satisfies the sample's `^3.6.1`. The generated counter test `test/widget_test.dart` was removed because it referred to the old counter widget. No tests are included.

## Storage notes
- **Schema and initialization:** `lib/database_helper.dart` (starter code) opens `MyDatabase.db` in the app documents directory. On first creation, `onCreate` makes `my_table(_id INTEGER PRIMARY KEY, name TEXT NOT NULL, age INTEGER NOT NULL)`. `main()` creates one `DatabaseHelper`, awaits `init()` before `runApp`, and shows an error screen if that fails. The same instance goes to `DirectoryApp`, then `RosterScreen`. The first load happens in `initState()`.
- **Input policy, IDs, and where the CRUD code is:** a name must be nonempty after trimming. Age must pass `int.tryParse`, and it must be from 0 through 130 inclusive. Invalid input shows a message under the field and writes nothing. SQLite generates the IDs, and Edit and Delete target the row's integer `_id`, never its name or list position. My change to the starter: `queryAllRows()` now sorts with `orderBy: '_id ASC'`. Code locations in `lib/main.dart`:
  - read: `_load()` (line 89)
  - insert and update: `_save()` (line 150; calls at 164 and 170)
  - delete: `_delete()` (line 233; call at 263)
- **Memory / preference / SQLite examples:**
  - Memory: the text you are typing, `_busy`, and `_selectedId`. These are lost when the app restarts.
  - Key-value preference: an example would be a "last sort order" or theme setting. This app does not store any preferences.
  - SQLite: the guest rows (`_id`, `name`, `age`) in `my_table`.

## Notes
Analyzer command/result: `flutter analyze`, "No issues found!" (saved in evidence/analysis_output.txt).
Known limitations: validation exists only in the UI, so the schema itself still accepts `''` or a negative age. There is no search, and there is no undo after a delete. The project folder is named `in_class_08`.

## Attribution
- Starter code: `lib/database_helper.dart`
- References: Flutter SQLite cookbook, sqflite documentation.
- AI assistance: I did make code with Claude.
