defmodule RPG.Personaje do
  @moduledoc """
  Módulo que representa a un jugador en la partida.
  Cada jugador tiene un personaje con características como vida, ataques especiales y la capacidad de usar pociones.
  """
  use GenServer
  require Logger

  @doc """
  Inicia una instancia del módulo RPG.Personaje.

  ## Parámetros

  - `nombre`: Nombre del personaje.
  - `tipo`: Tipo de personaje.
  - `vida`: Vida actual del personaje.
  - `vida_maxima`: Vida máxima del personaje.
  - `num_pociones`: Número de pociones que tiene el personaje.
  - `ataques_especiales`: Número de ataques especiales restantes.
  - `partida_pid`: PID de la partida a la que pertenece el personaje.

  ## Ejemplo

      iex> RPG.Personaje.start_link(nombre_personaje, tipo_personaje, vida_inicial, vida_inicial, num_pociones, ataques_especiales, partida_pid)
  """
  def start_link(nombre, tipo, vida, vida_maxima, num_pociones, ataques_especiales, partida_pid) do
    GenServer.start_link(__MODULE__, {nombre, tipo, vida, vida_maxima, num_pociones, ataques_especiales, partida_pid})
  end

  def init({nombre, tipo, vida, vida_maxima, num_pociones, ataques_especiales, partida_pid}) do
    {:ok, %{nombre: nombre, tipo: tipo, vida: vida, vida_maxima: vida_maxima, num_pociones: num_pociones, ataques_especiales: ataques_especiales, partida_pid: partida_pid}}
  end

  @doc """
  Maneja la llamada para obtener el estado del personaje.

  ## Parámetros

  - `:obtener_estado`: Mensaje para obtener el estado del personaje.
  - `_from`: El proceso que envía la solicitud.
  - `state`: El estado actual del personaje.
  """
  def handle_call(:obtener_estado, _from, state) do
    {:reply, state, state}
  end

   @doc """
  Maneja la acción actualizar los ataques especiales restantes.

  ## Parámetros

  - `{:ataquesEspecialesRestantes}`: Mensaje para actualizar ataques especiales restantes.
  - `state`: El estado actual del personaje.

  ## Ejemplo

      iex> GenServer.cast(personaje_pid, {:ataquesEspecialesRestantes})
  """
  def handle_cast({:ataquesEspecialesRestantes}, state) do
    nuevo_estado = %{state | ataques_especiales: state.ataques_especiales-1}
    Logger.info("#{state.nombre}, te quedan #{nuevo_estado.ataques_especiales} ataque(s) especial(es) (´•︵•`)")
    {:noreply, nuevo_estado}
  end

  @doc """
  Maneja la acción de usar una poción.

  ## Parámetros

  - `{:usar_pocion}`: Mensaje para usar una poción.
  - `state`: El estado actual del personaje.

  ## Ejemplo

      iex> GenServer.cast(personaje_pid, {:usar_pocion})
  """
  def handle_cast({:usar_pocion}, state) do
    if state.vida == state.vida_maxima do
      Logger.info("#{state.nombre}, tu vida ya está al máximo ( ˘ ³˘)♥")
      {:noreply, state}
    else
      if state.num_pociones == 0 do
        Logger.info("#{state.nombre}, no te quedan pociones, ¡Dios se apiade de ti! (´•︵•`)")
        {:noreply, state}
      else
        nuevo_estado = %{state | vida: min(state.vida + 10, state.vida_maxima), num_pociones: state.num_pociones-1}
        Logger.info("#{state.nombre} ha usado una poción ( ˘ ³˘)♥. Nueva vida: #{nuevo_estado.vida}")
        if nuevo_estado.num_pociones == 0 do
          Logger.info("#{state.nombre}, no te quedan pociones, ¡Dios se apiade de ti! (´•︵•`)")
        else
          Logger.info("#{state.nombre}, te quedan #{nuevo_estado.num_pociones} pocion(es). Adminístrala(s) bien! (∪▂∪)")
        end
        {:noreply, nuevo_estado}
      end
    end
  end

  @doc """
  Maneja la acción de recibir un ataque del jefe.

  ## Parámetros

  - `{:ataque_jefe, nombre_jefe}`: Mensaje para recibir un ataque del jefe.
  - `state`: El estado actual del personaje.

  ## Ejemplo

      iex> GenServer.cast(personaje_pid, {:ataque_jefe, state.nombre_jefe})
  """
  def handle_cast({:ataque_jefe, nombre_jefe}, state) do
      random_number = :rand.uniform(3)
      if random_number==3 do
        random_ataque = :rand.uniform(30)
        nuevo_estado = %{state | vida: max(state.vida - random_ataque, 0)}
        Logger.info("#{nombre_jefe} ha infligido #{random_ataque} de daño a #{state.nombre} щ（ﾟДﾟщ）(╬ ಠ益ಠ)")
        if nuevo_estado.vida == 0 do
          Logger.info("#{state.nombre} ha muerto (✖╭╮✖) (DEP) (ಥ_ಥ)")
          GenServer.cast(state.partida_pid, {:abandonar_partida, self()})
          {:noreply, nuevo_estado}
        else
           Logger.info("A #{state.nombre} le quedan #{nuevo_estado.vida} puntos de vida ¯\\_(ツ)_/¯")
           {:noreply, nuevo_estado}
        end
      else if random_number==2 do
        Logger.info("#{state.nombre} ha esquivado el ataque de #{nombre_jefe} (ಠ ͜ʖಠ)")
        {:noreply, state}
      else
        Logger.info("#{nombre_jefe} falló el ataque a #{state.nombre}! (‾ʖ̫‾)")
        {:noreply, state}
      end
    end
  end
end
