class ChangeTradedPowerToBeFloatInResults < ActiveRecord::Migration[5.2]
  def change
     change_column :results, :traded_power, :float
  end
end
