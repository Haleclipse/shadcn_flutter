## [0.0.55]
### Fixed
- **[#426]**: Material ancestors are now installed through
  `ShadcnApp.surfaceBuilder` instead of `ShadcnApp.builder`, so they also cover
  shadcn overlays. A Material widget inside a toast previously found no
  `Material` ancestor.
- `MaterialLayer` now installs `kMaterialLocalizationsDelegates` over its own
  subtree by default, so it works standalone. Previously a bare `MaterialLayer`
  under a plain `ShadcnApp` threw `No MaterialLocalizations found` from an
  `AppBar`, a tooltip or a `SnackBar`. Set `localizations: false` to opt out.

### Added
- `MaterialLayer.localizations`, controlling the above.

### Changed
- Documented that `package:flutter/material.dart` and
  `package:material_ui/material_ui.dart` define distinct, incompatible types.
  An app that keeps its old SDK imports still compiles but fails
  `debugCheckHasMaterial` in debug builds — the fix is migrating the import.
  See the README's migration section.

## [0.0.54]
### Added
- Requires Flutter 3.47.0 (Dart 3.13.0) or newer, matching `shadcn_flutter`.
- Initial release, split out of `shadcn_flutter` when that package dropped its
  Material dependency.
- `MaterialShadcnApp`, a drop-in replacement for `ShadcnApp` that registers the
  Material localizations and installs the Material theme, `Material` and
  `ScaffoldMessenger` ancestors.
- `MaterialLayer`, the same ancestors for a single subtree, plus
  `materialThemeFor` and `kMaterialLocalizationsDelegates`.
- `buildAdaptiveEditableTextContextMenu`,
  `buildMaterialEditableTextContextMenu` and
  `buildMaterialSpellCheckSuggestionsToolbar`, replacing
  `TextField.nativeContextMenuBuilder()` and
  `TextField.materialContextMenuBuilder()`.
- Re-exports of `Icons`, `MaterialPage`, `MaterialPageRoute` and `SliverAppBar`,
  which `shadcn_flutter` used to re-export itself.
