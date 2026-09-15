import 'package:docs/code_highlighter.dart';
import 'package:docs/pages/docs_page.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class LocalizationsPage extends StatefulWidget {
  const LocalizationsPage({super.key});

  @override
  State<LocalizationsPage> createState() => _LocalizationsPageState();
}

class _LocalizationsPageState extends State<LocalizationsPage> {
  final keySetup = OnThisPage();
  final keyReading = OnThisPage();
  final keyOverriding = OnThisPage();
  final keyNewLocale = OnThisPage();
  final keyVariants = OnThisPage();
  final keyFormatting = OnThisPage();
  final keyDirectionality = OnThisPage();

  @override
  Widget build(BuildContext context) {
    return DocsPage(
      name: 'localizations',
      onThisPage: {
        'Setting Up': keySetup,
        'Reading Strings': keyReading,
        'Overriding Strings': keyOverriding,
        'Adding a Locale': keyNewLocale,
        'Regions and Scripts': keyVariants,
        'Formatting Helpers': keyFormatting,
        'Right-to-Left Layouts': keyDirectionality,
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SelectableText('Localizations').h1(),
          const SelectableText(
            'Translating the text that shadcn_flutter components render on their own.',
          ).lead(),
          const SelectableText(
            'Components ship with built-in text: the "Cancel" on a dialog button, the month names in a '
            'calendar, the validation message a form shows for an empty field. Those strings come from '
            'ShadcnLocalizations rather than from your widget code, so this is where you change them.',
          ).p(),
          const SelectableText(
            'shadcn_flutter ships those strings in 40 locales. They have not been reviewed by native '
            'speakers, so treat them as a starting point: overriding one is a subclass away, and '
            'corrections upstream are welcome.',
          ).p(),
          const SelectableText('Setting Up').h2().anchored(keySetup),
          const SelectableText(
            'ShadcnApp registers ShadcnLocalizations.delegate for you. What it cannot guess is which '
            'locales your app supports. It defaults to English alone, so pass the list:',
          ).p(),
          const CodeBlock(
            code:
                'ShadcnApp(\n'
                '  supportedLocales: ShadcnLocalizations.supportedLocales,\n'
                '  home: const MyHomePage(),\n'
                ');',
            mode: 'dart',
          ).p(),
          const SelectableText(
            'That opts into every locale the package ships. To offer a subset, list them yourself; '
            'Flutter resolves the device locale against this list and falls back to the first entry.',
          ).p(),
          const CodeBlock(
            code:
                'ShadcnApp(\n'
                '  supportedLocales: const [\n'
                "    Locale('en'),\n"
                "    Locale('id'),\n"
                "    Locale('ja'),\n"
                '  ],\n'
                '  home: const MyHomePage(),\n'
                ');',
            mode: 'dart',
          ).p(),
          const Alert(
            leading: Icon(LucideIcons.info),
            title: Text('No flutter_localizations needed'),
            content: Text(
              'shadcn_flutter does not depend on package:flutter_localizations, and you do not need it '
              'for these strings. Add it only if your own code calls GlobalWidgetsLocalizations. Note '
              'that GlobalMaterialLocalizations and GlobalCupertinoLocalizations come from the SDK '
              'material and cupertino libraries, which define different types from the material_ui and '
              'cupertino_ui packages the companion packages use. If you render Material or Cupertino '
              'widgets, take kMaterialLocalizationsDelegates or kCupertinoLocalizationsDelegates from '
              'shadcn_flutter_material or shadcn_flutter_cupertino instead.',
            ),
          ).p(),
          const SelectableText('Reading Strings').h2().anchored(keyReading),
          const SelectableText(
            'Your own widgets can read the same strings the components use. This keeps a screen consistent '
            'with the components on it, and means one translation covers both:',
          ).p(),
          const CodeBlock(
            code:
                'Widget build(BuildContext context) {\n'
                '  final localizations = ShadcnLocalizations.of(context);\n'
                '  return Text(localizations.buttonCancel);\n'
                '}',
            mode: 'dart',
          ).p(),
          const SelectableText('Use ')
              .thenInlineCode('ShadcnLocalizations.maybeOf(context)')
              .thenText(
                ' where the widget might build outside a ShadcnApp. It returns null instead of throwing.',
              )
              .p(),
          const SelectableText('Overriding Strings')
              .h2()
              .anchored(keyOverriding),
          const SelectableText(
            'To reword something without adding a language, subclass the implementation for that locale '
            'and override only what you want. Every locale class is exported, so pick the one you are '
            'adjusting; everything you leave alone keeps its translation:',
          ).p(),
          const CodeBlock(
            code:
                'class MyLocalizations extends ShadcnLocalizationsEn {\n'
                '  @override\n'
                "  String get buttonCancel => 'Never mind';\n"
                '\n'
                '  @override\n'
                "  String get formNotEmpty => 'Please fill this in';\n"
                '}',
            mode: 'dart',
          ).p(),
          const SelectableText(
            'Serve it through a delegate. ShadcnApp puts the delegates you pass ahead of its own, so yours '
            'is the one Flutter resolves:',
          ).p(),
          const CodeBlock(
            code:
                'class MyLocalizationsDelegate\n'
                '    extends LocalizationsDelegate<ShadcnLocalizations> {\n'
                '  const MyLocalizationsDelegate();\n'
                '\n'
                '  @override\n'
                "  bool isSupported(Locale locale) => locale.languageCode == 'en';\n"
                '\n'
                '  @override\n'
                '  Future<ShadcnLocalizations> load(Locale locale) {\n'
                '    return SynchronousFuture(MyLocalizations());\n'
                '  }\n'
                '\n'
                '  @override\n'
                '  bool shouldReload(MyLocalizationsDelegate old) => false;\n'
                '}\n'
                '\n'
                'ShadcnApp(\n'
                '  localizationsDelegates: const [MyLocalizationsDelegate()],\n'
                '  supportedLocales: ShadcnLocalizations.supportedLocales,\n'
                '  home: const MyHomePage(),\n'
                ');',
            mode: 'dart',
          ).p(),
          const SelectableText('Adding a Locale').h2().anchored(keyNewLocale),
          const SelectableText(
            'For a language the package does not ship yet, the best home for the translation is the '
            'package itself, so every app gets it. Translations live as ARB files:',
          ).p(),
          const CodeBlock(
            code:
                '# packages/shadcn_flutter/lib/l10n/shadcn_sv.arb\n'
                '{\n'
                '  "@@locale": "sv",\n'
                '  "formNotEmpty": "Det här fältet får inte vara tomt",\n'
                '  "buttonCancel": "Avbryt"\n'
                '}',
            mode: 'json',
          ).p(),
          const SelectableText('Copy ')
              .thenInlineCode('shadcn_en.arb')
              .thenText(', translate every value, then run ')
              .thenInlineCode('dart run gen:l10n_generator')
              .thenText(
                ' from the repository root. The generator refuses to run if a key is missing, a key is '
                'unknown, or a translation drops a placeholder the English message uses, so a partial '
                'file fails loudly rather than shipping English strings in a translated app. The '
                'contributing guide has the full workflow.',
              )
              .p(),
          const SelectableText(
            'If the language is only for your app, subclass ShadcnLocalizations directly instead. '
            'Extending the base class rather than a locale means the compiler lists everything still '
            'untranslated:',
          ).p(),
          const CodeBlock(
            code:
                'class ShadcnLocalizationsSv extends ShadcnLocalizations {\n'
                "  ShadcnLocalizationsSv([super.locale = 'sv']);\n"
                '\n'
                '  @override\n'
                "  String get formNotEmpty => 'Det här fältet får inte vara tomt';\n"
                '\n'
                '  @override\n'
                "  String get buttonCancel => 'Avbryt';\n"
                '\n'
                '  // ... the analyzer names the rest.\n'
                '}',
            mode: 'dart',
          ).p(),
          const SelectableText(
            'Register it through a delegate whose isSupported answers for your language code, and add '
            'the locale to supportedLocales so Flutter will resolve to it.',
          ).p(),
          const SelectableText('Regions and Scripts')
              .h2()
              .anchored(keyVariants),
          const SelectableText(
            'A locale resolves to the most specific translation available, falling back through script '
            'and region to the bare language. Portuguese ships once, so pt_BR and pt_PT both get it. '
            'Chinese ships twice:',
          ).p(),
          const CodeBlock(
            code:
                "lookupShadcnLocalizations(const Locale('zh'));          // Simplified\n"
                "lookupShadcnLocalizations(const Locale('zh', 'CN'));    // Simplified\n"
                "lookupShadcnLocalizations(const Locale('zh', 'TW'));    // Traditional\n"
                'lookupShadcnLocalizations(\n'
                "  const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),\n"
                ');                                                      // Traditional',
            mode: 'dart',
          ).p(),
          const SelectableText(
            'zh_TW, zh_HK and zh_MO reach Traditional Chinese without carrying a script subtag because '
            'the Traditional translation claims those regions. An explicit script always wins, so '
            'zh_Hans_HK still resolves to Simplified.',
          ).p(),
          const SelectableText('Formatting Helpers')
              .h2()
              .anchored(keyFormatting),
          const SelectableText(
            'ShadcnLocalizations is a flat list of strings. Anything that combines them, like naming a '
            'month from its number or laying out a date, lives on the ShadcnLocalizationsExtensions '
            'extension:',
          ).p(),
          const CodeBlock(
            code:
                'final localizations = ShadcnLocalizations.of(context);\n'
                '\n'
                'localizations.getMonth(3); // March\n'
                'localizations.formatDateTime(DateTime.now());\n'
                'localizations.formatDuration(const Duration(minutes: 90));',
            mode: 'dart',
          ).p(),
          const SelectableText(
            'These read through overridable members, so translating monthMarch changes what getMonth '
            'returns.',
          ).p(),
          const SelectableText('For numbers, ')
              .thenInlineCode('formatDecimal')
              .thenText(
                ' groups digits and drops a trailing .0, which is what the form validation messages use '
                'when they quote a bound:',
              )
              .p(),
          const CodeBlock(
            code:
                'formatDecimal(5);        // 5\n'
                'formatDecimal(1234.5);   // 1,234.5\n'
                "formatDecimal(1234.5, separator: '.'); // 1.234,5 style grouping",
            mode: 'dart',
          ).p(),
          const Alert.destructive(
            leading: Icon(LucideIcons.circleAlert),
            title: Text('Extension members cannot be overridden'),
            content: Text(
              'Dart resolves extension members against the static type, and components hold their '
              'localizations as ShadcnLocalizations. Declaring datePartsOrder or formatDateTime on a '
              'subclass therefore overrides nothing. The defaults (month/day/year ordering, YYYY/MM/DD '
              'abbreviations, "January 1, 2024" date layout) apply in every locale. Widgets that need a '
              'different order take it as a parameter instead.',
            ),
          ).p(),
          const SelectableText('Right-to-Left Layouts')
              .h2()
              .anchored(keyDirectionality),
          const SelectableText(
            'Arabic, Hebrew, Persian, Pashto and Urdu all ship, and all mirror. ShadcnLocalizations '
            'reports the direction for its locale and ShadcnApp applies it, so a right-to-left locale '
            'mirrors the whole app without extra configuration.',
          ).p(),
          const Alert(
            leading: Icon(LucideIcons.info),
            title: Text('Why ShadcnApp sets the direction itself'),
            content: Text(
              'WidgetsApp normally takes the ambient direction from WidgetsLocalizations. Without '
              'package:flutter_localizations that is DefaultWidgetsLocalizations, which reports '
              'left-to-right for every locale, so an Arabic app would not mirror. ShadcnApp reads '
              'ShadcnLocalizations.textDirection instead, outside its overlay layers so dialogs and '
              'toasts inherit it too.',
            ),
          ).p(),
          const SelectableText(
            'To force a direction, for a preview or for one subtree, wrap it:',
          ).p(),
          const CodeBlock(
            code:
                'Directionality(\n'
                '  textDirection: TextDirection.rtl,\n'
                '  child: MyForm(),\n'
                ');',
            mode: 'dart',
          ).p(),
          const SelectableText(
            'Table and ResizableTable also take a textDirection directly, which overrides the ambient one '
            'for that table. Column indices stay logical either way: column 0 is the first column, and '
            'under RTL it is laid out at the right edge, with frozen columns pinned there and horizontal '
            'scrolling running leftwards.',
          ).p(),
          const CodeBlock(
            code:
                'Table(\n'
                '  textDirection: TextDirection.rtl,\n'
                '  columnWidths: const {0: FixedTableSize(120)},\n'
                '  rows: const [\n'
                '    TableRow(\n'
                '      cells: [\n'
                "        TableCell(child: Text('الاسم')),\n"
                "        TableCell(child: Text('البريد')),\n"
                '      ],\n'
                '    ),\n'
                '  ],\n'
                ');',
            mode: 'dart',
          ).p(),
        ],
      ),
    );
  }
}
