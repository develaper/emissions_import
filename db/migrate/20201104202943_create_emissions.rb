class CreateEmissions < ActiveRecord::Migration[6.0]
  def change
    create_table :emissions, id: :uuid do |t|
      t.string :country, null: false
      t.string :sector
      t.string :parent_sector
      t.json :values_by_year, default: {}

      t.timestamps
    end
  end
end
