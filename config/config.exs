import Config

config :review_scraper, dealer_rater_base_url: "https://www.dealerrater.com"

config :tesla, adapter: Tesla.Adapter.Hackney

import_config "#{Mix.env()}.exs"
