defmodule PeriodicJob do
  use GenServer
  require Logger

  @period 60_000 # 1 minute

  def start() do
	Logger.info("Starting...")
	GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
	execute_fetch()

	{:ok, state}
  end

  def handle_info(:fetch_price, state) do
	Logger.info("Fetching...")
	GpuPriceTracker.main

	execute_fetch()

	{:noreply, state}
  end

  def execute_fetch() do
	Logger.info("Waiting...")
	Process.send_after(self(), :fetch_price, @period * 8)
  end
end
