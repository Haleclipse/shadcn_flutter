import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

Widget _app({required Locale locale, required Widget child}) => ShadcnApp(
  locale: locale,
  supportedLocales: ShadcnLocalizations.supportedLocales,
  home: child,
);

void main() {
  group('delegate', () {
    test('supports every locale it ships', () {
      for (final locale in ShadcnLocalizations.supportedLocales) {
        expect(
          ShadcnLocalizations.delegate.isSupported(locale),
          isTrue,
          reason: '$locale',
        );
      }
    });

    test('ignores the region when matching', () {
      expect(
        ShadcnLocalizations.delegate.isSupported(const Locale('pt', 'BR')),
        isTrue,
      );
      expect(
        lookupShadcnLocalizations(const Locale('pt', 'BR')),
        isA<ShadcnLocalizationsPt>(),
      );
    });

    test('rejects a locale it does not ship', () {
      expect(
        ShadcnLocalizations.delegate.isSupported(const Locale('xx')),
        isFalse,
      );
      expect(
        () => lookupShadcnLocalizations(const Locale('xx')),
        throwsFlutterError,
      );
    });

    test('script variants beat the bare language', () {
      expect(
        lookupShadcnLocalizations(
          const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
        ),
        isA<ShadcnLocalizationsZhHant>(),
      );
      expect(
        lookupShadcnLocalizations(const Locale('zh')),
        isA<ShadcnLocalizationsZh>(),
      );
    });

    test('a region that writes the script gets it without a script subtag', () {
      for (final country in const ['TW', 'HK', 'MO']) {
        expect(
          lookupShadcnLocalizations(Locale('zh', country)),
          isA<ShadcnLocalizationsZhHant>(),
          reason: 'zh_$country',
        );
      }
      expect(
        lookupShadcnLocalizations(const Locale('zh', 'CN')),
        isA<ShadcnLocalizationsZh>(),
      );
    });

    test('an explicit script wins over the region shorthand', () {
      // `&&` binds tighter than `||`: without parentheses around the country
      // list this would have resolved to Traditional.
      expect(
        lookupShadcnLocalizations(
          const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hans',
            countryCode: 'HK',
          ),
        ),
        isA<ShadcnLocalizationsZh>(),
      );
    });

    test('every shipped locale resolves to a distinct implementation', () {
      final seen = <Type>{};
      for (final locale in ShadcnLocalizations.supportedLocales) {
        final localizations = lookupShadcnLocalizations(locale);
        expect(
          seen.add(localizations.runtimeType),
          isTrue,
          reason: '${localizations.runtimeType} is reused by $locale',
        );
        expect(localizations.localeName, startsWith(locale.languageCode));
      }
      expect(seen.length, ShadcnLocalizations.supportedLocales.length);
    });
  });

  group('translations', () {
    test('no locale leaves a string in English', () {
      // Not a translation-quality check — it catches a locale file that was
      // copied from the template and never translated.
      final english = lookupShadcnLocalizations(const Locale('en'));
      for (final locale in ShadcnLocalizations.supportedLocales) {
        if (locale.languageCode == 'en') continue;
        final other = lookupShadcnLocalizations(locale);
        expect(
          other.buttonCancel,
          isNot(english.buttonCancel),
          reason: '${locale.languageCode} did not translate buttonCancel',
        );
        expect(
          other.commandEmpty,
          isNot(english.commandEmpty),
          reason: '${locale.languageCode} did not translate commandEmpty',
        );
      }
    });

    test('placeholders survive translation', () {
      for (final locale in ShadcnLocalizations.supportedLocales) {
        final l = lookupShadcnLocalizations(locale);
        final code = locale.languageCode;
        expect(l.formLessThan('7'), contains('7'), reason: code);
        expect(l.formGreaterThan('7'), contains('7'), reason: code);
        expect(l.formEqualTo('7'), contains('7'), reason: code);
        expect(l.formLengthLessThan(3), contains('3'), reason: code);
        final between = l.formBetweenInclusively('2', '9');
        expect(between, contains('2'), reason: code);
        expect(between, contains('9'), reason: code);
        final rows = l.dataTableSelectedRows(4, 11);
        expect(rows, contains('4'), reason: code);
        expect(rows, contains('11'), reason: code);
      }
    });

    test('every message is non-empty in every locale', () {
      for (final locale in ShadcnLocalizations.supportedLocales) {
        final l = lookupShadcnLocalizations(locale);
        final code = locale.languageCode;
        for (final value in <String>[
          l.formNotEmpty,
          l.invalidValue,
          l.commandSearch,
          l.buttonSave,
          l.monthJanuary,
          l.abbreviatedMonday,
          l.timeHour,
          l.colorRed,
          l.menuCopy,
          l.placeholderDatePicker,
          l.refreshTriggerPull,
          l.durationDay,
        ]) {
          expect(value.trim(), isNotEmpty, reason: code);
        }
      }
    });
  });

  group('text direction', () {
    // Every right-to-left language this package ships.
    const rtl = {'ar', 'fa', 'he', 'ps', 'ur'};

    test('right-to-left languages report rtl, the rest ltr', () {
      for (final locale in ShadcnLocalizations.supportedLocales) {
        final expected = rtl.contains(locale.languageCode)
            ? TextDirection.rtl
            : TextDirection.ltr;
        expect(
          lookupShadcnLocalizations(locale).textDirection,
          expected,
          reason: locale.languageCode,
        );
      }
    });

    testWidgets('ShadcnApp mirrors for an RTL locale', (tester) async {
      late TextDirection seen;
      await tester.pumpWidget(
        _app(
          locale: const Locale('ar'),
          child: Builder(
            builder: (context) {
              seen = Directionality.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // WidgetsApp would say ltr here: without package:flutter_localizations
      // its WidgetsLocalizations is always DefaultWidgetsLocalizations.
      expect(seen, TextDirection.rtl);
    });

    testWidgets('every RTL language mirrors', (tester) async {
      for (final language in rtl) {
        late TextDirection seen;
        await tester.pumpWidget(
          _app(
            locale: Locale(language),
            child: Builder(
              builder: (context) {
                seen = Directionality.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        expect(seen, TextDirection.rtl, reason: language);
      }
    });

    testWidgets('ShadcnApp stays LTR for an LTR locale', (tester) async {
      late TextDirection seen;
      await tester.pumpWidget(
        _app(
          locale: const Locale('ja'),
          child: Builder(
            builder: (context) {
              seen = Directionality.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(seen, TextDirection.ltr);
    });
  });

  testWidgets('of() returns the strings for the app locale', (tester) async {
    late ShadcnLocalizations localizations;
    await tester.pumpWidget(
      _app(
        locale: const Locale('de'),
        child: Builder(
          builder: (context) {
            localizations = ShadcnLocalizations.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(localizations, isA<ShadcnLocalizationsDe>());
    expect(localizations.buttonCancel, 'Abbrechen');
  });
}
