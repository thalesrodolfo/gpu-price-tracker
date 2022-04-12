import Config

config :gpu_price_tracker,
  ecto_repos: [GpuPriceTracker.Repo],
  max_results: "10",
  user: "gpubipolar",
  keyword: "Menor",
  twitter_token: System.get_env("TWITTER_TOKEN"),
  telegram_token: System.get_env("TELEGRAM_TOKEN")

config :gpu_price_tracker, GpuPriceTracker.Repo,
  database: "./database.db"
