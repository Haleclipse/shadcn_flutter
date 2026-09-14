/// Generates shadcn_flutter's localizations from `lib/l10n/*.arb`.
///
/// ```shell
/// dart run gen:l10n_generator
/// ```
///
/// ## Why this exists instead of `flutter gen-l10n`
///
/// The SDK generator's template hardcodes two dependencies shadcn_flutter
/// deliberately does not have:
///
///  * `package:flutter_localizations`, so the generated
///    `localizationsDelegates` list can offer `GlobalMaterialLocalizations`,
///    `GlobalCupertinoLocalizations` and `GlobalWidgetsLocalizations`. The first
///    two come from `package:flutter/material.dart` and
///    `package:flutter/cupertino.dart` — the SDK libraries shadcn_flutter was
///    decoupled from, and which are incompatible with the `material_ui` and
///    `cupertino_ui` types the companion packages use.
///  * `package:intl`, for `Intl.canonicalizedLocale` and number formatting.
///    `canonicalizeLocale` and `formatDecimal` in `locale_utils.dart` cover
///    both.
///
/// It also requires `flutter: generate: true` in the pubspec, which would let an
/// ordinary build re-run it over whatever we produced.
///
/// Every published alternative leaves a runtime dependency behind too —
/// `intl_utils` output needs `intl`, `slang` needs `slang` + `slang_flutter` +
/// `intl` — so the only route to a package with no localization dependencies is
/// to emit the Dart ourselves.
///
/// ## What it supports
///
/// The `.arb` subset shadcn_flutter actually uses: plain messages and simple
/// `{placeholder}` substitution, with `String`, `int`, `double` and `num`
/// placeholder types. Plurals, selects and `format:` are **not** supported and
/// are rejected loudly rather than mistranslated — if a message ever needs one,
/// teach this generator rather than reaching back for `gen-l10n`.
///
/// ## Adding a locale
///
/// Drop `lib/l10n/shadcn_<locale>.arb` next to the others, translating every key
/// in the template, and rerun. A missing or unknown key is an error: the
/// generated classes have no fallbacks, so a gap would show up as an untranslated
/// English string in a translated app.
///
/// The locale part of the filename is a BCP 47 tag with `_` separators:
///
///  * `shadcn_pt.arb` — the language
///  * `shadcn_pt_PT.arb` — a country variant, two letters or three digits
///  * `shadcn_zh_Hant.arb` — a script variant, four letters
///  * `shadcn_zh_Hant_HK.arb` — both
///
/// A variant only has to exist for the locales it differs in; resolution falls
/// back through script+country, script, country, then the bare language. A
/// script variant can also claim the countries that write in it, so that a
/// `Locale('zh', 'TW')` with no script subtag still finds Traditional Chinese:
///
/// ```json
/// { "@@locale": "zh_Hant", "@@countries": ["TW", "HK", "MO"], ... }
/// ```
library;

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

const _package = 'shadcn_flutter';
const _arbDir = 'lib/l10n';
const _outputDir = 'lib/src/components/locale';
const _prefix = 'shadcn_';
const _className = 'ShadcnLocalizations';
const _fileStem = 'shadcn_localizations';

/// The template locale: the one every other `.arb` is checked against.
const _templateLocale = 'en';

/// Locales written right-to-left, so [_className] can report `textDirection`
/// without `GlobalWidgetsLocalizations`.
const Set<String> _rtlLanguages = {
  'ar',
  'fa',
  'he',
  'iw',
  'ps',
  'sd',
  'ur',
  'yi',
};

/// Human-readable names for the locales we ship, used in doc comments.
const Map<String, String> _languageNames = {
  'ar': 'Arabic',
  'bg': 'Bulgarian',
  'bn': 'Bengali',
  'ca': 'Catalan',
  'cs': 'Czech',
  'da': 'Danish',
  'de': 'German',
  'el': 'Greek',
  'en': 'English',
  'es': 'Spanish',
  'et': 'Estonian',
  'fa': 'Persian',
  'fi': 'Finnish',
  'fil': 'Filipino',
  'fr': 'French',
  'he': 'Hebrew',
  'hi': 'Hindi',
  'hr': 'Croatian',
  'hu': 'Hungarian',
  'id': 'Indonesian',
  'it': 'Italian',
  'ja': 'Japanese',
  'ko': 'Korean',
  'lt': 'Lithuanian',
  'lv': 'Latvian',
  'mr': 'Marathi',
  'ms': 'Malay',
  'nb': 'Norwegian Bokmal',
  'nl': 'Dutch',
  'pl': 'Polish',
  'ps': 'Pashto',
  'pt': 'Portuguese',
  'ro': 'Romanian',
  'ru': 'Russian',
  'sk': 'Slovak',
  'sl': 'Slovenian',
  'sr': 'Serbian',
  'sv': 'Swedish',
  'sw': 'Swahili',
  'ta': 'Tamil',
  'te': 'Telugu',
  'th': 'Thai',
  'tr': 'Turkish',
  'uk': 'Ukrainian',
  'ur': 'Urdu',
  'vi': 'Vietnamese',
  'zh': 'Chinese',
};

const _header = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
//
// Generated from lib/l10n/*.arb by `dart run gen:l10n_generator`.
// Edit the .arb files and rerun the generator instead.

// ignore_for_file: type=lint
''';

/// A parsed `.arb` filename suffix, such as `pt`, `pt_PT` or `zh_Hant_HK`.
class _LocaleTag implements Comparable<_LocaleTag> {
  _LocaleTag(this.language, this.script, this.country);

  /// Parses the locale part of an `.arb` filename.
  ///
  /// Throws [_ArbError] when a subtag is not a well-formed language, script or
  /// region — a typo there would otherwise generate a locale nothing matches.
  factory _LocaleTag.parse(String tag) {
    final parts = tag.split('_');
    if (parts.isEmpty || !RegExp(r'^[a-z]{2,3}$').hasMatch(parts.first)) {
      throw _ArbError('"$tag" does not start with a language code');
    }
    String? script;
    String? country;
    for (final part in parts.skip(1)) {
      if (RegExp(r'^[A-Z][a-z]{3}$').hasMatch(part) && script == null) {
        script = part;
      } else if (RegExp(r'^([A-Z]{2}|[0-9]{3})$').hasMatch(part) &&
          country == null) {
        country = part;
      } else {
        throw _ArbError(
          '"$tag" has an unexpected subtag "$part"; expected a script '
          '(Hant), a region (PT) or a numeric region (419)',
        );
      }
    }
    return _LocaleTag(parts.first, script, country);
  }

  final String language;
  final String? script;
  final String? country;

  /// Countries this variant also covers, from the `.arb`'s `@@countries`.
  final List<String> alsoCovers = <String>[];

  bool get isBase => script == null && country == null;

  /// The filename suffix and map key, such as `zh_Hant`.
  String get tag => [language, ?script, ?country].join('_');

  /// The Dart class suffix, such as `ZhHant`.
  String get className =>
      [language, ?script, ?country].map(_pascalPart).join();

  /// A `Locale` expression for `supportedLocales`.
  String get localeExpression {
    if (isBase) return "Locale('$language')";
    if (script == null) return "Locale('$language', '$country')";
    final region = country == null ? '' : ", countryCode: '$country'";
    return 'Locale.fromSubtags('
        "languageCode: '$language', "
        "scriptCode: '$script'"
        '$region)';
  }

  /// Most specific first, so resolution can take the first match.
  @override
  int compareTo(_LocaleTag other) {
    final byLanguage = language.compareTo(other.language);
    if (byLanguage != 0) return byLanguage;
    final specificity = other._specificity.compareTo(_specificity);
    if (specificity != 0) return specificity;
    return tag.compareTo(other.tag);
  }

  int get _specificity =>
      (script == null ? 0 : 2) + (country == null ? 0 : 1);

  @override
  String toString() => tag;
}

String _pascalPart(String part) =>
    part.isEmpty ? part : part[0].toUpperCase() + part.substring(1).toLowerCase();

/// One translatable message.
class _Message {
  _Message(this.name, this.text, this.placeholders);

  final String name;
  final String text;

  /// Placeholder name to Dart type, in the order they appear in the message.
  final Map<String, String> placeholders;

  bool get hasPlaceholders => placeholders.isNotEmpty;

  /// `String get foo` or `String foo(String value)`.
  String get signature {
    if (!hasPlaceholders) return 'String get $name';
    final params = placeholders.entries
        .map((e) => '${e.value} ${e.key}')
        .join(', ');
    return 'String $name($params)';
  }
}

Future<int> main(List<String> args) async {
  final root = _findRepoRoot();
  final package = p.join(root, 'packages', _package);
  final arbDir = Directory(p.join(package, _arbDir));
  if (!arbDir.existsSync()) {
    stderr.writeln('No ${p.join(package, _arbDir)}');
    return 1;
  }

  final locales = <String, File>{};
  final tags = <String, _LocaleTag>{};
  for (final entity in arbDir.listSync()) {
    if (entity is! File || p.extension(entity.path) != '.arb') continue;
    final stem = p.basenameWithoutExtension(entity.path);
    if (!stem.startsWith(_prefix)) {
      stderr.writeln(
        'Unexpected .arb name ${p.basename(entity.path)}; '
        'expected $_prefix<locale>.arb',
      );
      return 1;
    }
    final tag = stem.substring(_prefix.length);
    try {
      tags[tag] = _LocaleTag.parse(tag);
    } on _ArbError catch (e) {
      stderr.writeln('${p.basename(entity.path)}: ${e.message}');
      return 1;
    }
    locales[tag] = entity;
  }
  if (!locales.containsKey(_templateLocale)) {
    stderr.writeln('Missing the template $_prefix$_templateLocale.arb');
    return 1;
  }

  final List<_Message> template;
  try {
    template = _parse(locales[_templateLocale]!, isTemplate: true);
  } on _ArbError catch (e) {
    stderr.writeln(e.message);
    return 1;
  }

  // Every other locale must define exactly the template's keys, with the same
  // placeholders — a gap would surface as a missing override at compile time,
  // and an extra key is almost always a typo.
  final translations = <String, List<_Message>>{};
  for (final entry in locales.entries) {
    if (entry.key == _templateLocale) {
      translations[entry.key] = template;
      continue;
    }
    final List<_Message> messages;
    try {
      messages = _parse(entry.value, isTemplate: false);
    } on _ArbError catch (e) {
      stderr.writeln(e.message);
      return 1;
    }
    final problems = _diff(template, messages, entry.key);
    if (problems.isNotEmpty) {
      problems.forEach(stderr.writeln);
      return 1;
    }
    translations[entry.key] = messages;
    try {
      tags[entry.key]!.alsoCovers.addAll(_declaredCountries(entry.value));
    } on _ArbError catch (e) {
      stderr.writeln(e.message);
      return 1;
    }
  }

  // Resolution falls back to the bare language, so every variant needs one.
  for (final tag in tags.values) {
    if (tag.isBase) continue;
    if (!tags.containsKey(tag.language)) {
      stderr.writeln(
        '$_prefix${tag.tag}.arb has no base $_prefix${tag.language}.arb to '
        'fall back to',
      );
      return 1;
    }
  }

  final sorted = tags.values.toList()..sort();
  final outDir = Directory(p.join(package, _outputDir));
  outDir.createSync(recursive: true);

  _write(
    File(p.join(outDir.path, '$_fileStem.dart')),
    _renderBase(template, sorted),
  );
  for (final tag in sorted) {
    final locale = tag.tag;
    // Emit in the template's order, and with the template's placeholder types
    // and parameter order — a translation `.arb` carries only the text, so
    // inferring from it would type `formLengthLessThan`'s `int` as a `String`
    // and the override would not match the base class.
    final byName = {for (final m in translations[locale]!) m.name: m};
    final messages = [
      for (final m in template)
        _Message(m.name, byName[m.name]!.text, m.placeholders),
    ];
    _write(
      File(p.join(outDir.path, '${_fileStem}_$locale.dart')),
      _renderLocale(tag, messages),
    );
  }

  stdout.writeln(
    'Generated ${sorted.length} locale(s) '
    '(${sorted.map((t) => t.tag).join(', ')}) x ${template.length} messages',
  );
  return 0;
}

// ---------------------------------------------------------------------------
// Parsing
// ---------------------------------------------------------------------------

class _ArbError implements Exception {
  _ArbError(this.message);
  final String message;
}

const Map<String, String> _placeholderTypes = {
  'String': 'String',
  'int': 'int',
  'double': 'double',
  'num': 'num',
};

List<_Message> _parse(File file, {required bool isTemplate}) {
  final name = p.basename(file.path);
  final Object? decoded;
  try {
    decoded = jsonDecode(file.readAsStringSync());
  } on FormatException catch (e) {
    throw _ArbError('$name is not valid JSON: ${e.message}');
  }
  if (decoded is! Map<String, dynamic>) {
    throw _ArbError('$name must be a JSON object');
  }

  final messages = <_Message>[];
  for (final entry in decoded.entries) {
    if (entry.key.startsWith('@')) continue;
    final text = entry.value;
    if (text is! String) {
      throw _ArbError('$name: "${entry.key}" must be a string');
    }
    for (final unsupported in const ['plural,', 'select,']) {
      if (text.contains(unsupported)) {
        throw _ArbError(
          '$name: "${entry.key}" uses ICU "$unsupported", which this generator '
          'does not support. Teach it, or split the message.',
        );
      }
    }

    final meta = decoded['@${entry.key}'];
    final declared = <String, String>{};
    if (meta is Map<String, dynamic>) {
      final placeholders = meta['placeholders'];
      if (placeholders is Map<String, dynamic>) {
        for (final ph in placeholders.entries) {
          final spec = ph.value;
          if (spec is Map<String, dynamic> && spec.containsKey('format')) {
            throw _ArbError(
              '$name: "${entry.key}" placeholder "${ph.key}" uses "format", '
              'which needs package:intl. Format at the call site instead — see '
              'formatDecimal in locale_utils.dart.',
            );
          }
          final type = spec is Map<String, dynamic>
              ? (spec['type'] as String? ?? 'String')
              : 'String';
          final dartType = _placeholderTypes[type];
          if (dartType == null) {
            throw _ArbError(
              '$name: "${entry.key}" placeholder "${ph.key}" has unsupported '
              'type "$type"; use ${_placeholderTypes.keys.join(', ')}.',
            );
          }
          declared[ph.key] = dartType;
        }
      }
    }

    // Order the parameters the way they appear in the message, so the
    // signature reads the way the sentence does.
    final used = _placeholdersIn(text);
    for (final u in used) {
      if (!declared.containsKey(u)) {
        if (isTemplate) {
          throw _ArbError(
            '$name: "${entry.key}" uses {$u} but does not declare it under '
            '"@${entry.key}".placeholders',
          );
        }
        declared[u] = 'String';
      }
    }
    final ordered = <String, String>{
      for (final u in used) u: declared[u]!,
      // Declared but unused: keep them so the signature stays stable.
      for (final d in declared.keys)
        if (!used.contains(d)) d: declared[d]!,
    };
    messages.add(_Message(entry.key, text, ordered));
  }
  if (messages.isEmpty) throw _ArbError('$name defines no messages');
  return messages;
}

/// The `@@countries` a script variant claims, so a locale with no script
/// subtag still resolves to it.
List<String> _declaredCountries(File file) {
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, dynamic>) return const [];
  final declared = decoded['@@countries'];
  if (declared == null) return const [];
  if (declared is! List) {
    throw _ArbError('${p.basename(file.path)}: "@@countries" must be a list');
  }
  return [
    for (final country in declared)
      if (country is String &&
          RegExp(r'^([A-Z]{2}|[0-9]{3})$').hasMatch(country))
        country
      else
        throw _ArbError(
          '${p.basename(file.path)}: "@@countries" entry "$country" is not a '
          'region code',
        ),
  ];
}

final RegExp _placeholderPattern = RegExp(r'\{(\w+)\}');

List<String> _placeholdersIn(String text) {
  final seen = <String>[];
  for (final match in _placeholderPattern.allMatches(text)) {
    final name = match.group(1)!;
    if (!seen.contains(name)) seen.add(name);
  }
  return seen;
}

List<String> _diff(
  List<_Message> template,
  List<_Message> translation,
  String locale,
) {
  final problems = <String>[];
  final byName = {for (final m in translation) m.name: m};
  for (final expected in template) {
    final actual = byName.remove(expected.name);
    if (actual == null) {
      problems.add('$_prefix$locale.arb is missing "${expected.name}"');
      continue;
    }
    final expectedPh = expected.placeholders.keys.toSet();
    final actualPh = _placeholdersIn(actual.text).toSet();
    final missing = expectedPh.difference(actualPh);
    final extra = actualPh.difference(expectedPh);
    if (missing.isNotEmpty) {
      problems.add(
        '$_prefix$locale.arb: "${expected.name}" drops '
        '${missing.map((e) => '{$e}').join(', ')}',
      );
    }
    if (extra.isNotEmpty) {
      problems.add(
        '$_prefix$locale.arb: "${expected.name}" adds unknown '
        '${extra.map((e) => '{$e}').join(', ')}',
      );
    }
  }
  for (final leftover in byName.keys) {
    problems.add(
      '$_prefix$locale.arb: "$leftover" is not in the '
      '$_prefix$_templateLocale.arb template',
    );
  }
  return problems;
}

// ---------------------------------------------------------------------------
// Rendering
// ---------------------------------------------------------------------------

String _renderBase(List<_Message> template, List<_LocaleTag> locales) {
  final languages = <String>[
    for (final tag in locales)
      if (tag.isBase) tag.language,
  ];
  final buffer = StringBuffer(_header)
    ..writeln()
    ..writeln("import 'dart:async';")
    ..writeln()
    ..writeln("import 'package:flutter/foundation.dart';")
    ..writeln("import 'package:flutter/widgets.dart';")
    ..writeln()
    ..writeln("import 'locale_utils.dart';");
  for (final tag in locales) {
    buffer.writeln("import '${_fileStem}_${tag.tag}.dart';");
  }
  // Re-exported so an app can subclass a locale's strings to reword one of
  // them, which is the documented way to override a translation.
  buffer.writeln();
  for (final tag in locales) {
    buffer.writeln("export '${_fileStem}_${tag.tag}.dart';");
  }

  buffer
    ..writeln()
    ..writeln('''
/// The strings shadcn_flutter's own components display.
///
/// Look one up with `$_className.of(context)`. `ShadcnApp` installs [delegate]
/// itself, so an app only has to list the locales it supports:
///
/// ```dart
/// ShadcnApp(
///   supportedLocales: $_className.supportedLocales,
///   home: const HomePage(),
/// );
/// ```
///
/// To word a string differently, or to support a locale this package does not
/// ship, subclass a locale's implementation and register your own delegate
/// ahead of [delegate]:
///
/// ```dart
/// class MyStrings extends ShadcnLocalizationsEn {
///   @override
///   String get buttonSave => 'Keep';
/// }
/// ```
///
/// Anything that *combines* these strings — naming a month, laying out a date —
/// lives in `ShadcnLocalizationsExtensions` instead, so this class stays a plain
/// string table.''')
    ..writeln('abstract class $_className {')
    ..writeln('  /// Creates the localizations for [locale].')
    ..writeln('  $_className(String locale)')
    ..writeln('    : localeName = canonicalizeLocale(locale);')
    ..writeln()
    ..writeln('  /// The canonicalized name of the locale these strings are')
    ..writeln('  /// for, such as `en` or `pt_BR`.')
    ..writeln('  final String localeName;')
    ..writeln()
    ..writeln('  /// The direction text runs in for this locale.')
    ..writeln('  ///')
    ..writeln('  /// shadcn_flutter does not depend on')
    ..writeln('  /// `package:flutter_localizations`, so `Directionality` is')
    ..writeln('  /// not set from `GlobalWidgetsLocalizations`. `ShadcnApp`')
    ..writeln('  /// reads this instead.')
    ..writeln('  TextDirection get textDirection => TextDirection.ltr;')
    ..writeln()
    ..writeln('  /// The localizations in scope at [context].')
    ..writeln('  static $_className of(BuildContext context) {')
    ..writeln('    return Localizations.of<$_className>(')
    ..writeln('      context,')
    ..writeln('      $_className,')
    ..writeln('    )!;')
    ..writeln('  }')
    ..writeln()
    ..writeln('  /// The localizations in scope at [context], or null when')
    ..writeln('  /// none are installed.')
    ..writeln('  static $_className? maybeOf(BuildContext context) {')
    ..writeln('    return Localizations.of<$_className>(context, $_className);')
    ..writeln('  }')
    ..writeln()
    ..writeln('  /// Loads these localizations for a locale.')
    ..writeln('  static const LocalizationsDelegate<$_className> delegate =')
    ..writeln('      _${_className}Delegate();')
    ..writeln()
    ..writeln('  /// Just [delegate].')
    ..writeln('  ///')
    ..writeln('  /// shadcn_flutter does not depend on')
    ..writeln('  /// `package:flutter_localizations`, so the')
    ..writeln('  /// `Global*Localizations` delegates are not included here.')
    ..writeln('  /// Add them yourself if your app needs them, or use')
    ..writeln('  /// `kMaterialLocalizationsDelegates` /')
    ..writeln('  /// `kCupertinoLocalizationsDelegates` from the companion')
    ..writeln('  /// packages.')
    ..writeln('  static const List<LocalizationsDelegate<dynamic>>')
    ..writeln('  localizationsDelegates = <LocalizationsDelegate<dynamic>>[')
    ..writeln('    delegate,')
    ..writeln('  ];')
    ..writeln()
    ..writeln('  /// Every locale this package ships strings for.')
    ..writeln('  static const List<Locale> supportedLocales = <Locale>[');
  for (final tag in locales) {
    buffer.writeln('    ${tag.localeExpression},');
  }
  buffer.writeln('  ];');

  for (final message in template) {
    buffer
      ..writeln()
      ..writeln('  /// In $_templateLocale, this message reads:')
      ..writeln('  ///')
      ..writeln('  /// **${_docLiteral(message.text)}**')
      ..writeln('  ${message.signature};');
  }
  buffer.writeln('}');

  buffer
    ..writeln()
    ..writeln('class _${_className}Delegate')
    ..writeln('    extends LocalizationsDelegate<$_className> {')
    ..writeln('  const _${_className}Delegate();')
    ..writeln()
    ..writeln('  @override')
    ..writeln('  Future<$_className> load(Locale locale) {')
    ..writeln('    return SynchronousFuture<$_className>(')
    ..writeln('      lookup$_className(locale),')
    ..writeln('    );')
    ..writeln('  }')
    ..writeln()
    ..writeln('  @override')
    ..writeln('  bool isSupported(Locale locale) =>')
    ..writeln('      kSupportedLanguages.contains(locale.languageCode);')
    ..writeln()
    ..writeln('  @override')
    ..writeln('  bool shouldReload(_${_className}Delegate old) => false;')
    ..writeln('}')
    ..writeln()
    ..writeln('/// The language codes [$_className.delegate] accepts.')
    ..writeln('const Set<String> kSupportedLanguages = <String>{')
    ..writeln(
      '  ${languages.map((l) => "'$l'").join(', ')},',
    )
    ..writeln('};')
    ..writeln()
    ..writeln('/// The implementation for [locale].')
    ..writeln('///')
    ..writeln('/// Matches the most specific variant available, falling')
    ..writeln('/// back through script and region to the bare language:')
    ..writeln('/// `pt_BR` and `pt_PT` both resolve to Portuguese unless a')
    ..writeln('/// variant for one of them is shipped.')
    ..writeln('$_className lookup$_className(Locale locale) {')
    ..writeln('  switch (locale.languageCode) {');
  for (final language in languages) {
    buffer.writeln("    case '$language':");
    // `locales` is sorted most specific first, so the first match wins.
    for (final variant in locales) {
      if (variant.language != language || variant.isBase) continue;
      final conditions = <String>[
        if (variant.script != null)
          "locale.scriptCode == '${variant.script}'",
        if (variant.country != null)
          "locale.countryCode == '${variant.country}'",
      ];
      buffer
        ..writeln('      if (${conditions.join(' && ')}) {')
        ..writeln('        return $_className${variant.className}();')
        ..writeln('      }');
      if (variant.alsoCovers.isNotEmpty) {
        final countries = variant.alsoCovers
            .map((c) => "locale.countryCode == '$c'")
            .join('\n              || ');
        buffer
        // Parenthesised: `&&` binds tighter than `||`, so without them a
        // `zh_Hans_HK` would match this Traditional branch.
          ..writeln('      // Regions that write in this script.')
          ..writeln('      if (locale.scriptCode == null &&')
          ..writeln('          ($countries)) {')
          ..writeln('        return $_className${variant.className}();')
          ..writeln('      }');
      }
    }
    buffer.writeln('      return $_className${_pascal(language)}();');
  }
  buffer
    ..writeln('  }')
    ..writeln('  throw FlutterError(')
    ..writeln(
      "    '$_className.delegate failed to load unsupported locale \"\$locale\". '",
    )
    ..writeln("    'Supported languages are \${kSupportedLanguages.join(', ')}.',")
    ..writeln('  );')
    ..writeln('}');
  return buffer.toString();
}

String _renderLocale(_LocaleTag tag, List<_Message> messages) {
  final name = _describe(tag);
  final className = '$_className${tag.className}';
  final rtl = _rtlLanguages.contains(tag.language);
  final buffer = StringBuffer(_header)..writeln();
  if (rtl) {
    buffer
      ..writeln("import 'package:flutter/widgets.dart';")
      ..writeln();
  }
  buffer
    ..writeln("import '$_fileStem.dart';")
    ..writeln()
    ..writeln('/// The translations for $name (`${tag.tag}`).')
    ..writeln('class $className extends $_className {')
    ..writeln('  /// Creates the $name localizations.')
    ..writeln("  $className([super.locale = '${tag.tag}']);");

  if (rtl) {
    buffer
      ..writeln()
      ..writeln('  @override')
      ..writeln('  TextDirection get textDirection => TextDirection.rtl;');
  }

  for (final message in messages) {
    buffer
      ..writeln()
      ..writeln('  @override');
    if (message.hasPlaceholders) {
      buffer
        ..writeln('  ${message.signature} {')
        ..writeln('    return ${_interpolated(message)};')
        ..writeln('  }');
    } else {
      buffer.writeln('  ${message.signature} => ${_literal(message.text)};');
    }
  }
  buffer.writeln('}');
  return buffer.toString();
}

/// Renders a message as a Dart string literal, interpolating its placeholders.
String _interpolated(_Message message) {
  final buffer = StringBuffer("'");
  var index = 0;
  for (final match in _placeholderPattern.allMatches(message.text)) {
    buffer.write(_escape(message.text.substring(index, match.start)));
    // Braces, so a placeholder followed by a letter still resolves.
    buffer.write('\${${match.group(1)}}');
    index = match.end;
  }
  buffer
    ..write(_escape(message.text.substring(index)))
    ..write("'");
  return buffer.toString();
}

/// A human-readable name for a locale, such as `Chinese (Hant)`.
String _describe(_LocaleTag tag) {
  final language = _languageNames[tag.language] ?? tag.language;
  final qualifiers = [?tag.script, ?tag.country];
  return qualifiers.isEmpty
      ? language
      : '$language (${qualifiers.join(', ')})';
}

String _literal(String text) => "'${_escape(text)}'";

String _escape(String text) => text
    .replaceAll(r'\', r'\\')
    .replaceAll(r'$', r'\$')
    .replaceAll("'", r"\'")
    .replaceAll('\n', r'\n')
    .replaceAll('\r', r'\r');

/// A message rendered into a doc comment, where `{a}` reads better than `$a`.
String _docLiteral(String text) => text.replaceAll('\n', ' ');

String _pascal(String locale) => locale.split(RegExp('[_-]')).map((part) {
  if (part.isEmpty) return part;
  return part[0].toUpperCase() + part.substring(1).toLowerCase();
}).join();

void _write(File file, String contents) {
  final existing = file.existsSync() ? file.readAsStringSync() : '';
  final eol = existing.contains('\r\n') ? '\r\n' : '\n';
  file.writeAsStringSync(
    eol == '\r\n' ? contents.replaceAll('\n', eol) : contents,
  );
}

String _findRepoRoot() {
  var dir = Directory.current;
  while (true) {
    if (File(p.join(dir.path, 'pubspec.yaml')).existsSync() &&
        Directory(p.join(dir.path, 'packages')).existsSync()) {
      return dir.path;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError('Could not find the repository root from $dir');
    }
    dir = parent;
  }
}
