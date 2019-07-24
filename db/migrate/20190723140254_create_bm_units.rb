class CreateBmUnits < ActiveRecord::Migration[5.2]
  def change
    create_table :bm_units do |t|
      t.string :fuel
      t.string :category
      t.references :bm_agent, foreign_key: true

      t.timestamps
    end
  end
end
