# Contributing to shadcn_flutter

Thanks for your interest in contributing! This guide explains how the project is
organized, how to set up your environment, and the expectations for
contributions across components, utilities, icons, docs, and developer tooling.

If you get stuck, please open a discussion or hop into Discord:
https://discord.gg/ZzfBPQG4sV

## Before opening a pull request

To ensure your contribution is accepted and to prevent wasted effort, please follow these steps before submitting a Pull Request (PR):

1.  **Open an issue first**: Describe the problem you are solving or the feature you are proposing.
2.  **Propose your solution**: Explain how you intend to fix the issue. This allows us to validate the problem and discuss the approach before you invest time in coding.
    - Some issues might be better solved in user code rather than the library.
    - We may have a specific design or architectural preference for the solution.
3.  **Request assignment**: State in the issue that you would like to work on it and wait for it to be assigned to you.
4.  **Link the issue**: When you open your PR, please link to the issue it resolves.

PRs that do not follow this process may be closed if the solution is not aligned with the project's goals or if the problem is deemed invalid.

## Quick start

- Flutter: >= 3.47.0
- Dart SDK: >= 3.13.0 < 4.0.0
- Platforms: mobile, desktop, and web (docs run on web)

Windows PowerShell quickstart:

```powershell
# From repository root - resolves dependencies for every package in the workspace
flutter --version
flutter pub get

# Run the example app
cd packages/shadcn_flutter/example
flutter run

# Run the docs app in Chrome with web semantics (recommended for a11y checks)
cd ../../..
./run_docs_web_semantics.bat
```

## Project layout (high level)

- `packages/shadcn_flutter/` – The published library package
  - `lib/` – Public package code
    - `shadcn_flutter.dart` – Barrel exports for the public API
    - `src/` – Implementation details
      - `components/` – Components grouped by domain (form, layout, overlay, etc.)
      - `theme/` – Tokens, generated themes, typography, color schemes
      - `icons/` – Icon primitives (wired to fonts configured in `pubspec.yaml`)
      - `vendor/` – Third-party source bundled into the package rather than
        depended on, each with its upstream licence (see [Dependencies](#dependencies))
      - `util.dart`, `animation.dart`, `collection.dart` – Shared utilities
  - `l10n/` – `shadcn_<locale>.arb` translation sources (see [Translations](#4-translations))
  - `test/` – Widget/unit tests for the library; this is the main suite
  - `icons/` – Source icon sets and licenses
  - `colors/` – CSS sources used by style transpilers (for docs/themes)
  - `docs_images/` – Images used in the package README
- `packages/shadcn_flutter_material/` – Material interop (`MaterialLayer`,
  `MaterialShadcnApp`); shadcn_flutter itself does not depend on Material
- `packages/shadcn_flutter_cupertino/` – the same for Cupertino
- `packages/shadcn_flutter_skeletonizer/` – skeleton loading effects, split out
  so apps that never show a placeholder do not pay for `package:skeletonizer`
- `packages/docs/` – Flutter Web docs application (component gallery, usage examples)
- `packages/shadcn_flutter/example/` – Minimal consumer app, nested inside the
  library package so it's included in the pub.dev "Example" tab on publish
- `packages/gen/` – Developer tools and generators (icons, styles, LLM docs, analyzer
  helpers)
  - `bin/` – Entrypoints (e.g. `l10n_generator.dart`, `docs_divide.dart`,
    `llms_gen.dart`, `style_transpiler_v4.dart`)
  - `log/` – Analyzer outputs and derived task lists
- `packages/shadcn_flutter_genui/` – GenUI catalog that renders AI-generated
  interfaces using shadcn_flutter widgets
- `web_loaders/` – Standalone JS loader served via CDN at a fixed public URL
  (`cdn.jsdelivr.net/gh/sunarya-thito/shadcn_flutter@latest/web_loaders/...`);
  intentionally kept at the repo root and must not be moved.

## Contribution types

- Components: new widgets or improvements to existing ones
- Utilities: shared helpers, platform interfaces, collection/animation utils
- Icons/Fonts: adding or updating icon sets and font assets
- Docs: pages, examples, and site-level improvements
- Dev tools: generators and scripts that help build/maintain the library
- Tests: unit/widgets tests (example and test projects)

## Standards and expectations

- Code style: follow the repo lints (`packages/shadcn_flutter/analysis_options.yaml`).
  Public members must have API docs (`public_member_api_docs`).
- Null-safety: all code must be null-safe.
- API design: favor composition over inheritance, keep widgets small and
  testable, avoid breaking changes without discussion.
- Theming: consume tokens from `src/theme` and keep visual parity with shadcn/ui
  defaults when applicable. A component with a `ComponentThemeData` implements
  `Styleable<ThatTheme>` and takes a `theme:` argument. See
  [Components](#1-components).
- Dependencies: see [Dependencies](#dependencies). Adding one to
  `packages/shadcn_flutter` needs discussion first.
- Accessibility: ensure focus management, keyboard navigation, semantics, and
  readable contrast. Validate using the docs app with web semantics enabled.
- Performance: use `const` where possible, avoid unnecessary rebuilds, prefer
  lightweight layouts, and memoize expensive computations where appropriate.
- Tests: add or update tests when behavior changes; keep example/test_widget
  green.
- Commits/PRs: use clear commit titles (Conventional Commits encouraged) and a
  concise PR description with screenshots/gifs for UI changes.
- Scope: avoid editing files that are not related to your pull request.
  - Do not include large diffs caused by formatting unrelated files.
  - Do not commit build outputs or generated files unless strictly necessary.
  - Do not include additional changes that were not stated in your proposal.
    - If you want to add additional changes, please open another issue and PR, or edit your proposal and notify your assignee.

## Dependencies

`packages/shadcn_flutter` depends on `flutter`, `data_widget` and
`animation_kit`, and nothing else. Every dependency is paid for by every app
that uses the library, so please open an issue before adding one. A PR that
adds a dependency without that discussion will not be merged.

Past removals took one of four shapes. If you need something, pick whichever
fits:

- Bundle it under `lib/src/vendor/<name>/` when it is small and pure Dart. Keep
  the upstream source close to verbatim so it stays easy to diff against a
  newer release, copy its `LICENSE` in beside it, and add a library comment
  naming the upstream version and license. Use `// ignore_for_file:` for
  upstream lint style rather than reformatting it. `phonecodes` and
  `email_validator` are bundled this way.
- Reimplement it when bundling would drag in a dependency tree.
  `package:expressions` pulled `petitparser`, `quiver` and `rxdart` for one text
  formatter, so `lib/src/vendor/expressions/` is a hand-written parser covering
  the same grammar.
- Split it into a companion package when it is a real third party runtime.
  Follow `shadcn_flutter_material`: a `*Layer` widget, a README with a migration
  section, `example/example.md` and a CHANGELOG. That is how
  `shadcn_flutter_skeletonizer` came about.
- Expose a hook when the dependency is mostly assets plus a renderer.
  `CountryFlag` draws regional indicator emoji and takes a
  `CountryFlagTheme.builder`, so an app that wants real artwork can delegate to
  `package:country_flags` itself.

`packages/docs`, `packages/gen` and the test suites are not published, so they
can depend on whatever is convenient.

## Local development

- Install tooling once:
  - Flutter 3.47.0+ and Dart 3.13+
  - Chrome for web docs

- Typical workflow:

```powershell
# 1) Get packages (resolves the whole workspace in one shared pubspec.lock)
flutter pub get

# 2) Run analyzer (root; analyzes every workspace package)
flutter analyze

# 3) Run example app while iterating on widgets
cd packages/shadcn_flutter/example
flutter run

# 4) Run docs with web semantics to check a11y/keyboard behavior
cd ../../..
./run_docs_web_semantics.bat
```

- Format code:

```powershell
# From repo root
dart format .
```

## Submitting changes

1. Discuss first for big changes. Open an issue to align on API and scope.
2. Create a feature/fix branch (e.g. `feat/card-media`,
   `fix/select-focus-trap`).
3. Make changes and update docs and tests as needed.
4. Ensure quality gates pass locally:

```powershell
flutter pub get
flutter analyze

# Run tests
cd packages/shadcn_flutter; flutter test; cd ../..

# If you edited any lib/l10n/*.arb
dart run gen:l10n_generator

# Optional: rebuild LLM/docs helper files when relevant
./gen_dotguides.bat

# Optional: generate analyzer task parts after heavy changes
# Produces checklists under packages/gen/log/analyze_parts/
dart run packages/gen/bin/docs_divide.dart
```

5. Push and open a pull request. Include:
   - Summary of the change and motivation
   - Screenshots/gifs for visual components (light/dark if relevant)
   - Breaking changes (if any) and migration notes
   - Checklist confirming analyzer/tests/docs were updated

## Feature-specific guides

### 1) Components

Where:

- `packages/shadcn_flutter/lib/src/components/<domain>/...` for implementation
- Export from `packages/shadcn_flutter/lib/shadcn_flutter.dart` to make the component public
- Add docs examples under `packages/docs/lib/pages/docs/components/<component>/...`

Checklist:

- Name: match shadcn/ui naming where it makes sense; use Flutter idioms for
  props.
- API: keep props minimal; prefer stateless widgets and composition; support
  theming via `src/theme` tokens.
- Theming: a component that has styling knobs gets a `ComponentThemeData`
  subclass and declares it:

  ```dart
  class Tracker extends StatelessWidget implements Styleable<TrackerTheme> {
    /// {@macro shadcn_flutter.Styleable.theme}
    @override
    final TrackerTheme? theme;

    const Tracker({super.key, required this.data, this.theme});

    @override
    Widget build(BuildContext context) {
      final compTheme =
          this.theme ?? ComponentTheme.maybeOf<TrackerTheme>(context);
      // ...
    }
  }
  ```

  `theme:` applies to that widget only. Read it as a plain field and never put
  it into a `ComponentTheme`, or descendants would pick it up too.
  `.inheritStyle(...)` and `.resetInheritedStyle()` are the subtree equivalents
  and come for free from implementing `Styleable`. New styling options go on the
  theme class; the per property constructor arguments are deprecated. A widget
  can implement `Styleable` once, so pick the theme it is mainly styled by and
  resolve any others through `ComponentTheme.maybeOf`.
- Accessibility: verify focus order, keyboard navigation, and semantics. Use
  `./run_docs_web_semantics.bat` to run docs with `ENABLE_WEB_SEMANTICS`.
- Layout: ensure responsiveness; test in narrow and wide layouts.
- Exports: update `packages/shadcn_flutter/lib/shadcn_flutter.dart` to export your widget(s) in the
  appropriate section.
- Docs: add at least one runnable example and a short explanation. If images are
  needed for README, place them in `packages/shadcn_flutter/docs_images/`.
- Tests: add widget tests under `packages/shadcn_flutter/test/components/`.

Suggested structure:

- One primary widget file; split subparts when it improves clarity.
- Keep internal helpers private (prefix with `_`) and document all public
  classes/members.

### 2) Utilities

Where:

- `packages/shadcn_flutter/lib/src/util.dart`, `packages/shadcn_flutter/lib/src/animation.dart`,
  `packages/shadcn_flutter/lib/src/collection.dart`, or a new file under
  `packages/shadcn_flutter/lib/src/`

Guidelines:

- Keep APIs small and composable; document behavior and edge cases.
- Avoid leaking implementation details to the public API unless intended;
  re-export from `shadcn_flutter.dart` only when stable.
- Add unit tests where feasible; add a docs page if the utility affects
  user-facing behavior.

### 3) Icons and fonts

Sources & assets:

- Icon sources live under `packages/shadcn_flutter/icons/` (e.g.,
  `packages/shadcn_flutter/icons/bootstrap`, `packages/shadcn_flutter/icons/lucide`,
  `packages/shadcn_flutter/icons/radix`) with licenses included.
- Packaged fonts are registered in `packages/shadcn_flutter/pubspec.yaml` under
  `flutter/fonts` and stored in `packages/shadcn_flutter/lib/icons/`.

Generators:

- Bootstrap: `packages/gen/bin/bootstrap_icon_generator.dart`
- Lucide: `packages/gen/bin/lucide_icons_generator.dart`
- Radix: `packages/gen/bin/radix_icon_generator.dart`
- Convert WOFF2 → OTF: `packages/gen/bin/woff2otf.dart`

Typical flow (run from the repo root):

```powershell
# After updating sources under packages/shadcn_flutter/icons, regenerate the Dart bindings/fonts as needed
dart run packages/gen/bin/bootstrap_icon_generator.dart
dart run packages/gen/bin/lucide_icons_generator.dart
dart run packages/gen/bin/radix_icon_generator.dart

# If you add new font files, ensure packages/shadcn_flutter/pubspec.yaml has matching entries under flutter/fonts
```

Docs:

- Update icon showcase pages in `packages/docs/lib/pages/docs/icons_page.dart` if new
  sets are added.

### 4) Translations

shadcn_flutter ships its own strings (validation messages, month names, the
text selection menu) in 40 locales. Contributions here are very welcome.
Reviewing an existing language is as useful as adding a new one, since none of
the translations have been checked by a native speaker.

**Where**

- `packages/shadcn_flutter/lib/l10n/shadcn_<locale>.arb` holds the sources you
  edit.
- `packages/shadcn_flutter/lib/src/components/locale/shadcn_localizations*.dart`
  are generated. Do not edit them by hand; they carry a
  `GENERATED CODE - DO NOT MODIFY BY HAND` header and your changes will be
  overwritten on the next run.
- `shadcn_en.arb` is the template. Every other file is checked against it.

**Generating**

```powershell
# From the repo root, after editing any .arb
dart run gen:l10n_generator
dart format packages/shadcn_flutter/lib/src/components/locale
```

> Do not run `flutter gen-l10n`. There is no `l10n.yaml` any more. Its template
> hardcodes imports of `package:flutter_localizations` and `package:intl`, which
> this package does not depend on, and it needs `flutter: generate: true`, which
> would let an ordinary build overwrite the output.
> `packages/gen/bin/l10n_generator.dart` replaces it. See
> [Dependencies](#dependencies) for why that matters.

**Adding a language**

1. Copy `shadcn_en.arb` to `shadcn_<code>.arb`, using the ISO 639 code
   (`shadcn_es.arb`, `shadcn_fil.arb`).
2. Set `"@@locale"` to the same code.
3. Delete every `"@key"` metadata block. A translation file carries only
   `"key": "text"` pairs. Placeholder names, types and order come from the
   template, so metadata here is ignored and only drifts out of date.
4. Translate every value.
5. If the language is written right to left, add its code to `_rtlLanguages` in
   `packages/gen/bin/l10n_generator.dart`. Without it the strings are translated
   but the layout is not mirrored.
6. Add a display name to `_languageNames` in the same file. It only feeds the
   generated doc comments, but every shipped locale has one.
7. Run the generator and the localization tests.

The generated classes have no fallbacks, so a missing key would show up as an
English string in a translated app rather than as an error. The generator is
strict to catch that: it fails when a file is missing a key, adds a key that is
not in the template, or drops a `{placeholder}` the English message uses. The
error names the file and the key.

**Placeholders**

Keep every `{placeholder}` from the English message. Reorder them to suit the
language if you need to; the generator interpolates by name, not position:

```jsonc
// shadcn_en.arb
"dataTableSelectedRows": "{count} of {total} row(s) selected."

// shadcn_ja.arb, reordered, both still present
"dataTableSelectedRows": "{total} 行中 {count} 行を選択中。"
```

ICU plurals, selects and `"format":` are not supported. The generator rejects
them with an explanatory error rather than mistranslating. If a message needs
one, raise it in the issue so we can teach the generator.

**Region and script variants**

The locale part of the filename is a BCP 47 tag with `_` separators:

| File | Covers |
| :--- | :--- |
| `shadcn_pt.arb` | the language |
| `shadcn_pt_PT.arb` | a region (two letters, or three digits like `419`) |
| `shadcn_zh_Hant.arb` | a script (four letters) |
| `shadcn_zh_Hant_HK.arb` | both |

A variant only needs to exist where the wording differs. Resolution falls back
through script and region to the bare language, so every variant needs its base
language present. The generator says so if it is missing.

A script variant can also claim the regions that write in it, so a locale that
arrives without a script subtag still finds it:

```jsonc
{
  "@@locale": "zh_Hant",
  "@@countries": ["TW", "HK", "MO"],
  "formNotEmpty": "此欄位不能為空"
}
```

With that, `Locale('zh', 'TW')` resolves to Traditional Chinese, while an
explicit `zh_Hans_HK` still resolves to Simplified.

**Testing**

```powershell
cd packages/shadcn_flutter
flutter test test/components/localizations_test.dart
```

Those tests walk every shipped locale and check that the delegate accepts it,
that placeholders survive, that no message is empty, that variants resolve most
specific first, and that right to left languages mirror. Run the full suite
before opening the PR.

**What to look at when reviewing a language**

The sentences are usually fine. Mistakes cluster in the short strings, so give
those a careful pass:

- The weekday abbreviations, `abbreviatedMonday` through
  `abbreviatedSunday`. The list is Monday first, and the usual length varies by
  language.
- The month abbreviations, which are not always a simple truncation.
- The duration field hints `timeDaysAbbreviation`, `timeHoursAbbreviation`,
  `timeMinutesAbbreviation` and `timeSecondsAbbreviation`. These are localized
  (`DD`/`HH` in English, `TT`/`SS` in German), and it is easy to miss two of them
  colliding in one language.
- The color labels `colorSaturation`, `colorValue` and `colorLightness`. They
  sit in a narrow column and are abbreviated in most languages.
- `timeAM` / `timePM`, where conventions differ a lot.

To reword a single string without touching the shared translation, an app can
subclass that locale's generated class. They are all exported:

```dart
class MyStrings extends ShadcnLocalizationsDe {
  @override
  String get buttonSave => 'Sichern';
}
```

### 5) Theming and colors

- Theme tokens and generated themes live under `packages/shadcn_flutter/lib/src/theme/`.
- If you change color sources in `packages/shadcn_flutter/colors/`, use the style transpilers to
  regenerate Dart styles (run from the repo root):

```powershell
# Transpile styles (versioned)
dart run packages/gen/bin/style_transpiler_v4.dart
# or
dart run packages/gen/bin/style_transpiler.dart

# Generate color helpers if needed
dart run packages/gen/bin/color_generator.dart
```

- Validate changes visually in the docs app (light/dark + multiple color
  schemes).

### 6) Docs site and examples

Run locally:

```powershell
# Recommended (enables accessible web semantics)
./run_docs_web_semantics.bat

# Manual
cd packages/docs
flutter run -d chrome --dart-define=ENABLE_WEB_SEMANTICS=true
```

Add docs:

- New component page: add an example directory under
  `packages/docs/lib/pages/docs/components/<component>/` and register in the component
  pages where needed.
- Global docs (installation, theme, typography, etc.): see
  `packages/docs/lib/pages/docs/*`.
- Sidebar/nav: `packages/docs/lib/pages/docs/sidebar_nav.dart` and related pages.

LLMs and guides:

- Generate machine‑readable references after component changes (run from the repo root):

```powershell
./gen_llms.bat         # runs: dart run packages/gen/bin/llms_gen.dart
./gen_dotguides.bat    # runs: dart run packages/gen/bin/dotguides_gen.dart
```

Analyzer task lists for docs reviews:

```powershell
dart run packages/gen/bin/docs_divide.dart
# Outputs checklists under packages/gen/log/analyze_parts/
```

## Testing

- Prefer adding a minimal widget test when changing behavior.
- Places to put tests:
  - `packages/shadcn_flutter/test/` – the main suite, and where nearly
    everything belongs. Mirror the source layout: `test/components/`,
    `test/theme/`, `test/vendor/`. `test/test_helper.dart` has a `SimpleApp`
    wrapper that gives a widget the `ShadcnApp` ancestors it needs.
  - Keep tests light. The full suite is large, so run the file you touched while
    iterating and the whole suite once before pushing.
  - `packages/shadcn_flutter_material/test/`,
    `packages/shadcn_flutter_cupertino/test/`,
    `packages/shadcn_flutter_skeletonizer/test/` – for interop behaviour that
    only exists in a companion package.
  - `packages/docs/test/` – smoke tests for the docs examples.
  - `packages/shadcn_flutter/example/test/` – only for the example app itself.

Run tests:

```powershell
# The main suite
cd packages/shadcn_flutter; flutter test; cd ../..

# Companion packages and docs
cd packages/shadcn_flutter_material; flutter test; cd ../..
cd packages/shadcn_flutter_cupertino; flutter test; cd ../..
cd packages/shadcn_flutter_skeletonizer; flutter test; cd ../..
cd packages/docs; flutter test; cd ../..
```

## Commit messages and PRs

- Conventional Commits encouraged (e.g., `feat: add pagination widget`,
  `fix(select): correct focus restoration`).
- Scope examples: `alert`, `pagination`, `theme`, `docs`, `icons`, `generator`.
- Keep PRs focused; large refactors should be split where possible.

PR checklist:

- [ ] Code formatted (`dart format .`)
- [ ] Analyzer passes (`flutter analyze`)
- [ ] Tests added/updated and passing (`flutter test` where applicable)
- [ ] Public API documented (`public_member_api_docs`)
- [ ] Docs/examples updated (docs pages or README images if needed)
- [ ] Exports updated in `packages/shadcn_flutter/lib/shadcn_flutter.dart` (for new public widgets)
- [ ] Generators run (icons/styles/LLMs/l10n) when relevant, and their output committed
- [ ] No new dependency in `packages/shadcn_flutter` without prior agreement
      (see [Dependencies](#dependencies))

## Issue reporting

- Use GitHub Issues for bugs and feature requests.
- Include reproduction steps, expected vs. actual behavior, environment
  (`flutter doctor -v`), and screenshots when UI-related.

## Code of conduct

Please be respectful and follow the GitHub Community Guidelines in all
interactions. We foster an inclusive, welcoming environment for contributors of
all backgrounds and experience levels.

## License

By contributing, you agree that your contributions will be licensed under the
project’s license (see `LICENSE`).
