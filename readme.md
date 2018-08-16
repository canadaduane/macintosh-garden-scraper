# Web Scraper for Macintosh Garden

## What is this?

This scrapes the http://macintoshgarden.org wiki and turns entries there into machine-readable json format.

## What's the output look like?

Here's an example:

```
[
  {
    "title": "A Brief History of Time",
    "url": "http://macintoshgarden.org/games/a-brief-history-of-time",
    "short_desc": "A BRIEF HISTORY OF TIME",
    "rating": 3.6,
    "rating_votes": 0,
    "categories": [
      "Educational"
    ],
    "perspective": [
      "1st Person"
    ],
    "year_released": 1994,
    "author": [
      "Creative technology Ltd."
    ]
  },
  # ...
]
```

## Do I have to run the script myself?

Not necessarily. I was interested in the `games` section of the garden, so I've downloaded and stored the [macintosh-games.json](macintosh-games.json) file in this repository. If you're interested in another section of the garden, you'll need to download, configure, and run the ruby script.

## How do I configure and run the script?

Using a recent version of ruby (e.g. `2.5.1`) and bundler, run the following commands:

```
bundle install
bundle exec ruby scraper.rb
```

If you'd like to configure the script to scrape a different part of the website, edit the `scraper.rb` file and point it at a different url (e.g. `http://macintoshgarden.org/apps`)

## License

MIT

