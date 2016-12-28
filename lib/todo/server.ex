defmodule Todo.Server do
  use GenServer

  def start_link(todo_list_name) do
    IO.puts "Starting to-do server"
    GenServer.start_link(Todo.Server, todo_list_name)
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  def delete_entry(todo_server, id) do
    GenServer.cast(todo_server, {:delete_entry, id})
  end

  def update_entry(todo_server, entry) do
    GenServer.cast(todo_server, {:update_entry, entry})
  end


  def init(todo_list_name) do
    {:ok, {todo_list_name, Todo.Database.get(todo_list_name) || Todo.List.new }}
  end

  def handle_cast({:add_entry, new_entry}, {list_name, todo_list}) do
    new_list = Todo.List.add_entry(todo_list, new_entry)
    store_todo_list(list_name, new_list)
    {:noreply, {list_name, new_list}}
  end

  def handle_cast({:delete_entry, id}, {list_name, todo_list}) do
    new_list = Todo.List.delete_entry(todo_list, id)
    store_todo_list(list_name, new_list)
    {:noreply, {list_name, new_list}}
  end

  def handle_cast({:update_entry, entry}, {list_name, todo_list}) do
    new_list = Todo.List.update_entry(todo_list, entry)
    store_todo_list(list_name, new_list)
    {:noreply, {list_name, new_list}}
  end

  def handle_call({:entries, date}, _, {_, todo_list} = state) do
    {
      :reply,
      Todo.List.entries(todo_list, date),
      state
    }
  end

  defp store_todo_list(list_name, todo_list) do
    Todo.Database.store(list_name, todo_list)
  end
end