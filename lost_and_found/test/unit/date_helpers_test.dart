import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lost_and_found/utils/date_helpers.dart';

void main() {
  group('formatShortDate', () {
    test('formats normal date correctly', () {
      final ts = Timestamp.fromDate(DateTime(2024, 1, 15));
      expect(formatShortDate(ts), 'Jan 15, 2024');
    });

    test('formats end of year correctly', () {
      final ts = Timestamp.fromDate(DateTime(2024, 12, 31));
      expect(formatShortDate(ts), 'Dec 31, 2024');
    });

    test('returns "Date unknown" for null timestamp', () {
      expect(formatShortDate(null), 'Date unknown');
    });

    test('formats single digit day without padding', () {
      final ts = Timestamp.fromDate(DateTime(2024, 6, 1));
      expect(formatShortDate(ts), 'Jun 1, 2024');
    });

    test('formats all months correctly', () {
      final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      for (int i = 0; i < 12; i++) {
        final ts = Timestamp.fromDate(DateTime(2024, i + 1, 10));
        expect(formatShortDate(ts), '${monthNames[i]} 10, 2024');
      }
    });
  });

  group('formatFullDate', () {
    test('formats afternoon time correctly', () {
      final ts = Timestamp.fromDate(DateTime(2024, 3, 15, 14, 30));
      expect(formatFullDate(ts), 'March 15, 2024 at 2:30 PM');
    });

    test('formats midnight (hour 0) correctly', () {
      final ts = Timestamp.fromDate(DateTime(2024, 1, 1, 0, 5));
      expect(formatFullDate(ts), 'January 1, 2024 at 12:05 AM');
    });

    test('formats noon (hour 12) correctly', () {
      final ts = Timestamp.fromDate(DateTime(2024, 7, 4, 12, 0));
      expect(formatFullDate(ts), 'July 4, 2024 at 12:00 PM');
    });

    test('formats morning single-digit hour correctly', () {
      final ts = Timestamp.fromDate(DateTime(2024, 11, 25, 9, 0));
      expect(formatFullDate(ts), 'November 25, 2024 at 9:00 AM');
    });

    test('formats 1 PM correctly', () {
      final ts = Timestamp.fromDate(DateTime(2024, 5, 10, 13, 45));
      expect(formatFullDate(ts), 'May 10, 2024 at 1:45 PM');
    });

    test('returns "Date unknown" for null timestamp', () {
      expect(formatFullDate(null), 'Date unknown');
    });

    test('pads single-digit minutes with zero', () {
      final ts = Timestamp.fromDate(DateTime(2024, 2, 14, 8, 5));
      expect(formatFullDate(ts), 'February 14, 2024 at 8:05 AM');
    });

    test('formats 11 AM correctly', () {
      final ts = Timestamp.fromDate(DateTime(2024, 8, 20, 11, 30));
      expect(formatFullDate(ts), 'August 20, 2024 at 11:30 AM');
    });
  });
}
