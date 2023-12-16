#!/usr/bin/env bash

# Converts conferences JSON file into a nice markdown

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
data=$(jq '.' "$script_dir/../resources/data.json" | jq '.data')
readarray -t years < <(printf '%s' "$data" | jq -r 'keys_unsorted.[]')

out+=(
    "# Conference Calendar"
    "This site lists interesting tech conferences throughout the year(s) including most important related information."
    "## Contribution"
    "If you want to contribute, please fork the repo and create a pull request from \`main\` to your branch. I will review your changes and merge them."
)

function gen_pricing_for_conference {
    local name
    local currency
    local value

    if [ "${#prices_json[@]}" -gt 0 ]; then
        for price_json in "${prices_json[@]}"; do
            name=$(printf '%s' "${price_json[@]}" | jq -r '.name')
            currency=$(printf '%s' "${price_json[@]}" | jq -r '.currency')
            value=$(printf '%s' "${price_json[@]}" | jq -r '.value')
            value=00$value # avoid bad length error
            value=$(printf '%.2f\n' "${value::-2}.${value: -2}")
            prices+=(
                "<li>$value $currency - $name</li>"
            )
        done
        pricing="<ul>$(printf '%s' "${prices[@]}")</ul>"
    else
        pricing="n/a"
    fi

    printf '%s' "$pricing"
}

for year in "${years[@]}"; do
    readarray -t conferences_json < <(printf '%s' "$data" | jq -c ".\"$year\".[]")
    out+=(
        "## $year"
    )

    for conference_json in "${conferences_json[@]}"; do
        name=$(printf '%s' "${conference_json[@]}" | jq -r '.name')
        url=$(printf '%s' "${conference_json[@]}" | jq -r '.url')
        twitter=$(printf '%s' "${conference_json[@]}" | jq -r '.twitter')
        [ "$twitter" != null ] && twitter="([@$twitter](https://x.com/$twitter))" || twitter=""
        out+=("### [$name]($url) $twitter")

        description=$(printf '%s' "${conference_json[@]}" | jq -r '.description')
        out+=("$description")


        dates=$(printf '%s' "${conference_json[@]}" | jq -r '.dates')
        location=$(printf '%s' "${conference_json[@]}" | jq -r '.location')

        export prices_json
        readarray -t prices_json < <(printf '%s' "${conference_json[@]}" | jq -c '.pricing.[]')
        pricing=$(gen_pricing_for_conference)

        out+=(
            "<table>"
            "<tr>"
            "<th>Dates</th> <th>Location</th> <th>Pricing</th>"
            "</tr>"
            "<tr>"
            "<td>$dates</td> <td>$location</td> <td>$pricing</td>"
            "</tr>"
            "</table>"
        )
    done
done

printf '%s\n\n' "${out[@]}" > "index.md"
