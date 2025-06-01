require 'test_helper'

class LineupCacheTest < ActiveSupport::TestCase
  test 'raises an error when TMS_API_KEY is missing' do
    original_key = ENV['TMS_API_KEY']
    ENV['TMS_API_KEY'] = nil

    error = assert_raises RuntimeError do
      LineupCache.new
    end

    assert_equal 'TMS_API_KEY not set', error.message
  ensure
    ENV['TMS_API_KEY'] = original_key
  end
end
