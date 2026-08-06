# Publishing PhysKit 0.1.0

Run the full validation from the repository root:

```sh
scripts/test-package.sh
```

Then build both release archives:

```sh
scripts/build-release.sh
```

The archives are written to `build/`.

## Test as a local package

The package can be installed under the `local` namespace before submission.

### Linux

```sh
destination="${XDG_DATA_HOME:-$HOME/.local/share}/typst/packages/local/physkit/0.1.0"
mkdir -p "$destination"
unzip physkit-package-0.1.0.zip -d "$destination"
```

### macOS

```sh
destination="$HOME/Library/Application Support/typst/packages/local/physkit/0.1.0"
mkdir -p "$destination"
unzip physkit-package-0.1.0.zip -d "$destination"
```

## Submit to Typst Universe

Public packages are submitted through a pull request to
[`typst/packages`](https://github.com/typst/packages). Extract the Universe
archive at the repository root of your fork, commit it, and open a pull request
against `typst/packages:main`.

The destination must be:

```text
packages/preview/physkit/0.1.0/
```

Published versions are immutable. Corrections should be released under a new
SemVer version.
