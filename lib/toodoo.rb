require "toodoo/version"
require "toodoo/init_db"
require 'highline/import'
require 'pry'

module Toodoo
  class User < ActiveRecord::Base
    has_many :todo_lists  
  end

  class TodoList < ActiveRecord::Base
    belongs_to :user
    has_many :todo_items
  end

  class TodoItem < ActiveRecord::Base
    belongs_to :todo_list
  end
end

class TooDooApp
  def initialize
    @user = nil
    @todos = nil
    @show_done = nil
  end

  def new_user
    say("Creating a new user:")
    name = ask("Username?") { |q| q.validate = /\A\w+\Z/ }
    @user = Toodoo::User.create(:name => name)
    say("We've created your account and logged you in. Thanks #{@user.name}!")
  end

  def login
    choose do |menu|
      menu.prompt = "Please choose an account: "

      Toodoo::User.find_each do |u|
        menu.choice(u.name, "Login as #{u.name}.") { @user = u }
      end

      menu.choice(:back, "Just kidding, back to main menu!") do
        say "You got it!"
        @user = nil
      end
    end
  end

  def delete_user
    choices = 'yn'
    delete = ask("Are you *sure* you want to stop using TooDoo?") do |q|
      q.validate =/\A[#{choices}]\Z/
      q.character = true
      q.confirm = true
    end
    if delete == 'y'
      @user.destroy
      @user = nil
    end
  end

  def new_todo_list
    say("Creating a new todo list:")
    title = ask("List name?") { |q| q.validate = /\A\w+\Z/ }
    @todos = Toodoo::TodoList.create(:title => title, :user_id => @user.id)
    say("Thanks #{@user.name}, your new list is ready!")
  end

  def pick_todo_list
    choose do |menu|
      menu.prompt = "Choose a list: "
        Toodoo::TodoList.where(:user_id => @user.id).find_each do |l|
          menu.choice(l.title, "Choose the #{l.title}. todo list") {@todos = l}
      end
      menu.choice(:back, "Back to the main menu!") do
        say "You got it!"
        @todos = nil
      end
    end
  end

  def delete_todo_list
    choose do |menu|
      menu.prompt = "Choose a list to delete: "
        Toodoo::TodoList.where(:user_id => @user.id).find_each do |l|
          menu.choice(l.title, "Choose the #{l.title}. todo list") {@todos = l}
      end
    end
    choices = 'yn'
    delete = ask("Are you sure you want to delete the todo list?") do |q|
      q.validate=/\A[#{choices}]\Z/
      q.character = true
      q.confirm = true
    end
    if delete == 'y'
      @todos.destroy
    end
    @todos = nil
  end

  def new_task
    say("Creating a new task: ")
    input = ask("Task name?") 
    Toodoo::TodoItem.create(:name => input, :todo_list_id => @todos.id)  
  end

  ## NOTE: For the next 3 methods, make sure the change is saved to the database.
  def mark_done
    choose do |menu|
      menu.prompt = "What task is completed? "
      Toodoo::TodoItem.where(:todo_list_id => @todos.id, :completed => false).each do |t|
        menu.choice(t.name, "Choose the #{t.name} task" ) {t.update(:completed => true)}
        t.save
      end
      menu.choice(:back)
    end
  end

  #def change_due_date
    # TODO: This should display the todos on the current list in a menu
    # similarly to pick_todo_list. Once they select a todo, the menu choice block
    # should update the due date for the todo. You probably want to use
    # `ask("foo", Date)` here.
  #end

  def edit_task
    # TODO: This should display the todos on the current list in a menu
    # similarly to pick_todo_list. Once they select a todo, the menu choice block
    # should change the name of the todo.
  end

  def show_overdue
    # TODO: This should print a sorted list of todos with a due date *older*
    # than `Date.now`. They should be formatted as follows:
    # "Date -- Eat a Cookie"
    # "Older Date -- Play with Puppies"
  end

  def run
    puts "Welcome to your personal TooDoo app."
    loop do
      choose do |menu|
        #menu.layout = :menu_only
        #menu.shell = true

        # Are we logged in yet?
        unless @user
          menu.choice("Create a new user.", :new_user) { new_user }
          menu.choice("Login with an existing account.", :login) { login }
        end

        # We're logged in. Do we have a todo list to work on?
        if @user && !@todos
          menu.choice("Delete the current user account.", :delete_account) { delete_user }
          menu.choice("Create a new todo list.", :new_list) { new_todo_list }
          menu.choice("Work on an existing list.", :pick_list) { pick_todo_list }
          menu.choice("Delete a todo list.", :remove_list) { delete_todo_list }
        end

        # Let's work on some todos!
        if @todos
          menu.choice("Add a new task.", :new_task) { new_task }
          menu.choice("Mark a task finished.", :mark_done) { mark_done }
          menu.choice("Change a task's due date.", :move_date) { change_due_date }
          menu.choice("Update a task's description.", :edit_task) { edit_task }
          menu.choice("Toggle display of tasks you've finished.", :show_done) { @show_done = !!@show_done }
          menu.choice("Show a list of task's that are overdue, oldest first.", :show_overdue) { show_overdue }
          menu.choice("Go work on another Toodoo list!", :back) do
            say "You got it!"
            @todos = nil
          end
        end

        menu.choice("Quit!", :quit) { exit }
      end
    end
  end
end



todos = TooDooApp.new
todos.run
