require 'test_helper'

class ImportLiveGuideJobTest < ActiveJob::TestCase
  setup do
    # Freeze the time for consistent testing
    Timecop.freeze('2020-06-30T20:00:00-04:00')
  end

  teardown do
    # Unfreeze the time after the test runs
    Timecop.return
  end

  test 'new shows are imported from the live guide' do
    # Testing that new shows are added
    VCR.use_cassette("gracenote_live_guide") do
      assert_difference('Show.count', 1268) do
        ImportLiveGuideJob.perform_now
      end
    end

    # Testing that existing shows aren't re-added
    VCR.use_cassette("gracenote_live_guide") do
      assert_no_difference('Show.count') do
        ImportLiveGuideJob.perform_now
      end
    end
  end

  test 'raises an exception if API key is not found' do
    # temporarily nullify TMS_API_KEY to simulate a missing API key
    original_api_key = ENV['TMS_API_KEY']
    ENV['TMS_API_KEY'] = nil

    exception = assert_raises RuntimeError do
      ImportLiveGuideJob.perform_now
    end

    assert_equal 'TMS_API_KEY not found, can not import live guide', exception.message

    # Reassign TMS_API_KEY
    ENV['TMS_API_KEY'] = original_api_key
  end
end
