// GENERATED CODE - DO NOT MODIFY BY HAND
//
// Generated from lib/l10n/*.arb by `dart run gen:l10n_generator`.
// Edit the .arb files and rerun the generator instead.

// ignore_for_file: type=lint

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'locale_utils.dart';
import 'shadcn_localizations_ar.dart';
import 'shadcn_localizations_bg.dart';
import 'shadcn_localizations_bn.dart';
import 'shadcn_localizations_cs.dart';
import 'shadcn_localizations_da.dart';
import 'shadcn_localizations_de.dart';
import 'shadcn_localizations_el.dart';
import 'shadcn_localizations_en.dart';
import 'shadcn_localizations_es.dart';
import 'shadcn_localizations_fa.dart';
import 'shadcn_localizations_fi.dart';
import 'shadcn_localizations_fil.dart';
import 'shadcn_localizations_fr.dart';
import 'shadcn_localizations_he.dart';
import 'shadcn_localizations_hi.dart';
import 'shadcn_localizations_hu.dart';
import 'shadcn_localizations_id.dart';
import 'shadcn_localizations_it.dart';
import 'shadcn_localizations_ja.dart';
import 'shadcn_localizations_ko.dart';
import 'shadcn_localizations_mr.dart';
import 'shadcn_localizations_ms.dart';
import 'shadcn_localizations_nb.dart';
import 'shadcn_localizations_nl.dart';
import 'shadcn_localizations_pl.dart';
import 'shadcn_localizations_ps.dart';
import 'shadcn_localizations_pt.dart';
import 'shadcn_localizations_ro.dart';
import 'shadcn_localizations_ru.dart';
import 'shadcn_localizations_sk.dart';
import 'shadcn_localizations_sv.dart';
import 'shadcn_localizations_ta.dart';
import 'shadcn_localizations_te.dart';
import 'shadcn_localizations_th.dart';
import 'shadcn_localizations_tr.dart';
import 'shadcn_localizations_uk.dart';
import 'shadcn_localizations_ur.dart';
import 'shadcn_localizations_vi.dart';
import 'shadcn_localizations_zh_Hant.dart';
import 'shadcn_localizations_zh.dart';

export 'shadcn_localizations_ar.dart';
export 'shadcn_localizations_bg.dart';
export 'shadcn_localizations_bn.dart';
export 'shadcn_localizations_cs.dart';
export 'shadcn_localizations_da.dart';
export 'shadcn_localizations_de.dart';
export 'shadcn_localizations_el.dart';
export 'shadcn_localizations_en.dart';
export 'shadcn_localizations_es.dart';
export 'shadcn_localizations_fa.dart';
export 'shadcn_localizations_fi.dart';
export 'shadcn_localizations_fil.dart';
export 'shadcn_localizations_fr.dart';
export 'shadcn_localizations_he.dart';
export 'shadcn_localizations_hi.dart';
export 'shadcn_localizations_hu.dart';
export 'shadcn_localizations_id.dart';
export 'shadcn_localizations_it.dart';
export 'shadcn_localizations_ja.dart';
export 'shadcn_localizations_ko.dart';
export 'shadcn_localizations_mr.dart';
export 'shadcn_localizations_ms.dart';
export 'shadcn_localizations_nb.dart';
export 'shadcn_localizations_nl.dart';
export 'shadcn_localizations_pl.dart';
export 'shadcn_localizations_ps.dart';
export 'shadcn_localizations_pt.dart';
export 'shadcn_localizations_ro.dart';
export 'shadcn_localizations_ru.dart';
export 'shadcn_localizations_sk.dart';
export 'shadcn_localizations_sv.dart';
export 'shadcn_localizations_ta.dart';
export 'shadcn_localizations_te.dart';
export 'shadcn_localizations_th.dart';
export 'shadcn_localizations_tr.dart';
export 'shadcn_localizations_uk.dart';
export 'shadcn_localizations_ur.dart';
export 'shadcn_localizations_vi.dart';
export 'shadcn_localizations_zh_Hant.dart';
export 'shadcn_localizations_zh.dart';

/// The strings shadcn_flutter's own components display.
///
/// Look one up with `ShadcnLocalizations.of(context)`. `ShadcnApp` installs [delegate]
/// itself, so an app only has to list the locales it supports:
///
/// ```dart
/// ShadcnApp(
///   supportedLocales: ShadcnLocalizations.supportedLocales,
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
/// string table.
abstract class ShadcnLocalizations {
  /// Creates the localizations for [locale].
  ShadcnLocalizations(String locale)
    : localeName = canonicalizeLocale(locale);

  /// The canonicalized name of the locale these strings are
  /// for, such as `en` or `pt_BR`.
  final String localeName;

  /// The direction text runs in for this locale.
  ///
  /// shadcn_flutter does not depend on
  /// `package:flutter_localizations`, so `Directionality` is
  /// not set from `GlobalWidgetsLocalizations`. `ShadcnApp`
  /// reads this instead.
  TextDirection get textDirection => TextDirection.ltr;

  /// The localizations in scope at [context].
  static ShadcnLocalizations of(BuildContext context) {
    return Localizations.of<ShadcnLocalizations>(
      context,
      ShadcnLocalizations,
    )!;
  }

  /// The localizations in scope at [context], or null when
  /// none are installed.
  static ShadcnLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<ShadcnLocalizations>(context, ShadcnLocalizations);
  }

  /// Loads these localizations for a locale.
  static const LocalizationsDelegate<ShadcnLocalizations> delegate =
      _ShadcnLocalizationsDelegate();

  /// Just [delegate].
  ///
  /// shadcn_flutter does not depend on
  /// `package:flutter_localizations`, so the
  /// `Global*Localizations` delegates are not included here.
  /// Add them yourself if your app needs them, or use
  /// `kMaterialLocalizationsDelegates` /
  /// `kCupertinoLocalizationsDelegates` from the companion
  /// packages.
  static const List<LocalizationsDelegate<dynamic>>
  localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
  ];

  /// Every locale this package ships strings for.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bg'),
    Locale('bn'),
    Locale('cs'),
    Locale('da'),
    Locale('de'),
    Locale('el'),
    Locale('en'),
    Locale('es'),
    Locale('fa'),
    Locale('fi'),
    Locale('fil'),
    Locale('fr'),
    Locale('he'),
    Locale('hi'),
    Locale('hu'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('mr'),
    Locale('ms'),
    Locale('nb'),
    Locale('nl'),
    Locale('pl'),
    Locale('ps'),
    Locale('pt'),
    Locale('ro'),
    Locale('ru'),
    Locale('sk'),
    Locale('sv'),
    Locale('ta'),
    Locale('te'),
    Locale('th'),
    Locale('tr'),
    Locale('uk'),
    Locale('ur'),
    Locale('vi'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    Locale('zh'),
  ];

  /// In en, this message reads:
  ///
  /// **This field cannot be empty**
  String get formNotEmpty;

  /// In en, this message reads:
  ///
  /// **Invalid value**
  String get invalidValue;

  /// In en, this message reads:
  ///
  /// **Invalid email**
  String get invalidEmail;

  /// In en, this message reads:
  ///
  /// **Invalid URL**
  String get invalidURL;

  /// In en, this message reads:
  ///
  /// **Must be less than {value}**
  String formLessThan(String value);

  /// In en, this message reads:
  ///
  /// **Must be greater than {value}**
  String formGreaterThan(String value);

  /// In en, this message reads:
  ///
  /// **Must be less than or equal to {value}**
  String formLessThanOrEqualTo(String value);

  /// In en, this message reads:
  ///
  /// **Phone number is invalid**
  String get formPhoneNumberInvalid;

  /// In en, this message reads:
  ///
  /// **Phone number is required**
  String get formPhoneNumberEmpty;

  /// In en, this message reads:
  ///
  /// **Must be greater than or equal to {value}**
  String formGreaterThanOrEqualTo(String value);

  /// In en, this message reads:
  ///
  /// **Must be between {min} and {max} (inclusive)**
  String formBetweenInclusively(String min, String max);

  /// In en, this message reads:
  ///
  /// **Must be equal to {value}**
  String formEqualTo(String value);

  /// In en, this message reads:
  ///
  /// **Must be between {min} and {max} (exclusive)**
  String formBetweenExclusively(String min, String max);

  /// In en, this message reads:
  ///
  /// **Must be at least {value} characters**
  String formLengthLessThan(int value);

  /// In en, this message reads:
  ///
  /// **Must be at most {value} characters**
  String formLengthGreaterThan(int value);

  /// In en, this message reads:
  ///
  /// **Must contain at least one digit**
  String get formPasswordDigits;

  /// In en, this message reads:
  ///
  /// **Must contain at least one lowercase letter**
  String get formPasswordLowercase;

  /// In en, this message reads:
  ///
  /// **Must contain at least one uppercase letter**
  String get formPasswordUppercase;

  /// In en, this message reads:
  ///
  /// **Must contain at least one special character**
  String get formPasswordSpecial;

  /// In en, this message reads:
  ///
  /// **Type a command or search...**
  String get commandSearch;

  /// In en, this message reads:
  ///
  /// **No results found.**
  String get commandEmpty;

  /// In en, this message reads:
  ///
  /// **Select a year**
  String get datePickerSelectYear;

  /// In en, this message reads:
  ///
  /// **Mo**
  String get abbreviatedMonday;

  /// In en, this message reads:
  ///
  /// **Tu**
  String get abbreviatedTuesday;

  /// In en, this message reads:
  ///
  /// **We**
  String get abbreviatedWednesday;

  /// In en, this message reads:
  ///
  /// **Th**
  String get abbreviatedThursday;

  /// In en, this message reads:
  ///
  /// **Fr**
  String get abbreviatedFriday;

  /// In en, this message reads:
  ///
  /// **Sa**
  String get abbreviatedSaturday;

  /// In en, this message reads:
  ///
  /// **Su**
  String get abbreviatedSunday;

  /// In en, this message reads:
  ///
  /// **January**
  String get monthJanuary;

  /// In en, this message reads:
  ///
  /// **February**
  String get monthFebruary;

  /// In en, this message reads:
  ///
  /// **March**
  String get monthMarch;

  /// In en, this message reads:
  ///
  /// **April**
  String get monthApril;

  /// In en, this message reads:
  ///
  /// **May**
  String get monthMay;

  /// In en, this message reads:
  ///
  /// **June**
  String get monthJune;

  /// In en, this message reads:
  ///
  /// **July**
  String get monthJuly;

  /// In en, this message reads:
  ///
  /// **August**
  String get monthAugust;

  /// In en, this message reads:
  ///
  /// **September**
  String get monthSeptember;

  /// In en, this message reads:
  ///
  /// **October**
  String get monthOctober;

  /// In en, this message reads:
  ///
  /// **November**
  String get monthNovember;

  /// In en, this message reads:
  ///
  /// **December**
  String get monthDecember;

  /// In en, this message reads:
  ///
  /// **Jan**
  String get abbreviatedJanuary;

  /// In en, this message reads:
  ///
  /// **Feb**
  String get abbreviatedFebruary;

  /// In en, this message reads:
  ///
  /// **Mar**
  String get abbreviatedMarch;

  /// In en, this message reads:
  ///
  /// **Apr**
  String get abbreviatedApril;

  /// In en, this message reads:
  ///
  /// **May**
  String get abbreviatedMay;

  /// In en, this message reads:
  ///
  /// **Jun**
  String get abbreviatedJune;

  /// In en, this message reads:
  ///
  /// **Jul**
  String get abbreviatedJuly;

  /// In en, this message reads:
  ///
  /// **Aug**
  String get abbreviatedAugust;

  /// In en, this message reads:
  ///
  /// **Sep**
  String get abbreviatedSeptember;

  /// In en, this message reads:
  ///
  /// **Oct**
  String get abbreviatedOctober;

  /// In en, this message reads:
  ///
  /// **Nov**
  String get abbreviatedNovember;

  /// In en, this message reads:
  ///
  /// **Dec**
  String get abbreviatedDecember;

  /// In en, this message reads:
  ///
  /// **Cancel**
  String get buttonCancel;

  /// In en, this message reads:
  ///
  /// **Save**
  String get buttonSave;

  /// In en, this message reads:
  ///
  /// **Hour**
  String get timeHour;

  /// In en, this message reads:
  ///
  /// **Minute**
  String get timeMinute;

  /// In en, this message reads:
  ///
  /// **Second**
  String get timeSecond;

  /// In en, this message reads:
  ///
  /// **AM**
  String get timeAM;

  /// In en, this message reads:
  ///
  /// **PM**
  String get timePM;

  /// In en, this message reads:
  ///
  /// **Red**
  String get colorRed;

  /// In en, this message reads:
  ///
  /// **Green**
  String get colorGreen;

  /// In en, this message reads:
  ///
  /// **Blue**
  String get colorBlue;

  /// In en, this message reads:
  ///
  /// **Alpha**
  String get colorAlpha;

  /// In en, this message reads:
  ///
  /// **Hue**
  String get colorHue;

  /// In en, this message reads:
  ///
  /// **Sat**
  String get colorSaturation;

  /// In en, this message reads:
  ///
  /// **Val**
  String get colorValue;

  /// In en, this message reads:
  ///
  /// **Lum**
  String get colorLightness;

  /// In en, this message reads:
  ///
  /// **Cut**
  String get menuCut;

  /// In en, this message reads:
  ///
  /// **Copy**
  String get menuCopy;

  /// In en, this message reads:
  ///
  /// **Paste**
  String get menuPaste;

  /// In en, this message reads:
  ///
  /// **Select All**
  String get menuSelectAll;

  /// In en, this message reads:
  ///
  /// **No Replacements Found**
  String get noSpellCheckReplacements;

  /// In en, this message reads:
  ///
  /// **Undo**
  String get menuUndo;

  /// In en, this message reads:
  ///
  /// **Redo**
  String get menuRedo;

  /// In en, this message reads:
  ///
  /// **Delete**
  String get menuDelete;

  /// In en, this message reads:
  ///
  /// **Share**
  String get menuShare;

  /// In en, this message reads:
  ///
  /// **Search Web**
  String get menuSearchWeb;

  /// In en, this message reads:
  ///
  /// **Live Text Input**
  String get menuLiveTextInput;

  /// In en, this message reads:
  ///
  /// **Select a date**
  String get placeholderDatePicker;

  /// In en, this message reads:
  ///
  /// **Select a time**
  String get placeholderTimePicker;

  /// In en, this message reads:
  ///
  /// **Select a color**
  String get placeholderColorPicker;

  /// In en, this message reads:
  ///
  /// **Previous**
  String get buttonPrevious;

  /// In en, this message reads:
  ///
  /// **Next**
  String get buttonNext;

  /// In en, this message reads:
  ///
  /// **Pull to refresh**
  String get refreshTriggerPull;

  /// In en, this message reads:
  ///
  /// **Release to refresh**
  String get refreshTriggerRelease;

  /// In en, this message reads:
  ///
  /// **Refreshing...**
  String get refreshTriggerRefreshing;

  /// In en, this message reads:
  ///
  /// **Refresh complete**
  String get refreshTriggerComplete;

  /// In en, this message reads:
  ///
  /// **Recent**
  String get colorPickerTabRecent;

  /// In en, this message reads:
  ///
  /// **RGB**
  String get colorPickerTabRGB;

  /// In en, this message reads:
  ///
  /// **HSV**
  String get colorPickerTabHSV;

  /// In en, this message reads:
  ///
  /// **HSL**
  String get colorPickerTabHSL;

  /// In en, this message reads:
  ///
  /// **HEX**
  String get colorPickerTabHEX;

  /// In en, this message reads:
  ///
  /// **Move Up**
  String get commandMoveUp;

  /// In en, this message reads:
  ///
  /// **Move Down**
  String get commandMoveDown;

  /// In en, this message reads:
  ///
  /// **Select**
  String get commandActivate;

  /// In en, this message reads:
  ///
  /// **{count} of {total} row(s) selected.**
  String dataTableSelectedRows(int count, int total);

  /// In en, this message reads:
  ///
  /// **Next**
  String get dataTableNext;

  /// In en, this message reads:
  ///
  /// **Previous**
  String get dataTablePrevious;

  /// In en, this message reads:
  ///
  /// **Columns**
  String get dataTableColumns;

  /// In en, this message reads:
  ///
  /// **DD**
  String get timeDaysAbbreviation;

  /// In en, this message reads:
  ///
  /// **HH**
  String get timeHoursAbbreviation;

  /// In en, this message reads:
  ///
  /// **MM**
  String get timeMinutesAbbreviation;

  /// In en, this message reads:
  ///
  /// **SS**
  String get timeSecondsAbbreviation;

  /// In en, this message reads:
  ///
  /// **Select a duration**
  String get placeholderDurationPicker;

  /// In en, this message reads:
  ///
  /// **Day**
  String get durationDay;

  /// In en, this message reads:
  ///
  /// **Hour**
  String get durationHour;

  /// In en, this message reads:
  ///
  /// **Minute**
  String get durationMinute;

  /// In en, this message reads:
  ///
  /// **Second**
  String get durationSecond;
}

class _ShadcnLocalizationsDelegate
    extends LocalizationsDelegate<ShadcnLocalizations> {
  const _ShadcnLocalizationsDelegate();

  @override
  Future<ShadcnLocalizations> load(Locale locale) {
    return SynchronousFuture<ShadcnLocalizations>(
      lookupShadcnLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      kSupportedLanguages.contains(locale.languageCode);

  @override
  bool shouldReload(_ShadcnLocalizationsDelegate old) => false;
}

/// The language codes [ShadcnLocalizations.delegate] accepts.
const Set<String> kSupportedLanguages = <String>{
  'ar', 'bg', 'bn', 'cs', 'da', 'de', 'el', 'en', 'es', 'fa', 'fi', 'fil', 'fr', 'he', 'hi', 'hu', 'id', 'it', 'ja', 'ko', 'mr', 'ms', 'nb', 'nl', 'pl', 'ps', 'pt', 'ro', 'ru', 'sk', 'sv', 'ta', 'te', 'th', 'tr', 'uk', 'ur', 'vi', 'zh',
};

/// The implementation for [locale].
///
/// Matches the most specific variant available, falling
/// back through script and region to the bare language:
/// `pt_BR` and `pt_PT` both resolve to Portuguese unless a
/// variant for one of them is shipped.
ShadcnLocalizations lookupShadcnLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'ar':
      return ShadcnLocalizationsAr();
    case 'bg':
      return ShadcnLocalizationsBg();
    case 'bn':
      return ShadcnLocalizationsBn();
    case 'cs':
      return ShadcnLocalizationsCs();
    case 'da':
      return ShadcnLocalizationsDa();
    case 'de':
      return ShadcnLocalizationsDe();
    case 'el':
      return ShadcnLocalizationsEl();
    case 'en':
      return ShadcnLocalizationsEn();
    case 'es':
      return ShadcnLocalizationsEs();
    case 'fa':
      return ShadcnLocalizationsFa();
    case 'fi':
      return ShadcnLocalizationsFi();
    case 'fil':
      return ShadcnLocalizationsFil();
    case 'fr':
      return ShadcnLocalizationsFr();
    case 'he':
      return ShadcnLocalizationsHe();
    case 'hi':
      return ShadcnLocalizationsHi();
    case 'hu':
      return ShadcnLocalizationsHu();
    case 'id':
      return ShadcnLocalizationsId();
    case 'it':
      return ShadcnLocalizationsIt();
    case 'ja':
      return ShadcnLocalizationsJa();
    case 'ko':
      return ShadcnLocalizationsKo();
    case 'mr':
      return ShadcnLocalizationsMr();
    case 'ms':
      return ShadcnLocalizationsMs();
    case 'nb':
      return ShadcnLocalizationsNb();
    case 'nl':
      return ShadcnLocalizationsNl();
    case 'pl':
      return ShadcnLocalizationsPl();
    case 'ps':
      return ShadcnLocalizationsPs();
    case 'pt':
      return ShadcnLocalizationsPt();
    case 'ro':
      return ShadcnLocalizationsRo();
    case 'ru':
      return ShadcnLocalizationsRu();
    case 'sk':
      return ShadcnLocalizationsSk();
    case 'sv':
      return ShadcnLocalizationsSv();
    case 'ta':
      return ShadcnLocalizationsTa();
    case 'te':
      return ShadcnLocalizationsTe();
    case 'th':
      return ShadcnLocalizationsTh();
    case 'tr':
      return ShadcnLocalizationsTr();
    case 'uk':
      return ShadcnLocalizationsUk();
    case 'ur':
      return ShadcnLocalizationsUr();
    case 'vi':
      return ShadcnLocalizationsVi();
    case 'zh':
      if (locale.scriptCode == 'Hant') {
        return ShadcnLocalizationsZhHant();
      }
      // Regions that write in this script.
      if (locale.scriptCode == null &&
          (locale.countryCode == 'TW'
              || locale.countryCode == 'HK'
              || locale.countryCode == 'MO')) {
        return ShadcnLocalizationsZhHant();
      }
      return ShadcnLocalizationsZh();
  }
  throw FlutterError(
    'ShadcnLocalizations.delegate failed to load unsupported locale "$locale". '
    'Supported languages are ${kSupportedLanguages.join(', ')}.',
  );
}
