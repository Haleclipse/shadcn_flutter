# Native all-15 repeatability failure at 67515beb

A second native macOS Profile capture completed every workload, finalized with
driver exit 0, retained 16 consecutive checkpoints, and verified that all 318
listed source inputs stayed unchanged. The independent assessor then returned
`budget_fail`. This is a valid failed repeatability sample; it is not replaced
or retried.

The [machine-readable record](2026-09-07-67515beb-repeatability-failure.json)
summarizes 10,298 engine frames and 1,022 RSS samples. Raw evidence remains in
`/tmp/beautiful-native-all-67515beb-repeat-20260907` and is bound by hashes in
the record.

| Workload | Frames / RSS | Build p95 / max (ms) | Raster p95 / max (ms) | Build or raster over 8.333ms | RSS peak (MiB) | Result |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| `prompt_bar` | 895 / 83 | 1.347 / 4.194 | 1.691 / 4.659 | 0 / 895 | 209.297 | pass |
| `diff_table` | 492 / 53 | 3.566 / 14.107 | 2.139 / 4.313 | 6 / 492 (1.220%) | 246.391 | **fail** |
| `records_table` | 1,157 / 115 | 1.461 / 16.858 | 2.320 / 4.405 | 9 / 1,157 (0.778%) | 279.953 | **fail** |
| `sidebar_nav` | 729 / 66 | 1.061 / 2.520 | 1.649 / 2.775 | 0 / 729 | 280.719 | pass |
| `flowchart` | 464 / 58 | 4.243 / 5.768 | 3.058 / 8.029 | 0 / 464 | 308.609 | pass |
| `insight_cards` | 1,054 / 106 | 3.121 / 4.733 | 3.301 / 8.194 | 0 / 1,054 | 332.703 | pass |
| `selection_actions` | 303 / 38 | 3.928 / 5.720 | 1.891 / 3.283 | 0 / 303 | 315.859 | pass |
| `search_long_catalog` | 1,301 / 115 | 1.580 / 4.124 | 1.668 / 5.712 | 0 / 1,301 | 324.766 | pass |
| `code_block_long_source` | 732 / 81 | 0.639 / 3.249 | 3.157 / 6.608 | 0 / 732 | 442.500 | pass |
| `thinking_long_trace` | 619 / 58 | 0.759 / 2.214 | 1.928 / 3.516 | 0 / 619 | 399.266 | pass |
| `streaming_long_answer` | 775 / 69 | 4.973 / 6.852 | 2.828 / 4.469 | 0 / 775 | 409.984 | pass |
| `tool_chips_large_output` | 535 / 51 | 3.067 / 5.641 | 1.240 / 3.070 | 0 / 535 | 419.891 | pass |
| `chat_long_transcript` | 311 / 35 | 0.571 / 1.081 | 0.766 / 3.144 | 0 / 311 | 425.328 | pass |
| `filter_table_large_dataset` | 362 / 40 | 3.387 / 6.633 | 1.493 / 3.111 | 0 / 362 | 436.688 | pass |
| `task_rows_large_workflow` | 569 / 54 | 2.466 / 3.375 | 1.217 / 4.374 | 0 / 569 | 440.078 | pass |

Diff Table exceeded the unchanged maximum 1% build-or-raster over-interval
fraction: 6/492 is 1.2195%. Records Table's 16.858ms maximum build duration
exceeded the unchanged two-interval limit of 16.667ms. The latter workload's
over-interval fraction and all p95 gates still passed.

The highest sampled current RSS was 442.5MiB, below the 512MiB process gate.
The process-lifetime maximum reported at the last sample was about 482.8MiB.
All measured positive memory changes stayed below 64MiB. These are whole-process
samples and do not establish component allocation or absence of leaks.

The run used Flutter 3.47.0/Dart 3.13.0 on macOS 15.7.9, a 1728×1080 logical
native view at DPR 2 and 120Hz, resumed lifecycle, stable platform/framework
semantics, and `caffeinate -di`. The Start control was activated once; no GUI
interaction followed. Other desktop activity was not isolated, so this record
does not assign causality or support a direct performance regression claim.

The earlier [5edbcab7 all-15 pass](2026-09-04-5edbcab7-all-performance.md)
remains intact. Together, one pass and this failure show that repeat-run
stability has not been established. The engineering defaults remain
`engineering_default_not_product_approved`.
