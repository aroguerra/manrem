class ChangePowerToBeFloatInResults < ActiveRecord::Migration[5.2]
  def change
    change_column :results, :power, :float
  end
end
