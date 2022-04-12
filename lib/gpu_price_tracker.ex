defmodule GpuPriceTracker do

  @base_url "https://api.twitter.com/2/"
  @endpoint "tweets/search/recent?"

  def main do
	getTweets()

	results = getTweets()

	send_results(results)
	update_last_id(results)

  end

  def getTweets do
	max_results = Application.fetch_env!(:gpu_price_tracker, :max_results)
	user = Application.fetch_env!(:gpu_price_tracker, :user)
	keyword = Application.fetch_env!(:gpu_price_tracker, :keyword)
	token = Application.fetch_env!(:gpu_price_tracker, :twitter_token)
	
	query = "query=from:#{user}%20#{keyword}"

	params = "&tweet.fields=created_at&max_results=#{max_results}"

	url = Enum.join [@base_url, @endpoint, query, params]

	headers = [{"Authorization", "Bearer #{token}"},
			   {"Accept", "Application/json; Charset=utf-8"}]

	{:ok, response} = HTTPoison.get(url, headers, [])

	#req = Poison.decode!(response.body)

	#data = req["data"]
	
	#data |> Enum.reverse

	Poison.decode!(response.body) |> Map.get("data") |> Enum.reverse
  end

  def send_results(ordered_list) do
	{:ok, last_id} = File.read("product.txt")
	
	ordered_list
	|> Enum.filter(fn item -> compare(item, last_id) end)
	|> Enum.each(fn i -> print_text(i) end)
  end

  def update_last_id(ordered_list) do
	new_last_id =
	  ordered_list |> List.last |> Map.get("id")

	IO.puts "NEW Last id: #{new_last_id}\n"

	File.write("product.txt", new_last_id)
  end

  def print_text(item) do
	text = String.replace(item["text"], "\n\n", "\n")

	{_, created_at, _} = String.replace(item["created_at"], "Z", "+03:00") |> DateTime.from_iso8601

	formated = Calendar.strftime(created_at, "%d/%m/%y %H:%M:%S")
	
	header = formated <> "  ---------------------------------------------------\n"
	content = text <> "\n"

	TelegramService.send_message(header <> content)
  end

  def compare(item, last_id) do

	item_value = item["id"]
	last_id_value = last_id

	#IO.puts "Item value: #{item_value}"
	#IO.puts "Last id value: #{last_id_value}"

	item_value > last_id_value
  end
end

