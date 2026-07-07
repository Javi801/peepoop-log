/// User-facing copy centralized ahead of full localization support.
abstract final class AppStrings {
  static const appName = 'PeePoop Log';

  static const navAddRecord = 'Add Record';
  static const navHistory = 'History';
  static const navTags = 'Tags';
  static const navExport = 'Export';
  static const navSettings = 'Settings';

  static const startupErrorTitle = 'Could not open your data';

  static const splashTitle = 'PeePoop\nLog';
  static const splashSubtitle = 'Your health, your log 💜';
  static const splashLoading = 'Loading your data...';

  static const addRecordTitle = 'Add Record';
  static const addRecordNow = 'Now';
  static const addRecordDateTime = 'Date and time';
  static const addRecordDateTimeSeparator = ' · ';
  static const addRecordSave = 'Save Record';
  static const recordSaved = 'Record saved';

  static const editRecordTitle = 'Edit Record';
  static const editRecordSave = 'Save Changes';
  static const recordUpdated = 'Record updated';
  static const recordDeleted = 'Record deleted';
  static const editRecordDelete = 'Delete record';
  static const editRecordDeleteDialogTitle = 'Delete this record?';
  static const editRecordDeleteDialogMessage =
      'This record will be permanently removed. '
      'This action cannot be undone.';

  static const urination = 'Urination';
  static const defecation = 'Defecation';
  static const urinationAndDefecation = 'Urination + Defecation';
  static const urinationDescription = 'Urination description';
  static const urinationDescriptionHint = 'No discomfort.';
  static const urinationTags = 'Urination tags';
  static const defecationDescription = 'Defecation description';
  static const defecationDescriptionHint = 'Write something...';
  static const defecationTags = 'Defecation tags';

  static const historyTitle = 'History';
  static const historyFilters = 'Filters';
  static const historyEmpty = 'No records found.';
  static const historyToday = 'Today';
  static const historyYesterday = 'Yesterday';
  static const historyEdit = 'Edit record';

  static const filtersTitle = 'Filters';
  static const filtersSortBy = 'Sort by';
  static const filtersSortNewest = 'Newest first';
  static const filtersSortOldest = 'Oldest first';
  static const filtersDateRange = 'Date range';
  static const filtersType = 'Type';
  static const filtersFrom = 'From';
  static const filtersTo = 'To';
  static const filtersTags = 'Tags';
  static const filtersTagsHint = 'Select tags';
  static const filtersClear = 'Clear';
  static const filtersApply = 'Apply';
  static const filtersAny = 'Any';

  static const settingsTitle = 'Settings';
  static const settingsDeleteAllTitle = 'Delete all app data';
  static const settingsDeleteAllDialogTitle = 'Delete all app data?';
  static const settingsDeleteAllDialogMessage =
      'This will permanently delete all records and tags. '
      'This action cannot be undone.';
  static const settingsDeleteAllBody =
      'Deletes all records and tags after confirmation.';
  static const settingsDeleted = 'All app data deleted';
  static const settingsPrivacyTitle = 'Privacy';
  static const settingsPrivacyBody =
      'All data is stored only on this device. No login, cloud, '
      'analytics, Firebase, Google services, Meta services, or '
      'tracking.';
  static const settingsAboutTitle = 'About';
  static const settingsAboutBody =
      'PeePoop Log\nVersion 0.1.0\n'
      'Developer contact: your.email@example.com';

  static const tagsTitle = 'Tags';
  static const tagsDelete = 'Delete';
  static const tagsNew = '+ New Tag';
  static const tagsEmpty = 'No tags yet.';
  static const tagsDeleteSelected = 'Delete selected tags';
  static const tagsDeleteSelectedDialogTitle = 'Delete selected tags?';
  static const tagsDeleteSelectedDialogMessage =
      'Selected tags will be removed from all records that use '
      'them. Records and descriptions will remain.';
  static const tagsPee = 'Pee';
  static const tagsPoop = 'Poop';

  static const editTagNewTitle = 'New Tag';
  static const editTagEditTitle = 'Edit Tag';
  static const editTagName = 'Name';
  static const editTagColor = 'Color';
  static const editTagHexColor = 'Hexadecimal color';
  static const editTagNameRequired = 'Tag name is required.';
  static const editTagColorInvalid = 'Color must be a 6-digit hex value.';
  static const editTagDuplicate = 'Tag already exists.';
  static const editTagSave = 'Save';
  static const editTagDelete = 'Delete tag';
  static const editTagDeleteDialogTitle = 'Delete this tag?';
  static const editTagDeleteDialogMessage =
      'The tag will be removed from all records that use it. '
      'Records and descriptions will remain.';

  static const colorPickerTitle = 'Pick a color';
  static const colorPickerSelect = 'Select';

  static const exportTitle = 'Export';
  static const exportHeroTitle = 'Export your data';
  static const exportHeroBody =
      'Export one row per urination or defecation event.';
  static const exportCsv = 'Export CSV';

  static const tagInputHint = 'Type a tag and press Enter';
  static const tagInputAddTooltip = 'Add tag';

  static const cancel = 'Cancel';
  static const close = 'Close';
  static const confirmDelete = 'Delete';

  static String recordTypeLabel({
    required bool hasUrination,
    required bool hasDefecation,
  }) {
    if (hasUrination && hasDefecation) return urinationAndDefecation;
    if (hasUrination) return urination;
    return defecation;
  }

  static String tagUsageCount(int count) => '$count uses';
}
