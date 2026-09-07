# Flutter 3.47 semantic Web composition patch

This directory preserves the source patch that fixes composing ranges for Web
text fields while Flutter semantics is enabled. The patch is pinned to Flutter
3.47.0, framework revision
`4cf24164269a5ebf0c16a028a00727d0e77bbb05`, and Dart 3.13.0. It is not a
general patch for another Flutter revision.

## Failure mechanism

`SemanticsTextEditingStrategy` overrides the default Web text-editing event
registration and teardown. At the pinned revision it does not register the
default composition handlers. It also does not restore the mixin's composition
state when the framework sends a `TextEditingValue` with a nonempty composing
range. A DOM selection notification can therefore feed the same text and caret
back with `TextRange(-1, -1)`.

The [source patch](flutter-3.47.0-semantic-composition.patch) makes three scoped
changes:

1. Register the existing composition handlers on the active semantic input.
2. Remove those handlers and clear their state during strategy teardown.
3. Synchronize a valid framework composing range into the existing composition
   mixin before applying the editing state to the DOM.

The patch adds engine regressions for a browser composition event, teardown,
and framework-state round-trip. It does not change Catalog widgets or relax any
Catalog assertion.

## Rebuild requirement

Editing the checked-out Dart source is insufficient for an application build.
Flutter applications load precompiled files from
`bin/cache/flutter_web_sdk/kernel`. The repository's
[`patch_flutter_web_composition.py`](../../../../.github/scripts/patch_flutter_web_composition.py)
verifies the exact SDK revision and source hashes, applies the patch, updates
the cached Web engine source, compiles all seven affected DDC, Dart2JS and
Dart2Wasm artifacts in a staging directory, then atomically installs them.

The script **modifies the SDK supplied with `--flutter` in place**. GitHub
Actions uses a disposable SDK. For a local run, create an isolated SDK copy or
Flutter Git worktree with its own copy of `bin/cache`; do not pass a shared SDK.

From the repository root, after `flutter pub get --enforce-lockfile` has created
`.dart_tool/package_config.json`:

```sh
python3 .github/scripts/patch_flutter_web_composition.py \
  --flutter /absolute/path/to/isolated-flutter/bin/flutter \
  --package-config .dart_tool/package_config.json \
  --evidence /fresh/path/flutter-web-composition-sdk
```

The evidence directory is required to be new. `manifest.json` records the
toolchain, all source and artifact hashes before and after rebuilding, and the
patch identity. `build.log` records each compiler invocation. Unexpected SDK
versions, partial patches, changed source hashes, missing compiler output, or a
failed compile stop the command.

To run the Chrome input acceptance against an exact browser/driver pair:

```sh
PATH=/absolute/path/to/isolated-flutter/bin:$PATH \
CHROMEWEBDRIVER=/absolute/path/to/chromedriver-directory \
python3 .github/scripts/run_catalog_input_acceptance.py \
  --platform chrome \
  --chrome-binary "/absolute/path/to/Google Chrome for Testing" \
  --artifacts /fresh/path/input-chrome
```

## Verified scope

The [September 7 record](../../quality_evidence/2026-09-07-flutter-web-composition-fix.md)
contains the red/green results and hashes. On the pinned revision:

- all 26 semantic text-field engine tests passed in Chrome with Dart2JS;
- the same 26 tests passed in Chrome with Dart2Wasm;
- Catalog's five-scenario framework input suite passed with its original
  composing-range assertions;
- the independent 26-stage W3C Chrome suite passed;
- Catalog JS and Wasm release builds completed.

The framework suite uses injected `TextEditingValue` and Flutter key events.
The W3C suite uses real browser pointer, key, clipboard and window commands, but
its CJK text delivery is Unicode insertion. Neither result is an operating
system IME candidate workflow. Real OS IME and assistive-technology sign-off
remain separate acceptance layers.
