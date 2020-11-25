require 'csv'

class EmissionImporter
  class InvalidFileException < StandardError; end

  # Creates a new Emission record in the db
  # for each row of the csv in the file_path.
  # params: file_path, String.
  #
  def import_from_csv(file_path)
    begin
      file_path = FileValidator.new(file_path).path
    rescue FileValidator::FileValidatorException => e
      handle_invalid_file_exception(e)
    end
    CSV.foreach(file_path, headers: true, converters: :numeric) do |row|
      row_data = row.to_hash.transform_keys! { |key| key.to_s.downcase }
      values_by_year = row_data.select { |key, value| numeric?(key) }
      Emission.create(country: row_data["country"], sector: row_data["sector"], parent_sector: row_data["parent sector"], values_by_year: values_by_year)
    end
  end

  private
  # Checks if word is numeric.
  # params: word, String.
  #
  def numeric?(word)
    Float(word) != nil rescue false
  end
  # Loggs exception information.
  # Raises InvalidFileException.
  # params: e, error.
  #
  def handle_invalid_file_exception(e)
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.join("\n")
    raise EmissionImporter::InvalidFileException.new(e.message)
  end
end
