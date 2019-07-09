class CreateResults < ActiveRecord::Migration[5.2]
  def change
    create_table :results do |t|
      t.integer :period
      t.integer :power
      t.integer :traded_power
      t.integer :price
      t.integer :market_price
      t.references :simulation, foreign_key: true
      #t.references :agent, foreign_key: true

      t.timestamps
    end
  end
end
