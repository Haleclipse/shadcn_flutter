#!/usr/bin/env python3
"""Patch and rebuild Flutter 3.47's Web SDK composition support.

This script deliberately mutates the SDK passed through --flutter. CI uses a
disposable SDK. Local callers should pass an isolated copy or worktree, never a
shared Flutter installation.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import subprocess
import tempfile
from datetime import datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
PATCH = (
    ROOT
    / "docs/beautiful-ui/diagnostics/flutter-web-composition-sdk"
    / "flutter-3.47.0-semantic-composition.patch"
)
FRAMEWORK_VERSION = "3.47.0"
FRAMEWORK_REVISION = "4cf24164269a5ebf0c16a028a00727d0e77bbb05"
DART_VERSION = "3.13.0"

ENGINE_SOURCE = Path(
    "engine/src/flutter/lib/web_ui/lib/src/engine/semantics/text_field.dart"
)
ENGINE_TEST = Path(
    "engine/src/flutter/lib/web_ui/test/engine/semantics/text_field_test.dart"
)
CACHE_SOURCE = Path(
    "bin/cache/flutter_web_sdk/lib/_engine/engine/semantics/text_field.dart"
)

EXPECTED_SOURCE_HASHES = {
    ENGINE_SOURCE: (
        "02648f4dcf353ac2031d2bb5b3a12ff6d60cd9219b21885282a39983f8c9f815",
        "6e09d5dfcdbecc78b3ac741375ca35d7df69c71a66d9ac4f9a637b0f56df1862",
    ),
    ENGINE_TEST: (
        "e7391a64b4bbe2afd3a6f120c80613d768c1fd436b2d7e2e0ffadeea661ba1bb",
        "1fdbe899803e0960713fc8bc74adba0a2221ae7f62c8553ff4ae5d5e4c2e2510",
    ),
    CACHE_SOURCE: (
        "560248596a0ea39f197bd327dce65940f705abe166f5301634f8f15d6f46699b",
        "edec15f4499c1bff1ad4f5a2e15f0625fef4045b3a486901f66ca3997af0eae2",
    ),
}

CACHE_REPLACEMENTS = (
    (
        "    subscriptions.clear();\n"
        "    lastEditingState = null;",
        "    subscriptions.clear();\n"
        "    removeCompositionEventHandlers(activeDomElement);\n"
        "    composingText = null;\n"
        "    composingBase = null;\n"
        "    lastEditingState = null;",
    ),
    (
        "    subscriptions.add(\n"
        "      DomSubscription(domDocument, 'selectionchange', createDomEventListener(handleChange)),\n"
        "    );\n"
        "    preventDefaultForMouseEvents();",
        "    subscriptions.add(\n"
        "      DomSubscription(domDocument, 'selectionchange', createDomEventListener(handleChange)),\n"
        "    );\n"
        "    addCompositionEventHandlers(activeDomElement);\n"
        "    preventDefaultForMouseEvents();",
    ),
    (
        "  @override\n"
        "  void placeElement() {",
        "  @override\n"
        "  void setEditingState(EditingState? editingState) {\n"
        "    if (editingState != null &&\n"
        "        editingState.composingBaseOffset >= 0 &&\n"
        "        editingState.composingExtentOffset > editingState.composingBaseOffset &&\n"
        "        editingState.composingExtentOffset <= editingState.text.length) {\n"
        "      composingBase = editingState.composingBaseOffset;\n"
        "      composingText = editingState.text.substring(\n"
        "        editingState.composingBaseOffset,\n"
        "        editingState.composingExtentOffset,\n"
        "      );\n"
        "    } else {\n"
        "      composingBase = null;\n"
        "      composingText = null;\n"
        "    }\n"
        "    super.setEditingState(editingState);\n"
        "  }\n\n"
        "  @override\n"
        "  void placeElement() {",
    ),
)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def record(path: Path) -> dict[str, object]:
    return {"path": str(path), "bytes": path.stat().st_size, "sha256": sha256(path)}


def run(command: list[str], log: Path, *, cwd: Path | None = None) -> None:
    with log.open("a", encoding="utf-8") as output:
        output.write(json.dumps(command) + "\n")
        output.flush()
        subprocess.run(command, cwd=cwd, stdout=output, stderr=subprocess.STDOUT, check=True)


def patch_sources(sdk: Path, log: Path) -> str:
    source_hashes = {relative: sha256(sdk / relative) for relative in (ENGINE_SOURCE, ENGINE_TEST)}
    original = all(
        source_hashes[relative] == EXPECTED_SOURCE_HASHES[relative][0]
        for relative in source_hashes
    )
    patched = all(
        source_hashes[relative] == EXPECTED_SOURCE_HASHES[relative][1]
        for relative in source_hashes
    )
    if original:
        run(["git", "apply", "--check", str(PATCH)], log, cwd=sdk)
        run(["git", "apply", str(PATCH)], log, cwd=sdk)
        state = "applied"
    elif patched:
        state = "already_applied"
    else:
        raise RuntimeError(
            "Flutter engine source is neither the exact stock input nor the exact reviewed patch"
        )

    for relative in (ENGINE_SOURCE, ENGINE_TEST):
        actual = sha256(sdk / relative)
        expected = EXPECTED_SOURCE_HASHES[relative][1]
        if actual != expected:
            raise RuntimeError(f"Patched source hash mismatch for {relative}: {actual}")
    return state


def patch_cached_source(sdk: Path) -> str:
    target = sdk / CACHE_SOURCE
    current = sha256(target)
    original, patched = EXPECTED_SOURCE_HASHES[CACHE_SOURCE]
    if current == patched:
        return "already_applied"
    if current != original:
        raise RuntimeError(
            "Cached Web engine source is neither the exact stock input nor the exact reviewed patch"
        )
    contents = target.read_text(encoding="utf-8")
    for before, after in CACHE_REPLACEMENTS:
        if contents.count(before) != 1:
            raise RuntimeError("Cached Web engine patch preimage is not unique")
        contents = contents.replace(before, after)
    target.write_text(contents, encoding="utf-8")
    if sha256(target) != patched:
        raise RuntimeError("Cached Web engine source did not produce the reviewed patched hash")
    return "applied"


def compile_web_sdk(
    sdk: Path,
    package_config: Path,
    log: Path,
) -> tuple[list[tuple[Path, Path]], Path]:
    cache = sdk / "bin/cache"
    dart_sdk = cache / "dart-sdk"
    executable_suffix = ".exe" if os.name == "nt" else ""
    dartaotruntime = dart_sdk / "bin" / f"dartaotruntime{executable_suffix}"
    snapshots = dart_sdk / "bin/snapshots"
    kernel_worker = snapshots / "kernel_worker_aot.dart.snapshot"
    dartdevc = snapshots / "dartdevc_aot.dart.snapshot"
    web_sdk = cache / "flutter_web_sdk"
    libraries = "org-dartlang-sdk:///libraries.json"
    roots = [
        "--multi-root-scheme",
        "org-dartlang-sdk",
        "--multi-root",
        web_sdk.as_uri(),
        "--multi-root",
        cache.as_uri(),
    ]
    sources = [
        "--source",
        "dart:core",
        "--source",
        "dart:ui",
        "--source",
        "dart:ui_web",
        "--source",
        "dart:_engine",
    ]

    staging_root = Path(tempfile.mkdtemp(prefix="flutter-web-sdk-build-"))
    outputs: list[tuple[Path, Path]] = []

    kernel_specs = (
        (
            "ddc_outline.dill",
            ["--summary-only", "--include-unsupported-platform-library-stubs", "--target", "ddc"],
            "dart:_skwasm_stub",
        ),
        (
            "dart2js_platform.dill",
            ["--no-summary-only", "--null-environment", "--target", "dart2js"],
            "dart:_skwasm_stub",
        ),
        (
            "dart2wasm_platform.dill",
            ["--no-summary-only", "--null-environment", "--target", "dart2wasm"],
            "dart:_skwasm_impl",
        ),
    )
    for filename, target_args, skwasm_library in kernel_specs:
        staged = staging_root / filename
        command = [
            str(dartaotruntime),
            str(kernel_worker),
            *target_args,
            "--packages-file",
            package_config.as_uri(),
            *roots,
            "--libraries-file",
            libraries,
            "--output",
            str(staged),
            *sources,
            "--source",
            skwasm_library,
            "--source",
            "dart:_web_locale_keymap",
        ]
        run(command, log)
        outputs.append((staged, web_sdk / "kernel" / filename))

    ddc_specs = (
        ("amd-canvaskit", "amd", False),
        ("ddcLibraryBundle-canvaskit", "ddc", True),
    )
    for directory, module_format, canary in ddc_specs:
        stage_directory = staging_root / directory
        stage_directory.mkdir()
        staged = stage_directory / "dart_sdk.js"
        command = [
            str(dartaotruntime),
            str(dartdevc),
            "--compile-sdk",
            "dart:core",
            "dart:ui",
            "dart:ui_web",
            "dart:_engine",
            "dart:_skwasm_stub",
            "dart:_web_locale_keymap",
            "--no-summarize",
            "--packages",
            package_config.as_uri(),
            *roots,
            "--multi-root-output-path",
            str(cache),
            "--libraries-file",
            libraries,
            "--inline-source-map",
            "-DFLUTTER_WEB_USE_SKIA=true",
            "--modules",
            module_format,
            "-o",
            str(staged),
        ]
        if canary:
            command.insert(-2, "--canary")
        run(command, log)
        destination = web_sdk / "kernel" / directory / "dart_sdk.js"
        outputs.extend(((staged, destination), (Path(f"{staged}.map"), Path(f"{destination}.map"))))

    return outputs, staging_root


def install_outputs(outputs: list[tuple[Path, Path]]) -> None:
    for staged, destination in outputs:
        if not staged.is_file() or staged.stat().st_size == 0:
            raise RuntimeError(f"Compiler did not produce a nonempty artifact: {staged}")
        temporary = destination.with_name(f".{destination.name}.composition-patch.tmp")
        shutil.copy2(staged, temporary)
        os.replace(temporary, destination)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--flutter", type=Path, required=True)
    parser.add_argument("--package-config", type=Path, required=True)
    parser.add_argument("--evidence", type=Path, required=True)
    args = parser.parse_args()

    flutter = args.flutter.resolve()
    sdk = flutter.parent.parent
    package_config = args.package_config.resolve()
    evidence = args.evidence.resolve()
    evidence.mkdir(parents=True, exist_ok=False)
    log = evidence / "build.log"
    manifest: dict[str, object] = {
        "schema_version": 1,
        "status": "started",
        "started_at_utc": datetime.now(timezone.utc).isoformat(),
        "sdk_mutation_boundary": "The explicitly supplied Flutter SDK is modified in place.",
        "flutter": str(flutter),
        "sdk": str(sdk),
        "package_config": str(package_config),
        "patch": record(PATCH),
    }
    manifest_path = evidence / "manifest.json"
    try:
        version = json.loads(subprocess.check_output([str(flutter), "--version", "--machine"]))
        manifest["version"] = version
        if version.get("frameworkVersion") != FRAMEWORK_VERSION:
            raise RuntimeError(f"Expected Flutter {FRAMEWORK_VERSION}")
        if version.get("frameworkRevision") != FRAMEWORK_REVISION:
            raise RuntimeError(f"Expected Flutter revision {FRAMEWORK_REVISION}")
        if not str(version.get("dartSdkVersion", "")).startswith(DART_VERSION):
            raise RuntimeError(f"Expected Dart {DART_VERSION}")
        if not package_config.is_file():
            raise RuntimeError(f"Package config does not exist: {package_config}")

        tracked = [sdk / ENGINE_SOURCE, sdk / ENGINE_TEST, sdk / CACHE_SOURCE]
        manifest["sources_before"] = [record(path) for path in tracked]
        manifest["engine_patch_state"] = patch_sources(sdk, log)
        manifest["cache_patch_state"] = patch_cached_source(sdk)
        manifest["sources_after"] = [record(path) for path in tracked]

        destinations = [
            sdk / "bin/cache/flutter_web_sdk/kernel/ddc_outline.dill",
            sdk / "bin/cache/flutter_web_sdk/kernel/dart2js_platform.dill",
            sdk / "bin/cache/flutter_web_sdk/kernel/dart2wasm_platform.dill",
            sdk / "bin/cache/flutter_web_sdk/kernel/amd-canvaskit/dart_sdk.js",
            sdk / "bin/cache/flutter_web_sdk/kernel/amd-canvaskit/dart_sdk.js.map",
            sdk / "bin/cache/flutter_web_sdk/kernel/ddcLibraryBundle-canvaskit/dart_sdk.js",
            sdk / "bin/cache/flutter_web_sdk/kernel/ddcLibraryBundle-canvaskit/dart_sdk.js.map",
        ]
        manifest["artifacts_before"] = [record(path) for path in destinations]
        outputs, staging_root = compile_web_sdk(sdk, package_config, log)
        try:
            install_outputs(outputs)
        finally:
            shutil.rmtree(staging_root)
        manifest["artifacts_after"] = [record(path) for path in destinations]
        manifest["status"] = "passed"
        manifest["completed_at_utc"] = datetime.now(timezone.utc).isoformat()
    except Exception as error:
        manifest["status"] = "failed"
        manifest["error"] = str(error)
        raise
    finally:
        manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
