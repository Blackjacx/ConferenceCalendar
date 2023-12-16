#!/usr/bin/env bash

# Convert conferences JSON file into a nice markdown

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
data=$(jq '.' "$script_dir/../resources/data.json" | jq '.data')
readarray -t years < <(printf '%s' "$data" | jq -r 'keys_unsorted.[]')

out+=(
    "# Conference Calendar"
    "This site lists interesting tech conferences throughout the year(s) including most important related information."
    "## Contribution"
    "If you want to contribute, please fork the repo and create a pull request from `main` to your branch. I will review your changes and merge them."
)

for year in "${years[@]}"; do
    out+=(
        "## $year"
        "| Name | Twitter | Dates | Location | Pricing | Description |"
        "|------|---|-------|----------|---------|-------------|"
    )
    readarray -t conferences_json < <(printf '%s' "$data" | jq -c ".\"$year\".[]")
    for conference_json in "${conferences_json[@]}"; do
        name=$(printf '%s' "${conference_json[@]}" | jq -r '.name')
        url=$(printf '%s' "${conference_json[@]}" | jq -r '.url')

        twitter=$(printf '%s' "${conference_json[@]}" | jq -r '.twitter')
        twitter=$([ "$twitter" != "null" ] && echo "[🐦]($twitter)")

        dates=$(printf '%s' "${conference_json[@]}" | jq -r '.dates')
        location=$(printf '%s' "${conference_json[@]}" | jq -r '.location')
        description=$(printf '%s' "${conference_json[@]}" | jq -r '.description')

        pricing=$(printf '%s' "${conference_json[@]}" | jq -c '.pricing')
        pricing=$([ "$pricing" != "null" ] && echo "\`$pricing\`")

        out+=(
            "| [$name]($url) | $twitter | $dates | $location | $pricing | $description |"
        )
    done
done

printf '%s\n' "${out[@]}" > "index.md"

# tmp_file=$(mktemp)
# printf '%s\n' "${out[@]}" >> "$tmp_file"
# macdown "$tmp_file"
# rm -rf "$tmp_file"
