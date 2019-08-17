class CreateBmTerciaryNeeds < ActiveRecord::Migration[5.2]
  def change
    create_table :bm_terciary_needs do |t|
      t.string :hour
      t.float :down_band
      t.float :up_band
      t.float :forecast
      t.float :observed_production
      t.float :portugal_consumption
      t.float :balance_imp_exp
      t.float :day_ahead_power_pt
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
