#!/bin/sh

set -eu

usage() {
  echo "Usage: $0 path/to/icudtl.dat" >&2
  exit 2
}

if [ "$#" -ne 1 ]; then
  usage
fi

input=$1
if [ ! -f "$input" ]; then
  echo "error: ICU data file not found: $input" >&2
  exit 1
fi

icupkg=${ICUPKG:-icupkg}
if ! command -v "$icupkg" >/dev/null 2>&1; then
  echo "error: icupkg not found; install the matching ICU version or set ICUPKG" >&2
  exit 1
fi

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(dirname "$script_dir")
destination="$repo_root/src/icudtl.dat"

work_dir=$(mktemp -d "${TMPDIR:-/tmp}/deno_core_icudata.XXXXXX")
cleanup() {
  case "$work_dir" in
    "${TMPDIR:-/tmp}"/deno_core_icudata.*) rm -rf -- "$work_dir" ;;
  esac
}
trap cleanup 0
trap 'exit 1' HUP INT TERM

items="$work_dir/items.txt"
remove="$work_dir/remove.txt"
output="$work_dir/icudtl.dat"
remove_pattern='\.cnv$|^cnvalias\.icu$|^uts46\.nrm$|^confusables\.cfu$'
remove_pattern="$remove_pattern|^translit/|^rbnf/|^nfkc_scf\\.nrm$"
remove_pattern="$remove_pattern|^ulayout\\.icu$|^currencyNumericCodes\\.res$"
remove_pattern="$remove_pattern|^genderList\\.res$|^windowsZones\\.res$"
remove_pattern="$remove_pattern|^icuver\\.res$|^icustd\\.res$"

"$icupkg" --ignore-deps --auto_toc_prefix -l -o "$items" "$input"
if ! grep -E "$remove_pattern" "$items" > "$remove"; then
  echo "error: no V8-unused ICU data found in $input" >&2
  exit 1
fi

"$icupkg" \
  --ignore-deps \
  --auto_toc_prefix \
  -r "$remove" \
  "$input" \
  "$output"

cp "$output" "$destination"

removed_count=$(wc -l < "$remove" | tr -d '[:space:]')
output_size=$(wc -c < "$destination" | tr -d '[:space:]')
echo "Removed $removed_count V8-unused items."
echo "Wrote $destination ($output_size bytes)."
