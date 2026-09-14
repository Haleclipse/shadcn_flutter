# Automated macOS IME boundary — 2026-09-07

The existing passive live-input observer was replayed locally from its preserved
5edbcab7 Web build. The read-only input-source inventory reported the selected
source as `com.tencent.inputmethod.wetype.pinyin`. No input-source or other
system setting was changed.

After enabling Flutter Web semantics, CUA focused the empty stock
`EditableText` and issued separate `n` and `i` key presses. The observer showed:

- trusted `keydown`/`keyup` events for `KeyN` and `KeyI`;
- trusted `beforeinput` and `input` events with `inputType=insertText` and data
  `n`, then `i`;
- `isComposing=false` throughout;
- final stock text `ni`, selection `[2,2]`, Flutter composing `[-1,-1]`;
- no `compositionstart`, `compositionupdate` or `compositionend` event;
- unchanged editor state/controller identities and no Prompt submission.

The page visibly acknowledged an export request named
`live-os-ime-observed-2026-09-07T05-44-05.858Z.json`, but no resulting file was
available to the task filesystem. This record therefore summarizes the visible
observer state; it does not claim a preserved full trace.

These trusted browser events establish that the automated CUA key path reached
the real DOM input. They also establish that this automation path did not enter
the selected input method's candidate/pre-edit lifecycle. It cannot be used as
Chinese OS IME acceptance, and the absence of composition events does not imply
that WeType itself failed. The temporary in-app browser tab and localhost server
were closed after the observation.
