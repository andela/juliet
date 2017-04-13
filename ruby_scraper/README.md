# juliet
A collection of web scraping scripts

## Websites
- [Greenhouse](https://www.greenhouse.io/)
- [Lever](https://www.lever.co/)
- [Workable](https://workable.com)
- [Smartrecruiters](https://smartrecruiters.com)
- [Jobvite](https://jobvite.com)

## Setup && Usage
```
git clone 
bundle install        # install deps
rake scraper:jobs     # run scraper for all search terms (see
lib/tasks/scraper.rake)
```
[Mac OS X Setup Guide](http://sourabhbajaj.com/mac-setup/index.html)

## ENV Vars
We use the [figaro gem](https://github.com/laserlemon/figaro) to hide secrets

Update `config/application.yml` with:

- `sheet_id                  # Google Spreadsheet ID`
- `google_api_key            # Google Search Key (rate limited)`
- `google_custom_search_id   # Google Custom Search Paid Key (rate limited :( )`
- `bing_api_key              # BING Search API Key (rate limited) `

### Google Spreadsheet ID
![Google Sheet ID](screenshot.png)

### Google API Key
[Google Custom Search Console](https://cse.google.com/cse/all)
(Request access from @pauldariye)

### Bing Key
[Bind Data Search API](http://datamarket.azure.com/dataset/bing/search)

The columns in row 1 in screenshot above also shows the data that is collected for all the scraps.
[Guide to scraping Greenhouse](https://docs.google.com/document/d/1MavkX0pHW6hHySt0jjDRHxrC6y9P9wp2XMMG9gTj6eA/edit#heading=h.i8azkbec9zxk)

## Output

[View Scraped Job
Listings](https://docs.google.com/spreadsheets/d/1978FEQGZx1J4FicWa3YJMeHe66uMpNZCK_jMY2uzj_s/edit#gid=0)
