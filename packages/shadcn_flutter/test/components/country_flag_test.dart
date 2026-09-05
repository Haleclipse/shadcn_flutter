import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../test_helper.dart';

void main() {
  group('CountryFlag lookups', () {
    test('resolves an alpha-2 country code, case-insensitively', () {
      expect(CountryFlag.fromCountryCode('US').country, Country.unitedStates);
      expect(CountryFlag.fromCountryCode('us').country, Country.unitedStates);
    });

    test('resolves a currency code', () {
      expect(CountryFlag.fromCurrencyCode('JPY').country, Country.japan);
    });

    test('resolves a dial code with or without the plus', () {
      expect(CountryFlag.fromPhonePrefix('+81').country, Country.japan);
      expect(CountryFlag.fromPhonePrefix('81').country, Country.japan);
    });

    test('yields a null country for codes it does not know', () {
      expect(CountryFlag.fromCountryCode('ZZ').country, isNull);
      expect(CountryFlag.fromCurrencyCode('ZZZ').country, isNull);
      expect(CountryFlag.fromPhonePrefix('+99999').country, isNull);
    });
  });

  group('CountryFlag rendering', () {
    testWidgets('draws the regional-indicator emoji by default', (tester) async {
      await tester.pumpWidget(
        SimpleApp(child: CountryFlag.fromCountryCode('JP')),
      );

      expect(find.text(Country.japan.flag), findsOneWidget);
    });

    testWidgets('an unknown code renders an empty box, not an exception', (
      tester,
    ) async {
      await tester.pumpWidget(
        SimpleApp(
          child: CountryFlag.fromCountryCode('ZZ', width: 24, height: 18),
        ),
      );

      expect(tester.takeException(), isNull);
      final box = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(CountryFlag),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(box.width, 24);
      expect(box.height, 18);
    });

    testWidgets('a theme builder replaces the artwork', (tester) async {
      await tester.pumpWidget(
        SimpleApp(
          child: ComponentTheme(
            data: CountryFlagTheme(
              builder: (context, details) => Text('flag:${details.countryCode}'),
            ),
            child: CountryFlag.fromCountryCode('JP'),
          ),
        ),
      );

      expect(find.text('flag:JP'), findsOneWidget);
      expect(find.text(Country.japan.flag), findsNothing);
    });

    testWidgets('the builder receives the resolved size and shape', (
      tester,
    ) async {
      late CountryFlagDetails seen;
      const shape = CircleBorder();
      await tester.pumpWidget(
        SimpleApp(
          child: ComponentTheme(
            data: CountryFlagTheme(
              builder: (context, details) {
                seen = details;
                return const SizedBox.shrink();
              },
            ),
            child: CountryFlag.fromCountryCode(
              'JP',
              width: 30,
              height: 20,
              shape: shape,
            ),
          ),
        ),
      );

      expect(seen.country, Country.japan);
      expect(seen.width, 30);
      expect(seen.height, 20);
      expect(seen.shape, shape);
    });

    testWidgets('the widget argument wins over the ambient theme', (
      tester,
    ) async {
      late CountryFlagDetails seen;
      await tester.pumpWidget(
        SimpleApp(
          child: ComponentTheme(
            data: CountryFlagTheme(
              width: 100,
              height: 80,
              builder: (context, details) {
                seen = details;
                return const SizedBox.shrink();
              },
            ),
            child: CountryFlag.fromCountryCode('JP', width: 30),
          ),
        ),
      );

      expect(seen.width, 30, reason: 'set on the widget');
      expect(seen.height, 80, reason: 'inherited from the theme');
    });
  });
}
