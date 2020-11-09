require 'test_helper'
require 'csv'

class EmissionImporterTest < ActiveSupport::TestCase
  def setup
    @path_to_file = ENV['csv_folder_path'] + ENV['file_name']
    @full_path_to_file = Rails.root.to_s + @path_to_file
  end
  #happy path with a valid CSV
  #
  test "creates exact number of records for a valid csv" do
    arr_of_rows = CSV.read(@full_path_to_file, headers: true)

    assert_difference ("Emission.count"), arr_of_rows.count do
      EmissionImporter.new.import_from_csv(@path_to_file)
    end
  end
  # not so happy path
  # none existing file
  #
  test "raise exxception if file dont exist" do
    path_to_file = ENV['csv_folder_path'] + "bad.csv"
    assert_raises(EmissionImporter::InvalidFileException) { EmissionImporter.new.import_from_csv(path_to_file) }
  end

  # not valid file extension
  #
  test "raise exxception if the file extension is not csv" do
    path_to_file = ENV['csv_folder_path'] + "bad.txt"
    assert_raises(EmissionImporter::InvalidFileException) { EmissionImporter.new.import_from_csv(path_to_file) }
  end
end
