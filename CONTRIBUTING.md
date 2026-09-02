# Contributing to TraceKit

1. Fork the repository and create a feature branch.
2. Run `melos bootstrap` from the repo root.
3. Make changes and add tests.
4. Run `dart analyze` and `dart test` / `flutter test` in affected packages.
5. Update CHANGELOG.md for user-facing changes.
6. Open a pull request with a clear description.

## Commit messages

Use concise, imperative messages focused on why the change was made.

## Code style

- Follow `analysis_options.yaml` at the repo root.
- Add `///` dartdoc to all public APIs.
- Do not use `print`, `log`, or `debugPrint` — use TraceKit APIs.
