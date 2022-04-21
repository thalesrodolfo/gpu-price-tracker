defmodule GpuPriceTracker do
  require Logger

  @base_url "https://api.twitter.com/2/"
  @endpoint "tweets/search/recent?"


  def main do

	{tweets, users} =
	  getTweets("(from:gpubipolar OR from:pcbuildwizard) (\"Menor preço desde\" OR \"⭐⭐⭐⭐⭐\") -terabyte has:links", 20)

	send_results(tweets, users)
	update_last_id(tweets)
  end

  
  def getTweets(query, max_results \\ 10) do
	Logger.info("getTweets")
	
	query = "query=#{ URI.encode(query) }"

	params = "&tweet.fields=created_at&max_results=#{max_results}&expansions=author_id"

	url = Enum.join [@base_url, @endpoint, query, params]

	token = Application.fetch_env!(:gpu_price_tracker, :twitter_token)

	IO.puts "Twitter token: #{token}"

	headers = [{"Authorization", "Bearer #{token}"},
			   {"Accept", "Application/json; Charset=utf-8"}]

	{:ok, response} = HTTPoison.get(url, headers, [])

	IO.inspect response

	users = Poison.decode!(response.body)
	|> Map.get("includes")
	|> Map.get("users")
	
	tweets = Poison.decode!(response.body)
	|> Map.get("data")
	|> Enum.reverse

	{tweets, users}
  end

  
  def send_results(tweets, users) do
	{:ok, last_id} = File.read("product.txt")

	tweets
	|> Enum.filter(fn item -> item["id"] > last_id end)
	|> Enum.each(fn i -> print_text(i, users) end)

  end

  
  def update_last_id(ordered_list) do
	new_last_id =
	  ordered_list |> List.last |> Map.get("id")

	IO.puts "NEW Last id: #{new_last_id}\n"

	File.write("product.txt", new_last_id)	  
  end


  def print_text(item, users) do
	text = String.replace(item["text"], "\n\n", "\n")
	username = "@" <> get_username(users, item)

	{_, created_at, _} = String.replace(item["created_at"], "Z", "+03:00") |> DateTime.from_iso8601

	formated = Calendar.strftime(created_at, "%d/%m/%y %H:%M:%S")
	
	header = username <> " - " <> formated <> "\n\n"
	content = text <> "\n"

	IO.inspect (header <> content)

	TelegramService.send_message(header <> content)
  end


  def get_username(users, item) do
	users
	|> Enum.filter(fn user -> user["id"] == item["author_id"] end)
	|> List.first
	|> Map.get("username")
  end

end

