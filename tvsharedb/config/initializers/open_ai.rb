OpenAI.configure do |config|
  config.access_token = ENV['OPEN_AI_API_KEY']
  config.request_timeout = 240 # seconds
  config.organization_id = ENV['OPEN_AI_ORGANIZATION_ID'] # Returns nil if not set
end
