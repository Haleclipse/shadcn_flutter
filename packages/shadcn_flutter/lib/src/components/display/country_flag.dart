import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Builder function type for rendering a country flag.
///
/// Receives the resolved [CountryFlagDetails] — the country to draw plus the
/// size and shape it should be drawn at — and returns the widget that paints
/// it. Set one on [CountryFlagTheme.builder] to swap shadcn_flutter's built-in
/// emoji flags for artwork of your own.
typedef CountryFlagBuilder = Widget Function(
  BuildContext context,
  CountryFlagDetails details,
);

/// The request a [CountryFlagBuilder] answers.
///
/// Carries the country and the box the flag is expected to fill. A builder is
/// free to ignore [width] and [height] — [CountryFlag] does not clip or
/// constrain the widget it gets back — but honouring them keeps flags aligned
/// with the rest of the layout.
class CountryFlagDetails {
  /// The country whose flag should be drawn.
  final Country country;

  /// Width the flag should occupy, in logical pixels.
  final double width;

  /// Height the flag should occupy, in logical pixels.
  final double height;

  /// Shape the flag should be clipped to.
  ///
  /// Any [ShapeBorder] works: [RoundedRectangleBorder] for rounded corners,
  /// [CircleBorder] for a circular badge. Null means no clipping.
  final ShapeBorder? shape;

  /// Creates the details handed to a [CountryFlagBuilder].
  const CountryFlagDetails({
    required this.country,
    required this.width,
    required this.height,
    this.shape,
  });

  /// The ISO 3166-1 alpha-2 code of [country], e.g. `US`.
  String get countryCode => country.code;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CountryFlagDetails &&
        other.country == country &&
        other.width == width &&
        other.height == height &&
        other.shape == shape;
  }

  @override
  int get hashCode => Object.hash(country, width, height, shape);

  @override
  String toString() =>
      'CountryFlagDetails(country: $country, width: $width, height: $height, shape: $shape)';
}

/// Theme configuration for [CountryFlag].
///
/// Besides the usual sizing and shape defaults, this theme carries [builder] —
/// the flag artwork provider for the subtree. shadcn_flutter draws flags as
/// Unicode regional-indicator emoji, which needs no assets and no extra
/// dependency. Platforms differ in how well they render those — Windows in
/// particular ships no flag glyphs at all and falls back to the country's two
/// letters — so apps that want real artwork provide their own builder.
///
/// Example, backing flags with `package:country_flags`:
/// ```dart
/// ComponentTheme(
///   data: CountryFlagTheme(
///     builder: (context, details) => country_flags.CountryFlag.fromCountryCode(
///       details.countryCode,
///       theme: country_flags.ImageTheme(
///         width: details.width,
///         height: details.height,
///       ),
///     ),
///   ),
///   child: const MyApp(),
/// );
/// ```
class CountryFlagTheme extends ComponentThemeData {
  /// Renders the flag artwork.
  ///
  /// Null means [CountryFlag.emojiBuilder], the emoji fallback that ships with
  /// shadcn_flutter.
  final CountryFlagBuilder? builder;

  /// Default width of a flag, in logical pixels.
  final double? width;

  /// Default height of a flag, in logical pixels.
  final double? height;

  /// Default shape flags are clipped to.
  final ShapeBorder? shape;

  /// Creates a [CountryFlagTheme].
  const CountryFlagTheme({this.builder, this.width, this.height, this.shape});

  /// Creates a copy of this theme with the given values replaced.
  CountryFlagTheme copyWith({
    ValueGetter<CountryFlagBuilder?>? builder,
    ValueGetter<double?>? width,
    ValueGetter<double?>? height,
    ValueGetter<ShapeBorder?>? shape,
  }) {
    return CountryFlagTheme(
      builder: builder == null ? this.builder : builder(),
      width: width == null ? this.width : width(),
      height: height == null ? this.height : height(),
      shape: shape == null ? this.shape : shape(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CountryFlagTheme &&
        other.builder == builder &&
        other.width == width &&
        other.height == height &&
        other.shape == shape;
  }

  @override
  int get hashCode => Object.hash(builder, width, height, shape);

  @override
  String toString() =>
      'CountryFlagTheme(builder: $builder, width: $width, height: $height, shape: $shape)';
}

/// Displays the flag of a country.
///
/// The artwork comes from [CountryFlagTheme.builder]. With no theme in scope,
/// flags are drawn as Unicode regional-indicator emoji — no assets, no extra
/// dependency, and no fixed resolution. See [CountryFlagTheme] for swapping in
/// real flag images.
///
/// Example:
/// ```dart
/// CountryFlag.fromCountryCode(
///   'US',
///   height: 18,
///   width: 24,
///   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
/// );
/// ```
class CountryFlag extends StatelessWidget
    implements Styleable<CountryFlagTheme> {
  /// Draws a flag as a regional-indicator emoji pair, scaled to fit.
  ///
  /// This is what [CountryFlag] falls back to when [CountryFlagTheme.builder]
  /// is null. It is public so a custom builder can defer to it for countries
  /// its own artwork does not cover.
  static Widget emojiBuilder(BuildContext context, CountryFlagDetails details) {
    return _EmojiCountryFlag(details: details);
  }

  /// The country to draw, or null if the lookup found nothing.
  ///
  /// A null country renders as an empty box of the requested size, so a bad
  /// country code leaves the surrounding layout intact instead of throwing.
  final Country? country;

  /// Width of the flag; falls back to [CountryFlagTheme.width], then to 24
  /// scaled by the theme.
  @Deprecated('Use theme: CountryFlagTheme(width: ...) instead.')
  final double? width;

  /// Height of the flag; falls back to [CountryFlagTheme.height], then to 18
  /// scaled by the theme.
  @Deprecated('Use theme: CountryFlagTheme(height: ...) instead.')
  final double? height;

  /// Shape the flag is clipped to.
  ///
  /// Falls back to [CountryFlagTheme.shape], then to no clipping.
  final ShapeBorder? shape;

  /// {@macro shadcn_flutter.Styleable.theme}
  @override
  final CountryFlagTheme? theme;

  /// Creates a flag for [country].
  const CountryFlag(
    this.country, {
    super.key,
    this.width,
    this.height,
    this.shape,
    this.theme,
  });

  /// Creates a flag from an ISO 3166-1 alpha-2 country code, e.g. `US`.
  ///
  /// Unknown codes render as an empty box.
  CountryFlag.fromCountryCode(
    String countryCode, {
    super.key,
    this.width,
    this.height,
    this.shape,
    this.theme,
  }) : country = _findByCode(countryCode);

  /// Creates a flag from an ISO 4217 currency code, e.g. `USD`.
  ///
  /// Several countries can share a currency; the first match in
  /// [Country.values] wins. Unknown codes render as an empty box.
  CountryFlag.fromCurrencyCode(
    String currencyCode, {
    super.key,
    this.width,
    this.height,
    this.shape,
    this.theme,
  }) : country = _findByCurrency(currencyCode);

  /// Creates a flag from an international dial code, e.g. `+1`.
  ///
  /// Several countries can share a dial code; the first match in
  /// [Country.values] wins. Unknown prefixes render as an empty box.
  CountryFlag.fromPhonePrefix(
    String prefix, {
    super.key,
    this.width,
    this.height,
    this.shape,
    this.theme,
  }) : country = _findByDialCode(prefix);

  static Country? _findByCode(String countryCode) {
    final normalized = countryCode.toUpperCase();
    for (final country in Country.values) {
      if (country.code == normalized) return country;
    }
    return null;
  }

  static Country? _findByCurrency(String currencyCode) {
    final normalized = currencyCode.toUpperCase();
    for (final country in Country.values) {
      if (country.currency.code == normalized) return country;
    }
    return null;
  }

  static Country? _findByDialCode(String prefix) {
    final normalized = prefix.startsWith('+') ? prefix : '+$prefix';
    for (final country in Country.values) {
      if (country.dialCode == normalized) return country;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compTheme =
        this.theme ?? ComponentTheme.maybeOf<CountryFlagTheme>(context);
    final widthValue = styleValue(
      widgetValue: width,
      themeValue: compTheme?.width,
      defaultValue: theme.scaling * 24,
    );
    final heightValue = styleValue(
      widgetValue: height,
      themeValue: compTheme?.height,
      defaultValue: theme.scaling * 18,
    );
    final country = this.country;
    if (country == null) {
      return SizedBox(width: widthValue, height: heightValue);
    }
    final details = CountryFlagDetails(
      country: country,
      width: widthValue,
      height: heightValue,
      shape: shape ?? compTheme?.shape,
    );
    return (compTheme?.builder ?? emojiBuilder)(context, details);
  }
}

/// The built-in flag renderer: a regional-indicator emoji, scaled to fit.
class _EmojiCountryFlag extends StatelessWidget {
  final CountryFlagDetails details;

  const _EmojiCountryFlag({required this.details});

  @override
  Widget build(BuildContext context) {
    Widget result = SizedBox(
      width: details.width,
      height: details.height,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text(
          details.country.flag,
          textAlign: TextAlign.center,
          // Flag emoji pick up italics and weight badly across platforms, and
          // a line height above 1 leaves the glyph floating inside the box.
          style: const TextStyle(
            height: 1,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
    final shape = details.shape;
    if (shape != null) {
      result = ClipPath(
        clipper: ShapeBorderClipper(shape: shape),
        child: result,
      );
    }
    return result;
  }
}
