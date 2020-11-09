require 'test_helper'
require 'csv'

class FileValidatorTest < ActiveSupport::TestCase
  def setup
  end
  #happy path
  #
  test "valid path" do
    path_to_file = ENV['csv_folder_path'] + ENV['file_name']
    assert_equal Rails.root.to_s + path_to_file, FileValidator.new(path_to_file).path
  end
  # not so happy path
  # none existing file
  #
  test "raise exxception if file dont exist" do
    path_to_file = ENV['csv_folder_path'] + "bad.csv"
    assert_raises(FileValidator::PathException) { FileValidator.new(path_to_file).path }
  end
  # none csv file
  test "raise exxception if file is not a csv" do
    path_to_file = ENV['csv_folder_path'] + "bad.txt"
    assert_raises(FileValidator::ExtensionException) { FileValidator.new(path_to_file).path }
  end
end
