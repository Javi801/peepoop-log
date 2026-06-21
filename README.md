# peepoop-log

A fully offline mobile app for tracking urination and defecation events.

The app is designed for personal health tracking, including use cases related to traditional Chinese medicine observation. It allows users to quickly record bathroom events with date, time, optional descriptions, and customizable tags.

## Goals

* Track urination and defecation events.
* Keep all data offline.
* Avoid login, cloud services, analytics, Google services, and Meta services.
* Provide a simple and fast logging experience.
* Allow users to export their data manually as CSV.

## Platforms

* Android
* EMUI-based Android devices
* iOS

The app is built with Flutter.

## Main Features

### Record Bathroom Events

Users can create a record with:

* Date and time.
* Urination checkbox.
* Defecation checkbox.
* Optional urination description.
* Optional defecation description.
* Optional urination tags.
* Optional defecation tags.

A record can include:

* Only urination.
* Only defecation.
* Both urination and defecation.

### Edit Records

Users can edit existing records, including:

* Date and time.
* Event type.
* Descriptions.
* Tags.

### Delete Records

Users can delete:

* One record.
* Multiple selected records.
* All records.

All delete actions require confirmation.

### Tag Management

Users can:

* Create tags.
* Edit tags.
* Delete tags.
* Assign colors to tags.
* Use multiple tags per urination or defecation detail.

Tags are global and reused across records.

Duplicate tags are not allowed. Tag uniqueness is based on normalized names using:

```text
lower(trim(name))
```

Tag color is assigned randomly by default and can be edited using a hexadecimal color value.

### Filters

Users can filter records by:

* Date range.
* Event type.
* Multiple tags.

Filters can be combined.

The tag filter should behave similarly to retail brand filters:

* Search input below the tag filter title.
* Show the top 3 most used tags first.
* Allow expanding to view all tags.
* Show usage count next to each tag name.

Example:

```text
pain (4)
yellow (2)
urgent (1)
```

### CSV Export

Users can manually export their data as CSV.

The CSV uses one row per event. If a record includes both urination and defecation, it produces two rows.

Recommended columns:

```text
occurred_at,type,description,tags
```

Example:

```csv
occurred_at,type,description,tags
2026-06-19T08:30:00,urination,"Example note","tag1;tag2"
2026-06-19T08:30:00,defecation,"Example note","tag3"
```

### Launcher Widget

The app should include a launcher widget for fast logging.

Recommended widget actions:

* `+ Urination`
* `+ Defecation`
* `+ Both`
* `Open full record`

Quick actions create a new record with the current date and time, without tags or descriptions. The user can edit the record later from the app.

The widget should not display recent records for privacy reasons.

### Settings

The Settings screen includes:

* CSV export.
* Delete all records.
* Privacy statement.
* App version.
* Owner/developer information.
* Contact option for feedback, bug reports, or feature requests.

## Privacy

This app stores data only on the user’s device.

The app does not use:

* Login.
* Cloud storage.
* Google services.
* Meta services.
* Firebase.
* Analytics SDKs.
* Advertising SDKs.
* External tracking.

PIN or biometric lock is not implemented inside the app. Users can use device-level security settings if they want additional protection.

## Development Notes

Recommended stack:

* Flutter.
* SQLite.
* Drift or another local SQLite abstraction.
* Local CSV export.
* Platform-specific launcher widget implementation.

Android launcher widget support should be prioritized first. iOS widget support may be added later if needed.
