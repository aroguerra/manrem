class AddEnergyDownToBmUnitOffers < ActiveRecord::Migration[5.2]
  def change
    add_column :bm_unit_offers, :energy_down, :float
  end
end
