class AddNameToBmUnits < ActiveRecord::Migration[5.2]
  def change
     add_column :bm_units, :name, :string
  end
end
