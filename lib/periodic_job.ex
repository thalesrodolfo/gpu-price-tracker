defmodule PeriodicJob do
  use GenServer

  @period 60_000 # 1 minute

  def start_link(_args) do
	GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
	execute_fetch()

	{:ok, state}
  end

  def handle_info(:fetch_price, state) do
	IO.puts "fetching..."
	GpuPriceTracker.main

	execute_fetch()

	{:noreply, state}
  end

  def execute_fetch() do
	Process.send_after(self(), :fetch_price, @period * 15)
  end
end
