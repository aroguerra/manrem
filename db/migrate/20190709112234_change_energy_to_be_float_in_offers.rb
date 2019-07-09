class ChangeEnergyToBeFloatInOffers < ActiveRecord::Migration[5.2]
  def change
     change_column :offers, :energy, :float
  end
end
