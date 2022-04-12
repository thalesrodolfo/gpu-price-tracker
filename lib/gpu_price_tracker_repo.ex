defmodule GpuPriceTracker.Repo do
  use Ecto.Repo, otp_app: :gpu_price_tracker, adapter: Ecto.Adapters.SQLite3
end
