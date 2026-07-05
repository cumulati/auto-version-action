# auto-version-action

A GitHub Action that derives a version string and related git metadata from the
repository's tag history, and exposes them as step outputs. Useful for tagging
build artifacts, container images, and releases without hand-maintaining a
version number.

Under the hood it runs [`entrypoint.sh`](./entrypoint.sh), which shells out to
`git describe`, `git rev-parse`, and `git shortlog`.

## Outputs

Accessed via `steps.<id>.outputs.<name>`.

| Output     | Source                                    | Example                          | Notes                                                                   |
| ---------- | ----------------------------------------- | -------------------------------- | ----------------------------------------------------------------------- |
| `version`  | `VERSION` env, else `tag`, then sanitized | `v1.3`, `feature-x`              | Also written to `version.txt` in the workspace.                         |
| `tag`      | `git describe --tags --always`            | `v1.3-2-gabc1234`                | Nearest tag found; falls back to short SHA if untagged, then `unknown`. |
| `shortsha` | `git rev-parse --short HEAD`              | `abc1234`                        | Falls back to `unknown`.                                                |
| `shortlog` | `git shortlog <last-tag>..HEAD -e`        | multi-line author/commit summary | Commits since the most recent tag.                                      |

## Usage

```yaml
jobs:
    build:
        runs-on: ubuntu-latest
        steps:
            # Required: full history + tags. `git describe --tags` needs them,
            # so a shallow checkout (the default) will not work.
            - uses: actions/checkout@v4
              with:
                  fetch-depth: 0

            - id: version
              uses: twopow/auto-version-action@v1

            - run: |
                  echo "version:  ${{ steps.version.outputs.version }}"
                  echo "shortsha: ${{ steps.version.outputs.shortsha }}"
                  echo "tag:      ${{ steps.version.outputs.tag }}"
                  echo "shortlog:"
                  echo "${{ steps.version.outputs.shortlog }}"
```

> **Pin the version.** `@v1` is a floating tag that tracks the latest `v1.x`
> release. Pin to an exact tag (e.g. `@v1.3`) or a commit SHA for reproducible
> builds.

### Overriding the version

Use the `VERSION` **environment variable** to override the version.
If set, its value is used as the version (after sanitization) instead of the git tag:

```yaml
- id: version
  uses: twopow/auto-version-action@v1
  env:
      VERSION: ${{ github.ref_name }}
```

### Side effects

- Writes the computed version to `version.txt` in the workspace root.

## Requirements

- Check out with `fetch-depth: 0` so tags and full history are available;
  otherwise `git describe --tags` cannot find a tag and outputs degrade to the
  short SHA or `unknown`.

## Development

To float the `v1` release tag to a specific existing tag:

```bash
just float-v1-release-tag v1.X
```

where `v1.X` is a tag that already exists. See the [`justfile`](./justfile) for
details.
