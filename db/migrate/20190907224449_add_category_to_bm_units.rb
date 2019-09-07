class AddCategoryToBmUnits < ActiveRecord::Migration[5.2]
  def change
    add_column :bm_units, :market, :string
  end
end
