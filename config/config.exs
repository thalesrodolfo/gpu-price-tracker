import Config

config :gpu_price_tracker,
  twitter_token: System.get_env("TWITTER_TOKEN"),
  telegram_token: System.get_env("TELEGRAM_TOKEN")
