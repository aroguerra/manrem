class ChangePriceToBeFloatInResults < ActiveRecord::Migration[5.2]
  def change
     change_column :results, :price, :float
  end
end
