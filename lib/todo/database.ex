defmodule Todo.Database do
  use GenServer

  def start_link(db_folder) do
    IO.puts "Starting to-do database"
    GenServer.start_link(__MODULE__, db_folder, name: :database_server)
  end

  def store(key, data) do
    GenServer.cast(:database_server, {:store, key, data})
  end

  def get(key) do
    GenServer.call(:database_server, {:get, key})
  end


  def init(db_folder) do
    File.mkdir_p(db_folder)
    workers = Enum.reduce(0..2, %{}, fn(idx, acc) ->
      {:ok, worker} =  Todo.DatabaseWorker.start_link(db_folder)
      Map.put(acc, idx, worker) 
    end)
    {:ok, workers}
  end

  def handle_cast({:store, key, data}, workers) do
    worker = get_worker(workers, key)
    Todo.DatabaseWorker.store(worker, key, data)
    {:noreply, workers}
  end

  def handle_call({:get, key}, caller, workers) do
    worker = get_worker(workers, key)
    Todo.DatabaseWorker.get(worker, key, caller)
    {:noreply, workers}
  end

  # Needed for testing purposes
  def handle_info(:stop, state), do: {:stop, :normal, state}
  def handle_info(_, state), do: {:noreply, state}

  defp get_worker(workers, file_name), do: workers[:erlang.phash2(file_name, 3)]
end