class AddHourToBmTerciaryNeeds < ActiveRecord::Migration[5.2]
  def change
    add_column :bm_terciary_needs, :hour, :integer
  end
end
