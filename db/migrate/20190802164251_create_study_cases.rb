class CreateStudyCases < ActiveRecord::Migration[5.2]
  def change
    create_table :study_cases do |t|
      t.string :name
      t.string :author
      t.string :content
      t.string :excel_url

      t.timestamps
    end
  end
end
