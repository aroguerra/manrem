class ChangeTypeToCategory < ActiveRecord::Migration[5.2]
  def change
    rename_column :agents, :type, :category

  end
end
