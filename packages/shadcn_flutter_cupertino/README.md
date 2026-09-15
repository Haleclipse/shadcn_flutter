# shadcn_flutter_cupertino

Cupertino interop for
[shadcn_flutter](https://pub.dev/packages/shadcn_flutter).

`shadcn_flutter` is built on `package:flutter/widgets.dart` alone — it depends on
neither Material nor Cupertino, following Flutter's move of those libraries out
of the framework and into the `material_ui` and `cupertino_ui` packages. Add this
package when your app uses Cupertino widgets alongside shadcn_flutter
components.

## Install

```shell
flutter pub add shadcn_flutter_cupertino
```

This pulls in `cupertino_ui` transitively. Add it directly too if you import its
widgets in your own code, which you almost always will:

```shell
flutter pub add cupertino_ui
```

## Migrating from `package:flutter/cupertino.dart`

**This is the one thing to get right, and it is the most common upgrade
problem.** Flutter still ships `package:flutter/cupertino.dart`, so an app that
keeps its old imports goes on compiling after the upgrade — but it will not
work.

`package:flutter/cupertino.dart` and `package:cupertino_ui/cupertino_ui.dart`
are two separate libraries that each define their own `CupertinoTheme`,
`CupertinoLocalizations`, `CupertinoPageScaffold` and so on. They are different
Dart types, so a widget from the SDK copy cannot see the theme or the
localizations that `CupertinoLayer` installs, and throws:

```
No CupertinoLocalizations found.
```

These checks live inside `assert`s, so they only surface in debug builds.
Release builds stay silent while still missing the Cupertino defaults.

The fix is to change the import, not to add more layers:

```diff
- import 'package:flutter/cupertino.dart';
+ import 'package:cupertino_ui/cupertino_ui.dart';
```

Do this everywhere in your app. Mixing the two libraries in one widget tree does
not work, and no amount of `CupertinoLayer` or `CupertinoShadcnApp` nesting will
make it work.

See [issue #426](https://github.com/sunarya-thito/shadcn_flutter/issues/426).

## Localizations and overlays

`CupertinoShadcnApp` handles both of these for you. They are worth knowing about
if you compose `ShadcnApp` yourself:

- **Localizations have to be registered app-wide.** Cupertino widgets assert on
  `CupertinoLocalizations.of` — a date picker, a nav bar back label or a text
  selection toolbar throws without it. `CupertinoLayer` installs them over its
  own subtree, but a route pushed by `showCupertinoDialog` builds outside that
  subtree, on the root navigator. For those, put `kCupertinoLocalizationsDelegates` on
  `ShadcnApp.localizationsDelegates`.
- **Use `surfaceBuilder`, not `builder`.** `ShadcnApp.builder` is applied inside
  shadcn's own overlay layers, so a Cupertino widget shown in a toast would find
  no `CupertinoTheme` above it. `ShadcnApp.surfaceBuilder` wraps the whole surface
  instead:

  ```dart
  ShadcnApp(
    localizationsDelegates: kCupertinoLocalizationsDelegates,
    surfaceBuilder: (context, child) => CupertinoLayer(child: child),
    home: const HomePage(),
  );
  ```

## Use

`CupertinoShadcnApp` is a drop-in replacement for `ShadcnApp`. It takes exactly
the same parameters, registers the Cupertino localizations, and installs the
`CupertinoTheme` ancestor that Cupertino widgets read from.

```dart
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter_cupertino/shadcn_flutter_cupertino.dart';

void main() {
  runApp(
    CupertinoShadcnApp(
      title: 'My App',
      theme: ThemeData(
        colorScheme: ColorSchemes.lightZinc,
        radius: 0.5,
      ),
      home: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Hybrid app'),
        ),
        child: const Center(
          child: PrimaryButton(child: Text('A shadcn button')),
        ),
      ),
    ),
  );
}
```

The Cupertino theme is derived from the shadcn theme, so it follows it
automatically — including `darkTheme` and `themeMode` switches. Pass
`cupertinoTheme` to override it.

### One subtree only

If Cupertino widgets appear in only part of the app, keep the plain `ShadcnApp`
and wrap that subtree in a `CupertinoLayer`. Register the localizations
delegates at the app level: delegates have to sit above the `Localizations`
widget, so a layer alone cannot add them.

```dart
ShadcnApp(
  localizationsDelegates: kCupertinoLocalizationsDelegates,
  home: Builder(
    builder: (context) {
      return CupertinoLayer(
        child: CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(
            middle: Text('Only this screen'),
          ),
          child: const SizedBox.shrink(),
        ),
      );
    },
  ),
);
```

### The other direction

To use shadcn_flutter components inside an existing `CupertinoApp`, you need
neither this package nor any special setup: wrap the subtree in `ShadcnLayer`,
or a single widget in `ShadcnUI`.

## What this package exports

| Symbol | What it does |
| --- | --- |
| `CupertinoShadcnApp` | `ShadcnApp` plus Cupertino theme and localizations. |
| `CupertinoLayer` | Installs `CupertinoTheme` around a subtree. |
| `cupertinoThemeFor(ThemeData)` | Derives a `CupertinoThemeData` from a shadcn `ThemeData`. |
| `kCupertinoLocalizationsDelegates` | The delegates Cupertino widgets require. |
| `buildCupertinoEditableTextContextMenu` | iOS-style text selection toolbar, the old `TextField.cupertinoContextMenuBuilder()`. |
| `buildCupertinoSpellCheckSuggestionsToolbar` | iOS-style spell check toolbar. |
| `CupertinoIcons`, `CupertinoPage`, `CupertinoPageRoute` | Re-exported from `cupertino_ui`. |
| `cupertinoDesktopTextSelectionControls` and friends | Re-exported; these used to come from `shadcn_flutter`. |

Everything else comes from `package:cupertino_ui/cupertino_ui.dart` — import it
directly, with a prefix if its names collide with shadcn_flutter's.

## Links

- [Material/Cupertino guide](https://sunarya-thito.github.io/shadcn_flutter/#/external)
- [shadcn_flutter on pub.dev](https://pub.dev/packages/shadcn_flutter)
- [shadcn_flutter_material](https://pub.dev/packages/shadcn_flutter_material)
