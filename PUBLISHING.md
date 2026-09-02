# Publishing TraceKit

## Prerequisites

1. Google account linked at https://pub.dev
2. GitHub repository created at https://github.com/tracekit/tracekit
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

## GitHub release

```bash
git tag tracekit-v1.0.0
git push origin tracekit-v1.0.0
```

Create a GitHub Release with notes from CHANGELOG.md.

## Verify package name

Search https://pub.dev/packages?q=tracekit before first publish. If taken, use
`fluxtrace` or `inktrace` as documented in the plan.
