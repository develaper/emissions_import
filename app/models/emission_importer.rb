require 'csv'

class EmissionImporter
  # Creates a new Emission record in the db
  # for each row of the csv in the file_path.
  # params: file_path, String
  #
  def import_from_csv(file_path)
    CSV.foreach(Rails.root.to_s + file_path, headers: true, converters: :numeric) do |row|
      row_data = row.to_hash.transform_keys! { |key| key.to_s.downcase }
      values_by_year = row_data.select { |key, value| numeric?(key) }
      Emission.create(country: row_data["country"], sector: row_data["sector"], parent_sector: row_data["parent ector"], values_by_year: values_by_year)
    end
  end

  private
  # Checks if word is numeric
  # params: word, String
  #
  def numeric?(word)
    Float(word) != nil rescue false
  end
end
