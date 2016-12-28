defmodule Todo.DatabaseWorker do

  def start_link(db_folder) do
    IO.puts "Starting to-do database worker"
    GenServer.start_link(__MODULE__, db_folder)
  end

  def store(worker, list_name, list_data) do
    GenServer.cast(worker, {:store, list_name, list_data})
  end

  def get(worker, list_name, caller) do
    GenServer.cast(worker, {:get, list_name, caller})
  end
  
  def init(db_folder) do
    {:ok, db_folder}
  end

  def handle_cast({:store, list_name, list_data}, db_folder) do
    file_name(db_folder, list_name)
    |> File.write!(:erlang.term_to_binary(list_data))

    {:noreply, db_folder}
  end

  def handle_cast({:get, list_name, caller}, db_folder) do
    data = case File.read(file_name(db_folder, list_name)) do
      {:ok, contents} -> :erlang.binary_to_term(contents)
      _ -> nil
    end

    GenServer.reply(caller, data)
    {:noreply, db_folder}
  end

  defp file_name(db_folder, key), do: "#{db_folder}/#{key}"
end