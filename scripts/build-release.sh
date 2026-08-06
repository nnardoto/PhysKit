#!/bin/sh
set -eu

project_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
package_version=$(sed -n 's/^version = "\([^"]*\)"/\1/p' "$project_root/typst.toml")

if [ -z "$package_version" ]; then
  echo "Could not read the package version from typst.toml" >&2
  exit 1
fi

"$project_root/scripts/test-package.sh"

release_tmp=$(mktemp -d)
trap 'rm -rf "$release_tmp"' EXIT HUP INT TERM

package_dir="$release_tmp/package"
universe_dir="$release_tmp/universe/packages/preview/physkit/$package_version"
build_dir="$project_root/build"
mkdir -p "$package_dir" "$universe_dir" "$build_dir"

copy_release_files() {
  destination=$1
  cp "$project_root/lib.typ" "$project_root/typst.toml" \
    "$project_root/LICENSE" "$project_root/README.md" \
    "$project_root/CHANGELOG.md" "$project_root/CONTRIBUTING.md" "$destination/"
  cp -R "$project_root/core" "$project_root/docs" "$project_root/examples" \
    "$project_root/geometry" "$project_root/mechanics" \
    "$project_root/primitives" "$project_root/vectors" "$destination/"
}

copy_release_files "$package_dir"
copy_release_files "$universe_dir"

package_archive="$build_dir/physkit-package-$package_version.zip"
universe_archive="$build_dir/physkit-universe-$package_version.zip"
rm -f "$package_archive" "$universe_archive"

(cd "$package_dir" && zip -qr "$package_archive" .)
(cd "$release_tmp/universe" && zip -qr "$universe_archive" packages)

echo "Created $package_archive"
echo "Created $universe_archive"
