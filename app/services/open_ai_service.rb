require "openai"

class OpenAiService
  MODEL = "gpt-3.5-turbo"

  def initialize(client: nil)
    api_key = ENV["OPENAI_API_KEY"]
    raise "OPENAI_API_KEY environment variable is missing" if api_key.nil? || api_key.strip.empty?

    client ||= OpenAI::Client.new(access_token: api_key)
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
