class CreateTodoItems < ActiveRecord::Migration
	def self.up 
		create_table :todo_items do |t|
			t.integer :todo_list_id
			t.string :task
			t.datetime :due_date
			t.boolean :completed, default: false 
		end
	end

	def self.down
		drop_tabel :todo_items
	end
end

