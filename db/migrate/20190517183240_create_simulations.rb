class CreateSimulations < ActiveRecord::Migration[5.2]
  def change
    create_table :simulations do |t|
      t.datetime :date
      t.string :market_type
      t.string :pricing_mechanism
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
