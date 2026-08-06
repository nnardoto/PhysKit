#!/bin/sh
set -eu

project_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
package_version=$(sed -n 's/^version = "\([^"]*\)"/\1/p' "$project_root/typst.toml")
typst_bin=${TYPST_BIN:-typst}

if [ -z "$package_version" ]; then
  echo "Could not read the package version from typst.toml" >&2
  exit 1
fi

test_root=$(mktemp -d)
trap 'rm -rf "$test_root"' EXIT HUP INT TERM

package_dir="$test_root/packages/preview/physkit/$package_version"
output_dir="$test_root/output"
mkdir -p "$package_dir" "$output_dir"

cp "$project_root/lib.typ" "$project_root/typst.toml" \
  "$project_root/LICENSE" "$project_root/README.md" "$package_dir/"
cp -R "$project_root/core" "$project_root/geometry" \
  "$project_root/mechanics" "$project_root/primitives" \
  "$project_root/vectors" "$package_dir/"

for source_file in "$project_root"/tests/*.typ; do
  output_file="$output_dir/$(basename "${source_file%.typ}").pdf"
  "$typst_bin" compile --root "$project_root" "$source_file" "$output_file"
done

for source_file in "$project_root"/tests/fail/*.typ; do
  output_file="$output_dir/$(basename "${source_file%.typ}").pdf"
  if "$typst_bin" compile --root "$project_root" "$source_file" "$output_file" \
    >"$output_dir/expected-failure.log" 2>&1; then
    echo "Expected compilation to fail: $source_file" >&2
    exit 1
  fi
done

for source_file in "$project_root"/examples/*.typ "$project_root/docs/manual.typ"; do
  output_file="$output_dir/$(basename "${source_file%.typ}").pdf"
  "$typst_bin" compile --package-path "$test_root/packages" \
    --root "$project_root" "$source_file" "$output_file"
done

echo "PhysKit $package_version passed all compile checks."
