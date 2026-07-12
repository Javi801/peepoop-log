import 'package:flutter_test/flutter_test.dart';
import 'package:peepoop_log/presentation/util/date_time_format.dart';

void main() {
  group('formatHourMinute', () {
    test('zero-pads hour and minute to two digits', () {
      expect(formatHourMinute(DateTime(2026, 6, 1, 8, 5)), '08:05');
      expect(formatHourMinute(DateTime(2026, 6, 1, 0, 0)), '00:00');
      expect(formatHourMinute(DateTime(2026, 6, 1, 23, 59)), '23:59');
    });
  });

  group('formatMonthDayYear', () {
    test('formats as abbreviated month, day and year', () {
      expect(formatMonthDayYear(DateTime(2026, 6, 1)), 'Jun 1, 2026');
      expect(formatMonthDayYear(DateTime(2026, 1, 15)), 'Jan 15, 2026');
      expect(formatMonthDayYear(DateTime(2025, 12, 31)), 'Dec 31, 2025');
    });

    test('ignores the time of day', () {
      expect(formatMonthDayYear(DateTime(2026, 3, 9, 23, 59)), 'Mar 9, 2026');
    });
  });

  group('calendarDaysAgo', () {
    test('is 0 on the same calendar day regardless of time', () {
      expect(
        calendarDaysAgo(DateTime(2026, 6, 1, 0, 1), DateTime(2026, 6, 1, 23, 59)),
        0,
      );
    });

    test('is 1 for the day before, ignoring the time of day', () {
      expect(
        calendarDaysAgo(DateTime(2026, 6, 1, 23, 0), DateTime(2026, 6, 2, 1, 0)),
        1,
      );
    });

    test('counts whole days across month boundaries', () {
      expect(
        calendarDaysAgo(DateTime(2026, 5, 31), DateTime(2026, 6, 2)),
        2,
      );
    });

    test('is negative when the date is after the reference', () {
      expect(
        calendarDaysAgo(DateTime(2026, 6, 3), DateTime(2026, 6, 1)),
        -2,
      );
    });
  });
}
