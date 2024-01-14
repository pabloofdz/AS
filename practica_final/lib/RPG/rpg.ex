defmodule RPG do
  @moduledoc """
  Módulo principal que gestiona la creación y búsqueda de partidas en el juego de rol (RPG).
  """
  defstruct pids: []

  use GenServer
  require Logger

  @jugadores_max 5
  @tipos %{:cabra => {40, 150, 2, 90, 2}, :espadachin => {15, 100, 2, 60, 1}, :mago => {20, 100, 2, 33, 1}}

  @doc """
  Inicia una instancia del módulo RPG.

  ## Parámetros

  - `args`: Número de peers que se desean crear.

  ## Ejemplo

      iex> RPG.start_link(4)
  """
  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  # Error si no se crea ningún peer
  @impl true
  def init(0) do
    {:stop, "Debe haber al menos un nodo."}
  end

  def init(numpeers) do
    {pids, _} = Enum.reduce_while(1..numpeers, {[], RPG.Partida}, fn _, {pids, partida_mod} ->
      {:ok, peer_pid} = RPG.Partida.start_link(@jugadores_max, 0, %{}, "AS", 2000, 2000, @tipos)
      Logger.info("Partida inicializada en peer #{inspect(peer_pid)} ")
      {:cont, {pids ++ [peer_pid], partida_mod}}
    end)

    {:ok, %{pids: pids}}
  end

  @doc """
  Maneja la llamada para buscar una partida disponible.

  ## Parámetros

  - `{:buscar_partida, tipo_personaje, nombre_personaje}`: Solicitud para buscar una partida con un personaje específico.
  - `_from`: El proceso que envía la solicitud.
  - `state`: El estado actual del servidor.

  ## Ejemplo

      iex> GenServer.call(rpg_pid, {:buscar_partida, :cabra, "LA CABRA"})
  """
  @impl true
  def handle_call({:buscar_partida, tipo_personaje, nombre_personaje}, _from, state) do
    result =
      Enum.reduce_while(state.pids, {:ok, nil, nil}, fn pid, acc ->
        case GenServer.call(pid, {:unirse_a_partida, tipo_personaje, nombre_personaje}) do
          {:ok, j_pid, partida_pid} ->
            {:halt, {:ok, j_pid, partida_pid}}
          _ ->
            {:cont, acc}
        end
      end)

      case result do
        {:ok, j_pid, partida_pid} ->
          {:reply, {:ok, j_pid, partida_pid}, state}
        _ ->
          {:reply, {:error, "No hay partidas disponibles"}, state}
      end
  end
end
