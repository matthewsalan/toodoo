class CreateAddTimestampsToTodoLists < ActiveRecord::Migration
  def self.up
    add_column :timestamps
  end

  def self.down
    remove_column :timestamps
  end
end