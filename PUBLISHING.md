# Publishing TraceKit

## Prerequisites

1. Google account linked at https://pub.dev
2. GitHub repository created at https://github.com/vishalsharma7nov/tracekit
3. All tests passing locally
4. `dart pub global activate pana`

## Pre-publish checklist

- [ ] `dart analyze` clean in each package
- [ ] `dart test` / `flutter test` passing
- [ ] `dart pub global run pana packages/tracekit` scores 120+ points
- [ ] CHANGELOG.md updated per package
- [ ] README has install, quickstart, and platform table
- [ ] All public APIs have `///` dartdoc

## Publish order

```bash
cd packages/tracekit && dart pub publish
cd ../tracekit_flutter && dart pub publish
cd ../tracekit_dio && dart pub publish
cd ../tracekit_http && dart pub publish
cd ../tracekit_bloc && dart pub publish
cd ../tracekit_riverpod && dart pub publish
```

Run `dart pub publish --dry-run` first in each package.

## Automated publishing (GitHub Actions)

On each package admin page at pub.dev, enable GitHub Actions publishing:

| Package | Tag pattern |
|---------|-------------|
| `tracekit` | `tracekit-v{{version}}` |
| `tracekit_flutter` | `tracekit_flutter-v{{version}}` |
| `tracekit_dio` | `tracekit_dio-v{{version}}` |
| `tracekit_http` | `tracekit_http-v{{version}}` |
| `tracekit_bloc` | `tracekit_bloc-v{{version}}` |
| `tracekit_riverpod` | `tracekit_riverpod-v{{version}}` |
| `tracekit_lints` | `tracekit_lints-v{{version}}` |
| `tracekit_generator` | `tracekit_generator-v{{version}}` |

Repository for all packages: `vishalsharma7nov/tracekit`

Then bump the version in `pubspec.yaml` + `CHANGELOG.md`, commit, and:

```bash
git tag tracekit-v0.1.1
git push origin tracekit-v0.1.1
```

The workflow in `.github/workflows/publish.yml` publishes the matching package.

## Verify package name

Search https://pub.dev/packages?q=tracekit before first publish. If taken, use
`fluxtrace` or `inktrace` as documented in the plan.
