# Flutter Web semantic composition fix — 2026-09-07

The retained four-browser framework failures were traced to Flutter 3.47.0's
Web semantics text-editing strategy, rather than `BeautifulPromptBar` or the
Catalog test harness. `SemanticsTextEditingStrategy` omitted the default
composition event registration and did not synchronize a framework-provided
composing range into the existing composition tracker.

The fix is preserved as an exact-revision
[source patch](../diagnostics/flutter-web-composition-sdk/flutter-3.47.0-semantic-composition.patch)
and a [rebuild procedure](../diagnostics/flutter-web-composition-sdk/README.md).
The machine-readable [result](2026-09-07-flutter-web-composition-fix.json)
contains the source, patch, compiler-log and artifact identities.

## Red evidence

Three engine regressions were added before the complete fix:

| Contract | Expected | Stock result |
| --- | --- | --- |
| Active `compositionupdate` + `input` | composing `[0,1]` for `你` | `[-1,-1]` |
| Strategy teardown | cleared composition tracker | stale `active` text |
| Framework state + DOM selection feedback | composing `[0,2]` for `中文` | `[-1,-1]` |

The first red log has SHA-256
`f41ee46047e1ac70a5cc94863906f901f003292aa481b7c45a548e3434a00b53`.
The complete two-failure red log has SHA-256
`defd76d1e9876db6bdf0df41e5af0eea2080c0c7615d021dec36a23765f802ae`.

A separate Catalog control then applied the patched Dart source without
rebuilding the cached Web SDK. It retained the original failure: text `中文` and
caret `[2,2]` survived, while composing `[0,2]` became `[-1,-1]`. Chrome's
network record identified the served file as the old
`flutter_web_sdk/kernel/ddcLibraryBundle-canvaskit/dart_sdk.js`. This control
established that source editing alone does not alter a Flutter application
build.

## Green evidence

The final engine patch passed all **26/26** semantic text-field tests under both
Chrome Dart2JS and Chrome Dart2Wasm. The respective run-log hashes are
`ea3c277d9af976bc31abc152d2ed517a0c9555134c81ff461b417548687ec6a9` and
`a23b23050aa0292df6c59b7bbc15646667c938c57563d7f92f640f1363e99050`.

The repository rebuild script was then run against a second fresh detached
Flutter worktree at framework revision `4cf24164269a5ebf0c16a028a00727d0e77bbb05`
with a clean copy of the stock SDK cache. It verified all three source preimages,
applied the patch, rebuilt seven Web SDK files, atomically installed them, and
reported `passed`.

The normal Catalog acceptance runner used that rebuilt SDK with the exact
Chrome for Testing and ChromeDriver pair **152.0.7977.75**. Run
`8da0274d41de465c926617b041a9d208` passed both independent suites:

- framework input: **5/5 scenarios**, including the unchanged composing Enter,
  committed Enter, Shift+Enter and resize-preservation assertions;
- W3C browser input: **26/26 stages**, including pointer/key delivery, browser
  clipboard round-trips, read-only edit rejection and actual 599/600/1023/1024
  window boundaries;
- both Flutter and WebDriver process groups reported verified cleanup, and no
  ChromeDriver, test Chrome, frontend server or Flutter tool process remained.

Catalog release builds also completed with the rebuilt Dart2JS and Dart2Wasm
platform artifacts.

## Acceptance boundary

No Catalog assertion, timeout or input count was weakened. The framework result
proves Flutter editing-state composition survives the semantic Web strategy.
The W3C result proves the existing real browser input contract still passes.
The framework composing value is injected by Flutter, and the W3C CJK text is
Unicode insertion. These runs do not establish a real operating-system IME
candidate lifecycle or screen-reader behavior.

The browser CI workflow now rebuilds the exact patched SDK before Chrome, Edge,
Firefox and Safari framework input. Each browser still runs its independent W3C
suite, and Safari still runs the original complete journey. Their current-source
cross-browser result must come from the source-bound workflow run; this local
Chrome result does not pre-label those remote jobs as passed.
