/// Toggle-style mutation for selection sets.
extension SetToggle<T> on Set<T> {
  /// Removes [value] when present, adds it otherwise.
  void toggle(T value) {
    if (contains(value)) {
      remove(value);
    } else {
      add(value);
    }
  }
}
