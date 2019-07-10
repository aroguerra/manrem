class AddAgentNameToResults < ActiveRecord::Migration[5.2]
  def change
    add_column :results, :agent_name, :string
  end
end
