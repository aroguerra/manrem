class RemoveHourFromBmTerciaryNeeds < ActiveRecord::Migration[5.2]
  def change
    remove_column :bm_terciary_needs, :hour
  end
end
