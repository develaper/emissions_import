require 'test_helper'

class EmissionsImporterJobTest < ActiveJob::TestCase
  test "enqueued job" do
    assert_enqueued_jobs 0
    EmissionsImporterJob.perform_later(ENV['csv_folder_path'] + ENV['file_name'])
    assert_enqueued_jobs 1
  end
end
