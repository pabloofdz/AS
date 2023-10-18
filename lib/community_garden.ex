# Use the Plot struct as it is provided
defmodule Plot do
  @enforce_keys [:plot_id, :registered_to]
  defstruct [:plot_id, :registered_to]
end

defmodule CommunityGarden do
  def start(opts \\ []) do
    Agent.start(fn -> {0, []} end, opts)
  end     

  def list_registrations(pid) do
    Agent.get(pid, fn {_, plots} -> plots end)
  end

  def register(pid, register_to) do
    Agent.get_and_update(pid, fn {id, plots} ->
      plot = %Plot{plot_id: id + 1, registered_to: register_to}
      {plot, {id + 1, [plot | plots]}}
    end)
  end

  def release(pid, plot_id) do
    Agent.update(pid, fn {id, plots} -> {id, Enum.reject(plots, fn plot -> plot.plot_id == plot_id end)} end)
    :ok
  end

  def get_registration(pid, plot_id) do
    plot = Agent.get(pid, fn {_, plots} -> Enum.find(plots, fn plot -> plot.plot_id == plot_id end) end)
    if plot == nil do
      {:not_found, "plot is unregistered"}
    else
      plot
    end
  end
end
