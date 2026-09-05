/// Country, dial-code and currency data, vendored from `package:phonecodes`.
///
/// shadcn_flutter used to depend on `phonecodes` for the country list behind
/// [PhoneInput]. The package is pure data with no dependencies of its own, so
/// it is bundled here instead to keep shadcn_flutter's dependency list small.
///
/// Upstream: https://pub.dev/packages/phonecodes (v0.0.4), BSD 3-Clause,
/// Copyright 2023 Sreelal TS. The full license text sits next to this file in
/// `LICENSE`. Kept deliberately close to upstream so it stays easy to diff
/// against a newer release.
library;

part 'src/country.dart';
part 'src/phonecodes_base.dart';
part 'src/exception.dart';
part 'src/currency.dart';
part 'src/filter.dart';
