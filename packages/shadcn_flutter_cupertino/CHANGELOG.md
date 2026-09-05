## [0.0.55]
### Fixed
- **[#426]**: The `CupertinoTheme` is now installed through
  `ShadcnApp.surfaceBuilder` instead of `ShadcnApp.builder`, so it also covers
  shadcn overlays. A Cupertino widget inside a toast previously found no theme.
- `CupertinoLayer` now installs `kCupertinoLocalizationsDelegates` over its own
  subtree by default, so it works standalone. Previously a bare `CupertinoLayer`
  under a plain `ShadcnApp` threw `No CupertinoLocalizations found`. Set
  `localizations: false` to opt out.

### Added
- `CupertinoLayer.localizations`, controlling the above.

### Changed
- Documented that `package:flutter/cupertino.dart` and
  `package:cupertino_ui/cupertino_ui.dart` define distinct, incompatible types.
  See the README's migration section.

## [0.0.54]
### Added
- Requires Flutter 3.47.0 (Dart 3.13.0) or newer, matching `shadcn_flutter`.
- Initial release, split out of `shadcn_flutter` when that package dropped its
  Cupertino dependency.
- `CupertinoShadcnApp`, a drop-in replacement for `ShadcnApp` that registers the
  Cupertino localizations and installs the `CupertinoTheme` ancestor.
- `CupertinoLayer`, the same theme for a single subtree, plus
  `cupertinoThemeFor` and `kCupertinoLocalizationsDelegates`.
- `buildCupertinoEditableTextContextMenu` and
  `buildCupertinoSpellCheckSuggestionsToolbar`, replacing
  `TextField.cupertinoContextMenuBuilder()`.
- Re-exports of `CupertinoIcons`, `CupertinoPage`, `CupertinoPageRoute` and the
  Cupertino text selection controls that `shadcn_flutter` used to re-export.
