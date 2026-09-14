import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

void main() {
  group('formatDecimal', () {
    // Replaces intl's NumberFormat.decimalPattern for validation messages.
    test('drops the fraction on whole numbers', () {
      expect(formatDecimal(5), '5');
      expect(formatDecimal(5.0), '5');
      expect(formatDecimal(-5.0), '-5');
      expect(formatDecimal(0), '0');
      expect(formatDecimal(0.0), '0');
    });

    test('keeps fractional digits', () {
      expect(formatDecimal(5.5), '5.5');
      expect(formatDecimal(0.25), '0.25');
      expect(formatDecimal(-0.5), '-0.5');
    });

    test('groups the integer part in threes', () {
      expect(formatDecimal(999), '999');
      expect(formatDecimal(1000), '1,000');
      expect(formatDecimal(1234.5), '1,234.5');
      expect(formatDecimal(1234567), '1,234,567');
      expect(formatDecimal(-1234567), '-1,234,567');
    });

    test('honours a custom separator', () {
      expect(formatDecimal(1234567, separator: '.'), '1.234.567');
      expect(formatDecimal(1000, separator: ' '), '1 000');
      expect(formatDecimal(1000, separator: ''), '1000');
    });
  });

  group('canonicalizeLocale', () {
    // Replaces intl's Intl.canonicalizedLocale.
    test('upper-cases a two or three letter region', () {
      expect(canonicalizeLocale('en_us'), 'en_US');
      expect(canonicalizeLocale('en-us'), 'en_US');
      expect(canonicalizeLocale('es_419'), 'es_419');
      expect(canonicalizeLocale('en_US'), 'en_US');
    });

    test('leaves a bare language alone', () {
      expect(canonicalizeLocale('en'), 'en');
      expect(canonicalizeLocale('fr'), 'fr');
    });

    test('leaves longer subtags alone', () {
      expect(canonicalizeLocale('zh_Hans_CN'), 'zh_Hans_CN');
      expect(canonicalizeLocale('sr_Latn'), 'sr_Latn');
    });

    test('maps the POSIX C locale', () {
      expect(canonicalizeLocale('C'), 'en_ISO');
    });
  });
}
