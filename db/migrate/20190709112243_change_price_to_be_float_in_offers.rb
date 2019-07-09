class ChangePriceToBeFloatInOffers < ActiveRecord::Migration[5.2]
  def change
    change_column :offers, :price, :float
  end
end
