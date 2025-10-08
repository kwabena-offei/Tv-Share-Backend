# frozen_string_literal: true

# Reads required environment keys from env.example and raises if any are missing
example_path = Rails.root.join('env.example')
required_keys = if File.exist?(example_path)
  File.read(example_path).lines.map(&:strip).reject do |line|
    line.empty? || line.start_with?('#')
  end.map { |line| line.split('=').first }
else
  []
end

missing = required_keys.reject { |key| ENV[key].present? }
if missing.any?
  raise "Missing required environment variables: #{missing.join(', ')}"
end
