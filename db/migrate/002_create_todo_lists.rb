class CreateTodoLists < ActiveRecord::Migration
	def self.up
		create_table :todo_lists do |t|
			t.integer :user_id
			t.string :title
		end
	end

	def self.down
		drop_table :todo_lists
	end
end


