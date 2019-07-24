class CreateBmUnitOffers < ActiveRecord::Migration[5.2]
  def change
    create_table :bm_unit_offers do |t|
      t.float :price
      t.float :energy
      t.integer :period
      t.references :bm_unit, foreign_key: true

      t.timestamps
    end
  end
end
