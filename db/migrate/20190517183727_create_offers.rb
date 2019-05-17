class CreateOffers < ActiveRecord::Migration[5.2]
  def change
    create_table :offers do |t|
      t.integer :energy
      t.integer :price
      t.integer :period
      t.references :agent, foreign_key: true

      t.timestamps
    end
  end
end
