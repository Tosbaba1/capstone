require "openai"

class OpenAiService
  MODEL = "gpt-3.5-turbo"

  def initialize(client: OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY")))
    @client = client
  end

  def chat(messages)
    api_response = @client.chat(
      parameters: {
        model: MODEL,
        messages: messages
      }
    )
    api_response.dig("choices", 0, "message", "content")
  end
end
