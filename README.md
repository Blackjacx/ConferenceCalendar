# Conference Calendar

This repository stores interesting tech conferences throughout the year(s).

## Details

The details of each conference are stored in a [JSON file](https://github.com/Blackjacx/ConferenceCalendar/blob/main/resources/data.json). 

This data is converted to a markdown file using a [shell script](https://github.com/Blackjacx/ConferenceCalendar/blob/main/source/gen-markdown.sh) which is currently executed manually before deployment.

When changes are pushed to the `main` branch, [GitHub Actions](https://github.com/Blackjacx/ConferenceCalendar/actions) deploys this markdown file to [GitHub Pages](https://blackjacx.github.io/ConferenceCalendar).

## Deployment

To deploy the website the following steps have to be taken on the branch of the current year (referred to as `<year-branch>`):

- check that the LICENSE file date is up to date
- Run `./source/gen-markdown.sh` to update the markdown file
- Commit all changes on `<year-branch>`
- Rebase `main` on `<year-branch>`
- Push both branches
- Post the following on social media

```
Finally a new update of the #ConferenceCalendar, listing most important mobile development conferences focussing on Apple platforms for 2025:

https://blackjacx.github.io/ConferenceCalendar

The conferences get updated on a monthly basis since many of them did not yet announce dates and/or prices.

#iOS #Swift #conference
```

## Contribution

- If you found a **bug**, please open an **issue**.
- If you have a **feature request**, please open an **issue**.
- If you want to **contribute**, please fork the repo and create a pull request from `main` to your branch.

## Author

🐦 [@Blackjacxxx](https://x.com/Blackjacxxx)

## Contributors

Thanks to all of you who are part of this:

<a href="https://github.com/blackjacx/ConferenceCalendar/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=blackjacx/ConferenceCalendar" />
</a>

## License

ConferenceCalendar is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Star History

<a href="https://star-history.com/#blackjacx/conferencecalendar&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=blackjacx/conferencecalendar&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=blackjacx/conferencecalendar&type=Date" />
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=blackjacx/conferencecalendar&type=Date" />
  </picture>
</a>
