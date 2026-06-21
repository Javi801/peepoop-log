# Requirements

## 1. Product Scope

The app shall allow users to track urination and defecation events locally on their mobile device.

The app shall be fully offline and shall not require login, cloud services, Google services, Meta services, analytics, or external tracking.

## 2. Supported Platforms

The app shall support:

* Android.
* EMUI-based Android devices.
* iOS.

The app shall be developed using Flutter.

## 3. Functional Requirements

### 3.1 Record Creation

The app shall allow the user to create a bathroom record.

Each record shall include:

* Date and time.
* Urination selection.
* Defecation selection.

The app shall require at least one of the following to be selected:

* Urination.
* Defecation.

The app shall allow the user to manually edit the date and time.

### 3.2 Urination Details

If urination is selected, the app shall allow the user to add:

* Optional description.
* Optional tags.

The urination description and tags shall be independent from defecation description and tags.

### 3.3 Defecation Details

If defecation is selected, the app shall allow the user to add:

* Optional description.
* Optional tags.

The defecation description and tags shall be independent from urination description and tags.

### 3.4 Record Editing

The app shall allow the user to edit an existing record.

Editable fields shall include:

* Date and time.
* Urination selection.
* Defecation selection.
* Urination description.
* Urination tags.
* Defecation description.
* Defecation tags.

### 3.5 Record Deletion

The app shall allow the user to delete:

* One record.
* Multiple selected records.
* All records.

The app shall show a confirmation dialog before every delete operation.

### 3.6 History View

The app shall provide a history view showing all records.

Each record item should display:

* Date and time.
* Whether it includes urination.
* Whether it includes defecation.
* Associated tags.
* Description preview when available.

The user shall be able to open a record from the history view to edit it.

The user shall be able to select multiple records from the history view for deletion.

### 3.7 Filters

The app shall allow filtering records by:

* Date range.
* Event type.
* Tags.

Filters shall be combinable.

The event type filter shall support selecting more than one type.

The tag filter shall support selecting multiple tags.

The tag filter shall include:

* Search input.
* Top 3 most used tags shown first.
* Expand option to show all tags.
* Usage count displayed next to each tag name.

Example:

```text
yellow (5)
pain (3)
urgent (2)
```

### 3.8 Tags

The app shall allow users to manage tags.

The app shall allow users to:

* Create tags.
* Edit tag names.
* Edit tag colors.
* Delete tags.

Each tag shall include:

* Name.
* Normalized name.
* Hexadecimal color.

Tags shall not include `created_at` or `updated_at`.

The app shall normalize tag names using:

```text
lower(trim(name))
```

The app shall prevent duplicate tags based on normalized name.

The app shall not allow empty tag names.

When a tag name or color is edited, the change shall propagate to all records that use the tag.

When a tag is deleted, the app shall remove the tag from all records that use it after confirmation.

A single urination detail shall support multiple tags.

A single defecation detail shall support multiple tags.

The same tag shall not be duplicated within the same record and event type.

### 3.9 Automatic Tag Creation

When the user writes a new valid tag name while creating or editing a record, the app shall automatically create that tag if it does not already exist.

If a tag already exists according to normalized name, the app shall reuse the existing tag.

### 3.10 Tag Colors

The app shall assign a random hexadecimal color to newly created tags.

The user shall be able to edit the hexadecimal color manually.

Tag colors shall be stored on the tag entity, not copied into records.

### 3.11 CSV Export

The app shall allow manual CSV export.

The app shall not require cloud storage for export.

The CSV shall use one row per event.

If a record contains both urination and defecation, the export shall include two rows.

The CSV shall include at least:

```text
occurred_at,type,description,tags
```

Tags shall be separated using semicolons.

Example:

```csv
occurred_at,type,description,tags
2026-06-19T08:30:00,urination,"Example note","tag1;tag2"
2026-06-19T08:30:00,defecation,"Example note","tag3"
```

### 3.12 Launcher Widget

The app shall provide a launcher widget for quick record creation.

The widget should include:

* `+ Urination`
* `+ Defecation`
* `+ Both`
* `Open full record`

Quick widget actions shall create a record using the current date and time.

Quick widget records shall not include descriptions or tags by default.

The widget shall not display recent records.

Android widget support should be prioritized first.

iOS widget support may be implemented later if needed.

### 3.13 Settings

The app shall include a Settings screen.

The Settings screen shall include:

* CSV export.
* Delete all records.
* Privacy statement.
* App version.
* Owner/developer information.
* Contact option for feedback.
* Contact option for bug reports.
* Contact option for feature requests.

## 4. Privacy Requirements

The app shall store all user data locally on the device.

The app shall not require user login.

The app shall not use cloud synchronization.

The app shall not use:

* Google services.
* Meta services.
* Firebase.
* Analytics SDKs.
* Advertising SDKs.
* External tracking services.

The app shall clearly state that data is stored only on the device.

The app shall not implement PIN or biometric lock internally. Users may rely on device-level security.

## 5. Permission Requirements

The app should request no permissions unless strictly necessary.

For CSV export, the app should use the system file picker or share sheet.

The app should avoid broad storage permissions.

## 6. Non-Functional Requirements

### 6.1 Offline Operation

The app shall work without internet access.

### 6.2 Performance

The app should remain responsive with thousands of records.

Filtering should be performed locally.

### 6.3 Data Integrity

The app shall enforce:

* No duplicate tags by normalized name.
* No empty tag names.
* No empty records.
* No duplicated tag association within the same record and event type.

### 6.4 Maintainability

The codebase should separate:

* Presentation layer.
* Application/business logic layer.
* Data persistence layer.

### 6.5 Portability

The app should avoid dependencies that require Google Play Services.

The app should remain compatible with EMUI-based Android devices.

## 7. Out of Scope for MVP

The following features are out of scope for the initial version:

* Cloud synchronization.
* Login.
* Analytics.
* Statistics.
* Import from CSV.
* Tag categories.
* Structured observations such as `color: yellow` or `pain: none`.
* Internal PIN or biometric lock.
* Medical interpretation or diagnosis.
