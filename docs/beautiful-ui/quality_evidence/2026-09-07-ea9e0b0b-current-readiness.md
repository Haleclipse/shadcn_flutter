# Current automated readiness at ea9e0b0b — 2026-09-07

The final source-bound
[main workflow](https://github.com/pawaovo/shadcn_flutter/actions/runs/34089350151)
passed **12/12 jobs**. This includes format/analyze/package tests, Web JS/Wasm,
Android/Windows/Linux/Apple builds, hosted-consumer validation, Chrome/Edge/
Firefox/Linux/Windows/macOS/iOS journeys, and the Android original P1/P2/P3
journey with three native LatinIME candidate commits.

The independent
[Android candidate workflow](https://github.com/pawaovo/shadcn_flutter/actions/runs/34089362118)
also passed at the exact same source. It completed the original journey with one
native tap each for `inventory`, `rest`, and `restock`. All three calls drained,
all three helper processes and forwards were retired, the driver reported
`all_tests_passed=true`, and overall cleanup was verified. The compact
[JSON record](2026-09-07-ea9e0b0b-current-readiness.json) binds the original
summary, driver summary and complete artifact-manifest hashes.

The
[input and AT workflow](https://github.com/pawaovo/shadcn_flutter/actions/runs/34089350075)
passed **8/9 jobs**:

- Chrome, Edge, Firefox and Safari each passed the rebuilt-SDK five-scenario
  framework suite and the independent W3C browser suite; Safari also passed the
  original complete journey in the same job.
- Linux, macOS and Windows native input bridges passed.
- The real Linux Orca capability probe passed.
- The Windows Narrator capability probe failed because the runner exposed no
  render audio endpoint and its owned Narrator window had no safe minimization
  pattern. It retained `application_acceptance=not_accepted`.

The workflow therefore has a red overall conclusion from Narrator capability,
while its eight independent successful jobs remain valid. No Narrator or human
screen-reader support is inferred.

## Additional automatic work

The macOS all-15 Profile harness was repeated at the immediately preceding
runtime source `67515beb`. All 15 workloads, finalization, source integrity and
trace transport completed, but the unchanged engineering budget failed Diff
Table's 1% over-interval fraction and Records Table's two-interval maximum. The
[failed repeatability record](performance/2026-09-07-67515beb-repeatability-failure.md)
is preserved and was not retried.

The passive macOS IME observer was also replayed with the selected WeType Pinyin
source. Automated `n`/`i` key events reached the DOM as trusted plain
`insertText`, with no composition lifecycle. The
[automation-boundary record](2026-09-07-automated-macos-ime-boundary.md) keeps
that result unaccepted as real Chinese IME evidence.

Current local device discovery found only this Mac and Chrome. `adb`, Flutter
and Xcode reported no connected Android phone, iPhone or iPad, and the USB
inventory contained no mobile device. Physical-device smoke tests cannot run
until a device is connected, unlocked and trusted.

All six platforms therefore remain **Partial**, and all 27 registry entries
remain `in_progress`. The remaining release layers require external state or a
product decision: physical mobile devices, a real Chinese candidate/pre-edit
session, human VoiceOver/TalkBack/Narrator review, stable repeated performance,
and approval or replacement of the current engineering-only budget.
