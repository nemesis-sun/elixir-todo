defmodule Todo.Cache do
  use GenServer

  def start_link do
    IO.puts "Starting to-do cache"
    GenServer.start_link(Todo.Cache, nil, name: :todo_cache)
  end

  def server_process(server_name) do
    GenServer.call(:todo_cache, {:server_process, server_name})
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:server_process, server_name}, _, todo_servers) do
    {todo_server, new_todo_servers} = if Map.has_key?(todo_servers, server_name) do
      {todo_servers[server_name], todo_servers}
    else
      {:ok, new_todo_server} = Todo.Server.start_link(server_name)
      new_todo_servers = Map.put(todo_servers, server_name, new_todo_server)
      {new_todo_server, new_todo_servers}
    end

    {:reply, todo_server, new_todo_servers}
  end
end