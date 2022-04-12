defmodule TelegramService do
  @group_id "-699588211"

  def send_message(msg) do
	token = Application.fetch_env!(:gpu_price_tracker, :telegram_token)
	Telegram.Api.request(token, "sendMessage", chat_id: @group_id, text: msg)
  end
end
