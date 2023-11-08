defmodule TakeANumberDeluxe do
  use GenServer

  # Client API
  @spec start_link(keyword()) :: {:ok, pid()} | {:error, atom()}
  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg)
  end

  @spec report_state(pid()) :: TakeANumberDeluxe.State.t()
  def report_state(machine) do
    GenServer.call(machine, :report_state)
  end

  @spec queue_new_number(pid()) :: {:ok, integer()} | {:error, atom()}
  def queue_new_number(machine) do
    GenServer.call(machine, :queue_new_number)
  end

  @spec serve_next_queued_number(pid(), integer() | nil) :: {:ok, integer()} | {:error, atom()}
  def serve_next_queued_number(machine, priority_number \\ nil) do
    GenServer.call(machine, {:serve_next_queued_number, priority_number})
  end

  @spec reset_state(pid()) :: :ok
  def reset_state(machine) do
    GenServer.cast(machine, :reset_state)
  end

  # Server callbacks
  @impl GenServer
  def init(init_arg) do
    min_number = Keyword.get(init_arg, :min_number)
    max_number = Keyword.get(init_arg, :max_number)
    auto_shutdown_timeout = Keyword.get(init_arg, :auto_shutdown_timeout, :infinity)
    case TakeANumberDeluxe.State.new(min_number, max_number, auto_shutdown_timeout) do
      {:ok, state} -> {:ok, state, auto_shutdown_timeout}
      {:error, error} -> {:stop, error}
    end
  end

  @impl GenServer
  def handle_call(:report_state, _, state), do: {:reply, state, state, state.auto_shutdown_timeout}

  @impl GenServer
  def handle_call(:queue_new_number, _, state) do
    case TakeANumberDeluxe.State.queue_new_number(state) do
      {:ok, new_number, new_state} -> {:reply, {:ok, new_number}, new_state, state.auto_shutdown_timeout}
      error -> {:reply, error, state, state.auto_shutdown_timeout}
    end
  end

  @impl GenServer
  def handle_call({:serve_next_queued_number, priority_number}, _, state) do
    case TakeANumberDeluxe.State.serve_next_queued_number(state, priority_number) do
      {:ok, new_number, new_state} -> {:reply, {:ok, new_number}, new_state, state.auto_shutdown_timeout}
      error -> {:reply, error, state, state.auto_shutdown_timeout}
    end
  end

  @impl GenServer
  def handle_cast(:reset_state, state) do
    min_number = state.min_number
    max_number = state.max_number
    auto_shutdown_timeout = state.auto_shutdown_timeout
    case TakeANumberDeluxe.State.new(min_number, max_number, auto_shutdown_timeout) do
      {:ok, new_state} -> {:noreply, new_state, auto_shutdown_timeout}
      _ -> {:noreply, state, auto_shutdown_timeout}
    end
  end

  @impl GenServer
  def handle_info(:timeout, state) do
    {:stop, :normal, state}
  end

  @impl GenServer
  def handle_info(_, state) do
    {:noreply, state, state.auto_shutdown_timeout}
  end
end





defmodule TakeANumberDeluxe.State do
  defstruct min_number: 1, max_number: 999, queue: nil, auto_shutdown_timeout: :infinity
  @type t :: %__MODULE__{}

  alias TakeANumberDeluxe.Queue

  @spec new(integer, integer, timeout) :: {:ok, TakeANumberDeluxe.State.t()} | {:error, atom()}
  def new(min_number, max_number, auto_shutdown_timeout \\ :infinity) do
    if min_and_max_numbers_valid?(min_number, max_number) and
         timeout_valid?(auto_shutdown_timeout) do
      {:ok,
       %__MODULE__{
         min_number: min_number,
         max_number: max_number,
         queue: Queue.new(),
         auto_shutdown_timeout: auto_shutdown_timeout
       }}
    else
      {:error, :invalid_configuration}
    end
  end

  @spec queue_new_number(TakeANumberDeluxe.State.t()) ::
          {:ok, integer(), TakeANumberDeluxe.State.t()} | {:error, atom()}
  def queue_new_number(%__MODULE__{} = state) do
    case find_next_available_number(state) do
      {:ok, next_available_number} ->
        {:ok, next_available_number,
         %{state | queue: Queue.push(state.queue, next_available_number)}}

      {:error, error} ->
        {:error, error}
    end
  end

  @spec serve_next_queued_number(TakeANumberDeluxe.State.t(), integer() | nil) ::
          {:ok, integer(), TakeANumberDeluxe.State.t()} | {:error, atom()}
  def serve_next_queued_number(%__MODULE__{} = state, priority_number) do
    cond do
      Queue.empty?(state.queue) ->
        {:error, :empty_queue}

      is_nil(priority_number) ->
        {{:value, next_number}, new_queue} = Queue.out(state.queue)
        {:ok, next_number, %{state | queue: new_queue}}

      Queue.member?(state.queue, priority_number) ->
        {:ok, priority_number, %{state | queue: Queue.delete(state.queue, priority_number)}}

      true ->
        {:error, :priority_number_not_found}
    end
  end

  defp min_and_max_numbers_valid?(min_number, max_number) do
    is_integer(min_number) and is_integer(max_number) and min_number < max_number
  end

  defp timeout_valid?(timeout) do
    timeout == :infinity || (is_integer(timeout) && timeout >= 0)
  end

  defp find_next_available_number(state) do
    all_numbers_in_use = Queue.to_list(state.queue)
    all_numbers = Enum.to_list(state.min_number..state.max_number)

    case all_numbers_in_use do
      [] ->
        {:ok, state.min_number}

      list when length(list) == length(all_numbers) ->
        {:error, :all_possible_numbers_are_in_use}

      _ ->
        current_highest_number = Enum.max(all_numbers_in_use)

        next_available_number =
          if current_highest_number < state.max_number do
            current_highest_number + 1
          else
            Enum.min(all_numbers -- all_numbers_in_use)
          end

        {:ok, next_available_number}
    end
  end
end





defmodule TakeANumberDeluxe.Queue do
  # You don't need to read this module to solve this exercise.

  # We would have used Erlang's queue module instead
  # (https://www.erlang.org/doc/man/queue.html),
  # but it lacks a `delete` function before OTP 24,
  # and we want this exercise to work on older versions too.

  defstruct in: [], out: []
  @type t :: %__MODULE__{}

  @spec new() :: t()
  def new(), do: %__MODULE__{}

  @spec push(t(), any()) :: t()
  def push(%__MODULE__{in: in_q} = q, a), do: %__MODULE__{q | in: [a | in_q]}

  @spec out(t()) :: {{:value, any()}, t()} | {:empty, t()}
  def out(%__MODULE__{in: [], out: []} = q), do: {:empty, q}
  def out(%__MODULE__{out: [head | tail]} = q), do: {{:value, head}, %__MODULE__{q | out: tail}}
  def out(%__MODULE__{in: in_q}), do: out(%__MODULE__{out: Enum.reverse(in_q)})

  @spec empty?(t()) :: boolean()
  def empty?(%__MODULE__{in: [], out: []}), do: true
  def empty?(%__MODULE__{}), do: false

  @spec member?(t(), any()) :: boolean()
  def member?(%__MODULE__{in: in_q, out: out}, a), do: a in in_q or a in out

  @spec delete(t(), any()) :: t()
  def delete(%__MODULE__{in: in_q, out: out}, a) do
    out = out ++ Enum.reverse(in_q)
    out = List.delete(out, a)
    %__MODULE__{out: out}
  end

  @spec from_list([any()]) :: t()
  def from_list(list), do: %__MODULE__{out: list}

  @spec to_list(t()) :: [any()]
  def to_list(%__MODULE__{in: in_q, out: out}), do: out ++ Enum.reverse(in_q)
end
