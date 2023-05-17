require 'openai'

class ChatGpt
  def initialize
    @client = OpenAI::Client.new
  end

  def chat(message)
    response = @client.chat(
      parameters: {
        model: 'gpt-3.5-turbo',
        messages: [{ role: 'user', content: message }],
        temperature: 0.7
      }
    )

    response.dig('choices', 0, 'message', 'content')
  end
end
