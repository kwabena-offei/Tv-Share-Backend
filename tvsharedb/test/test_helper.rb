ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'webmock'
require 'vcr'

# Records external HTTP requests for testing purposes
VCR.configure do |config|
  config.cassette_library_dir = "test/vcr_cassettes"
  config.hook_into :webmock
  # Prevents TMS_API_KEY from being saved in the recorded files
  config.filter_sensitive_data('<TMS_API_KEY>') { ENV['TMS_API_KEY'] }
end

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end
