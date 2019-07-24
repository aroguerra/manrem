class CreateBmSecondaryNeeds < ActiveRecord::Migration[5.2]
  def change
    create_table :bm_secondary_needs do |t|
      t.float :prevision
      t.integer :period
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
