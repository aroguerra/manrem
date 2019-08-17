class CreateBmTerciaryDayAheadPrices < ActiveRecord::Migration[5.2]
  def change
    create_table :bm_terciary_day_ahead_prices do |t|
      t.integer :period
      t.float :price
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
