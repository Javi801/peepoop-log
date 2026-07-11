# Architecture

## Overview

This application is a fully offline mobile app for tracking urination and defecation events. It is designed for Android, EMUI-based Android devices, and iPhone using Flutter.

The app must not depend on Google, Meta, Firebase, cloud login, cloud storage, analytics SDKs, or remote services. All user data is stored locally on the device.

## Core Principles

* 100% offline-first.
* No user account or login.
* No cloud synchronization.
* No Google or Meta services.
* No analytics or tracking SDKs.
* No external backend.
* Minimal permissions.
* User-controlled manual CSV export.
* Sensitive health-related data remains on the device.

## Technology Stack

* Framework: Flutter
* Local database: SQLite
* Suggested database abstraction: Drift or equivalent SQLite wrapper
* State management: project-dependent, but should remain lightweight
* Export format: CSV
* Supported platforms:

  * Android
  * EMUI-based Android devices
  * iOS

## Data Model

### Record

A record represents one timestamped bathroom event. A record may include urination, defecation, or both.

```text
Record
- id
- occurred_at
- has_urination
- has_defecation
- urination_description
- defecation_description
```

Rules:

* `occurred_at` must be editable.
* At least one of `has_urination` or `has_defecation` must be true.
* A record can contain both urination and defecation events.
* Descriptions are optional and stored inline on the record, one per event type.
* A description may only exist when its event type is selected. This is enforced with `CHECK` constraints.
* Tags are attached through a many-to-many relationship. Urination events use urination-type tags only, and defecation events use defecation-type tags only.

### Tag

```text
Tag
- id
- name
- normalized_name
- type: urination | defecation
- color_hex
- UNIQUE (normalized_name, type)
```

Rules:

* Each tag belongs to exactly one event type: urination or defecation.
* Tags are reused across all records of their event type.
* Tags must not be duplicated within the same event type.
* Duplicate detection is based on normalized name plus event type. The same normalized name may exist once per type.
* `normalized_name` should be generated using `lower(trim(name))`.
* Tags do not require `created_at` or `updated_at`.
* `color_hex` is randomly assigned by default and editable by the user.
* Editing a tag name or color propagates to all records using that tag.
* Deleting a tag removes its associations from records after confirmation.

### Record Tag Association

The event context of each association is derived from the tag's own type, so the association only links a record with a tag.

```text
RecordTag
- record_id
- tag_id
```

Rules:

* A single record can have different tags for urination and defecation, resolved through each tag's type.
* Urination details only use urination tags; defecation details only use defecation tags.
* The same tag must not be duplicated within the same record.

## Suggested SQLite Structure

```sql
CREATE TABLE records (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  occurred_at INTEGER NOT NULL, -- unix epoch seconds (Drift dateTime); the local instant, not forced to UTC
  has_urination INTEGER NOT NULL DEFAULT 0,
  has_defecation INTEGER NOT NULL DEFAULT 0,
  urination_description TEXT,
  defecation_description TEXT,
  CHECK (has_urination = 1 OR has_defecation = 1),
  CHECK (has_urination = 1 OR urination_description IS NULL),
  CHECK (has_defecation = 1 OR defecation_description IS NULL)
);

CREATE INDEX idx_records_occurred_at ON records (occurred_at);

CREATE TABLE tags (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  normalized_name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('urination', 'defecation')),
  color_hex TEXT NOT NULL,
  UNIQUE (normalized_name, type),
  CHECK (length(trim(name)) > 0)
);

CREATE TABLE record_tags (
  record_id INTEGER NOT NULL,
  tag_id INTEGER NOT NULL,
  PRIMARY KEY (record_id, tag_id),
  FOREIGN KEY (record_id) REFERENCES records(id) ON DELETE CASCADE,
  FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
);

CREATE INDEX idx_record_tags_tag ON record_tags (tag_id);
```

Foreign keys must be enabled on every connection with `PRAGMA foreign_keys = ON`, since SQLite disables them by default.

## App Layers

### Presentation Layer

Contains Flutter screens, widgets, forms, dialogs, and navigation.

Main responsibilities:

* Record creation and editing.
* Record history display.
* Filtering UI.
* Tag management UI.
* Settings and export UI.
* Confirmation dialogs.

### Application Layer

Holds stateless services that transform data but do not own persistence. In the
current implementation this layer is intentionally thin: it contains the CSV
exporter (`CsvExporter`), a pure function that turns records into CSV text.

Most write and validation logic — creating, editing, and deleting records;
resolving and normalizing tags from user input; building and applying filters —
lives in the repositories of the data layer rather than in a separate use-case
layer. For an app of this size, keeping that logic on the repositories avoids a
redundant indirection layer.

### Data Layer

Contains SQLite access and local repositories. The repositories are also where
record/tag business rules (shape validation, tag-type matching, normalized-name
uniqueness, filtering) are enforced.

Examples:

* Record repository.
* Tag repository.
* The Drift database definition and its migration strategy.

There is no dedicated export repository: CSV building is a pure service in the
application layer (`CsvExporter`), and it reads records through the record
repository. The database is at schema version 1 with no migration steps yet; the
migration strategy is in place for future schema changes.

## Main Screens

### Navigation Shell

The app boots into a splash screen that opens the database, then hosts five
top-level destinations behind a shared bottom navigation bar:

* Add Record (the central "+" action).
* History.
* Tags.
* Export.
* Settings.

Each destination is a root screen kept alive in an `IndexedStack`, so switching
tabs preserves each screen's state.

### Quick Record Screen

Used to create or edit a record.

Fields:

* Date and time.
* Urination checkbox.
* Defecation checkbox.
* Urination description.
* Urination tags.
* Defecation description.
* Defecation tags.
* Save button.

Behavior:

* Urination fields appear only when urination is selected.
* Defecation fields appear only when defecation is selected.
* At least one type must be selected.
* Tags are created automatically when the user enters a new valid tag name.

### History Screen

Displays all records chronologically.

Features:

* List of records.
* Date and time.
* Urination/defecation indicators.
* Tags with color.
* Short description preview.
* Tap to edit.
* Multi-select mode.
* Delete one or multiple records with confirmation.

### Filters Screen or Filter Panel

Filters can be combined.

Supported filters:

* Date range.
* Event type:

  * Urination.
  * Defecation.
  * Both.
* Multiple tags.

Tag filter behavior:

* Search input below the filter title.
* Show the top 3 tags by usage count first.
* Allow expanding to show all tags.
* Display usage count next to each tag name, for example: `pain (4)`.

### Tag Management Screen

Features:

* List all tags in two groups: urination tags and defecation tags (for example, using tabs).
* Create tag.
* Edit tag name.
* Edit tag hexadecimal color.
* Delete tag with confirmation.
* Show usage count.
* Prevent duplicate tags based on normalized name and event type.

### Settings Screen

Features:

* Delete all records with confirmation.
* Privacy statement.
* App version.
* Owner/developer information.
* Contact option for feedback, bug reports, or feature requests.

CSV export is not part of Settings; it is its own top-level destination (see the
Export Screen below), which keeps the primary action visible in the navigation
bar instead of nested inside Settings.

### Export Screen

A dedicated destination that builds the CSV from all records and hands it to the
system share sheet. See the [CSV Export](#csv-export) section for the row format.

## Launcher Widget

The app should support a launcher widget to make logging faster.

Recommended widget actions:

* `+ Urination`
* `+ Defecation`
* `+ Both`
* `Open full record`

Behavior:

* Quick actions create a new record using the current date and time.
* Quick-created records have no description or tags by default.
* Users can edit the record later from the history screen.
* The widget must not display recent records, to preserve privacy.

Implementation note:

* Android widget support should be prioritized first.
* iOS widget support may be implemented later if it increases complexity.

## CSV Export

CSV export should be manual and local.

The export should use one row per physiological event, not one row per parent record.

If a record contains both urination and defecation, it should produce two CSV rows.

Recommended columns:

```text
occurred_at,type,description,tags
```

Example:

```csv
occurred_at,type,description,tags
2026-06-19T08:30:00,urination,"Light description","tag1;tag2"
2026-06-19T08:30:00,defecation,"Another description","tag3"
```

Rules:

* Tags should be separated with semicolons.
* CSV export must not require cloud storage.
* The app should use the system file picker/share sheet where possible.
* The app should avoid broad storage permissions.

## Privacy

The app handles sensitive health-related information.

Privacy requirements:

* Data is stored locally on the device.
* No login.
* No cloud storage.
* No analytics.
* No advertising SDKs.
* No external tracking.
* No Google or Meta services.
* The app must clearly explain this in Settings.

PIN or biometric lock is not part of the app scope. Users may rely on device-level security settings.

## Future Considerations

Potential future features:

* Import from CSV.
* Statistics and trends.
* Tag categories.
* Structured observations such as:

  * `color: yellow`
  * `odor: none`
  * `pain: none`
* Advanced filtering.
* iOS launcher widget support if not included in MVP.
