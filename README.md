# ReviewScraper

Fetches reviews from DealerRater.com, and sorts by the most posivitive reviews.

The criteria chosen to sort was:

- Recommended the dealer: Filters only reviews that have recommended the dealer.
- Average rating: sum of all the ratings divided by 5.
- Occurrences of overly positive words: given a set of overly positive words,
  the occurrence of those words is counted.

## Installation

- Clone the repo: `git clone https://github.com/andrhevictor/review_scraper.git`
- Install its dependencies: `cd review_scraper && mix deps.get`
- Run the test suite: `mix test`
- Test it on the playground: `iex -S mix`

After on Elixir's Interactive shell, type:

```elixir
ReviewScraper.get_overly_positive_reviews("McKaig")
```

It should return the 3 most positive reviews.

You can also tweak the results passing custom options:

- `:pages_to_fetch`: Number of pages to be fetched from DealerRater.com.
- `:reviews_count`: Number of reviews to be returned.

```elixir
options = [pages_to_fetch: 3, reviews_count: 10]

ReviewScraper.get_overly_positive_reviews("McKaig", options)
```
