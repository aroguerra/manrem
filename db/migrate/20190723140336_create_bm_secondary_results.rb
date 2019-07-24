class CreateBmSecondaryResults < ActiveRecord::Migration[5.2]
  def change
    create_table :bm_secondary_results do |t|
      t.string :bm_agent_name
      t.string :bm_unit_name
      t.integer :period
      t.float :power
      t.float :down_traded
      t.float :power_down
      t.float :up_traded
      t.float :power_up
      t.float :price
      t.float :market_price
      t.float :system_down_needs
      t.float :system_up_needs
      t.references :simulation, foreign_key: true

      t.timestamps
    end
  end
end
