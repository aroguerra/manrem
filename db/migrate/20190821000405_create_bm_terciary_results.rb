class CreateBmTerciaryResults < ActiveRecord::Migration[5.2]
  def change
    create_table :bm_terciary_results do |t|
      t.string :bm_agent_name
      t.string :bm_unit_name
      t.integer :period
      t.float :down_traded
      t.float :energy_down
      t.float :energy_down_price
      t.float :market_price_down
      t.float :up_traded
      t.float :energy_up
      t.float :energy_up_price
      t.float :market_price_up
      t.float :total_energy_down
      t.float :total_energy_up
      t.float :ter_need_down
      t.float :ter_need_up
      t.float :sec_need_down
      t.float :sec_need_up
      t.references :simulation, foreign_key: true

      t.timestamps
    end
  end
end
