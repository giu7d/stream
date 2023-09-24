defmodule StreamCore.LiveStreamMonitor do
  use GenServer

  def monitor(module, params) do
    {:global, __MODULE__}
    |> GenServer.whereis()
    |> GenServer.call({:monitor, module, params})
  end

  def demonitor() do
    {:global, __MODULE__}
    |> GenServer.whereis()
    |> GenServer.call(:demonitor)
  end

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: {:global, __MODULE__})
  end

  @impl true
  def init(_), do: {:ok, %{views: %{}}}

  @impl true
  def handle_call(
        {:monitor, module, params},
        {pid, _ref},
        %{views: views} = state
      ) do
    process_ref = Process.monitor(pid)
    new_state = %{state | views: Map.put(views, pid, {module, params, process_ref})}
    {:reply, :ok, new_state}
  end

  def handle_call(:demonitor, {pid, _ref}, state) do
    {{_, _, process_ref}, views} = Map.pop(state.views, pid)
    :erlang.demonitor(process_ref)
    new_state = %{state | views: views}
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, reason}, state) do
    state.views
    |> Map.pop(pid)
    |> case do
      {{module, params, _view_ref}, new_views} ->
        Task.async(fn -> module.unmount(reason, params) end)
        {:noreply, %{state | views: new_views}}

      _ ->
        {:noreply, state}
    end
  end

  def handle_info(_, state), do: {:noreply, state}
end
