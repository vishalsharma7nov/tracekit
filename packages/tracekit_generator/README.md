# tracekit_generator

Optional compile-time caller injection for TraceKit (Phase 5).

Use [CallerInfo.here()] at call sites today, or rely on automatic stack-based
capture via `CallerInfoConfig`.

Future releases will add `build_runner` codegen for zero-overhead file:line
injection.
