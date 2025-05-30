class OpenAiService
  CHAT_ENDPOINT = "https://api.openai.com/v1/chat/completions"
  MODEL = "gpt-3.5-turbo"

  def initialize(api_key: ENV["OPEN_AI_KEY"])
    @api_key = api_key
  end

  def chat(messages)
    response = HTTP.headers(
      "Authorization" => "Bearer #{@api_key}",
      "Content-Type" => "application/json"
    ).post(CHAT_ENDPOINT, json: { model: MODEL, messages: messages })
    JSON.parse(response.body.to_s).dig("choices", 0, "message", "content")
  end
end
