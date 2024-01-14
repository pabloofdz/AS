defmodule RPG.Partida do
  @moduledoc """
  Módulo que implementa la lógica de una partida en un juego de rol (RPG).

  Utiliza el comportamiento GenServer para gestionar el estado de la partida y las interacciones
  entre los jugadores y el jefe del juego.
  """
  use GenServer
  require String
  require Logger

  @doc """
  Inicia una instancia de la partida.

  ## Parámetros

  - `capacidad_jugadores`: La cantidad máxima de jugadores permitidos en la partida.
  - `numero_jugadores`: La cantidad actual de jugadores en la partida.
  - `jugadores`: Mapa de jugadores en la partida, donde las claves son PIDs de jugadores y los valores
    son mapas con información sobre el jugador.
  - `nombre_jefe`: El nombre del jefe del juego.
  - `vida_inicial_jefe`: La vida inicial del jefe del juego.
  - `vida_jefe`: La vida actual del jefe del juego.
  - `tipos`: Mapa que define los tipos de personajes y sus atributos.

  ## Ejemplo

      iex> RPG.Partida.start_link(2, 0, %{}, "Bowser", 500, 500, %{:cabra => {40, 150, 2, 90, 2}, :espadachin => {15, 100, 2, 60, 1}, :mago => {20, 100, 2, 33, 1}})
  """
  def start_link(capacidad_jugadores, numero_jugadores, jugadores, nombre_jefe, vida_inicial_jefe, vida_jefe, tipos) do
    GenServer.start_link(__MODULE__, %{capacidad_jugadores: capacidad_jugadores, numero_jugadores: numero_jugadores, jugadores: jugadores, nombre_jefe: nombre_jefe, vida_inicial_jefe: vida_inicial_jefe, vida_jefe: vida_jefe, tipos: tipos})
  end

  @doc """
  Inicializa el estado del servidor.

  Se llama automáticamente al iniciar el servidor.

  ## Parámetros

  - `init_arg`: Argumento de inicialización, que es el mapa de configuración de la partida.
  """
  def init(init_arg) do
    {:ok, init_arg}
  end

  #Este es una función privada utilizada internamente para expulsar a todos los jugadores.
  defp reiniciar_jugadores(jugadores) do
    Enum.each(jugadores, fn {pid, _} ->
      Process.exit(pid, :normal)
    end)
    %{}
  end

  @doc """
  Maneja la solicitud de obtener el estado actual de la partida.

  Esta función se llama al recibir una solicitud `:obtener_estado`.

  ## Parámetros

  - `:obtener_estado`: La solicitud para obtener el estado actual de la partida.
  - `_from`: El proceso que envía la solicitud.
  - `state`: El estado actual de la partida.
  """
  def handle_call(:obtener_estado, _from, state) do
    {:reply, state, state}
  end

  @doc """
  Maneja la solicitud de unirse a la partida con un personaje.

  Esta función se llama al recibir una solicitud {:unirse_a_partida, tipo_personaje, nombre_personaje}.

  ## Parámetros

  - `{:unirse_a_partida, tipo_personaje, nombre_personaje}`: Solicitud para unirse a la partida con un personaje.
  - `_from`: El proceso que envía la solicitud.
  - `state`: El estado actual de la partida.

  ## Ejemplo

      iex> GenServer.call(partida_pid, {:unirse_a_partida, :cabra, "LA CABRA"})
  """
  def handle_call({:unirse_a_partida, tipo_personaje, nombre_personaje}, _from, state) do
    tipos_validos = Map.keys(state[:tipos])

    if state.numero_jugadores + 1 > state.capacidad_jugadores do
      Logger.info("Error: Se intentó unir a una partida llena. ¯\\_(⊙︿⊙)_/¯ ")
      {:reply, {:error, "Partida llena"}, state}
    else
      if not Enum.member?(tipos_validos, tipo_personaje) do
        Logger.info("Error: Tipo de personaje no válido. Debes elegir entre espadachin, cabra o mago. (눈_눈)")
        {:reply, {:error, "Tipo de personaje no válido"}, state}
      else
        if Enum.any?(state.jugadores, fn {_, jugador} -> Map.get(jugador, :nombre) == nombre_personaje end) do
          Logger.info("Error: Ya hay un jugador con ese nombre. (⊙﹏⊙)")
          {:reply, {:error, "Nombre de jugador duplicado"}, state}
        else
          Logger.info("Uniéndose a partida #{inspect(self())} con #{state.numero_jugadores} jugador(es). Como #{nombre_personaje}, de tipo #{tipo_personaje} (งツ)ว.")

          vida_inicial = elem(Map.get(state.tipos, tipo_personaje, {0, 0, 0, 0, 0}), 1)
          num_pociones = elem(Map.get(state.tipos, tipo_personaje, {0, 0, 0, 0, 0}), 2)
          ataques_especiales = elem(Map.get(state.tipos, tipo_personaje, {0, 0, 0, 0, 0}), 4)

          {:ok, personaje_pid} = RPG.Personaje.start_link(nombre_personaje, tipo_personaje, vida_inicial, vida_inicial, num_pociones, ataques_especiales, self())
          nuevo_estado = %{
            state |
            numero_jugadores: state.numero_jugadores + 1,
            jugadores: Map.put(state.jugadores, personaje_pid, %{tipo: tipo_personaje, vida: vida_inicial, nombre: nombre_personaje})
          }
          Logger.info("Lista de jugadores:")
          Enum.each(nuevo_estado.jugadores, fn {_pid, %{tipo: tipo, vida: vida, nombre: nombre_personaje}} ->
            Logger.info("- Nombre: #{nombre_personaje}, Tipo: #{tipo}, Vida: #{vida}")
          end)

          Logger.info("Vuestro objetivo es derrotar a #{state.nombre_jefe}")
          {:reply, {:ok, personaje_pid, self()}, nuevo_estado}
        end
      end
    end
  end

  @doc """
  Maneja la acción de abandonar la partida por parte de un jugador.

  Esta función se llama al recibir un mensaje {:abandonar_partida, personaje_pid}.

  ## Parámetros

  - `{:abandonar_partida, personaje_pid}`: Mensaje que indica que un jugador desea abandonar la partida.
  - `state`: El estado actual de la partida.

  ## Ejemplo

      iex> GenServer.cast(partida_pid, {:abandonar_partida, j_pid})
  """
  def handle_cast({:abandonar_partida, personaje_pid}, state) do
    case Map.get(state.jugadores, personaje_pid) do
      nil ->
        Logger.info("Error: Jugador no encontrado en la partida.")
        {:noreply, state}

      %{nombre: nombre_personaje} ->
        Logger.info("#{nombre_personaje} ha abandonado la partida. (╯︵╰,)")
        Process.exit(personaje_pid, :normal)

        nuevo_estado = %{state | numero_jugadores: state.numero_jugadores - 1, jugadores: Map.delete(state.jugadores, personaje_pid)}
        {:noreply, nuevo_estado}
    end
  end

  @doc """
  Maneja la acción de atacar al jefe por parte de un jugador.

  Esta función se llama al recibir un mensaje {:atacar, personaje_pid}.

  ## Parámetros

  - `{:atacar, personaje_pid}`: Mensaje que indica que un jugador desea atacar al jefe.
  - `state`: El estado actual de la partida.

  ## Ejemplo

      iex> GenServer.cast(partida_pid, {:atacar, j_pid})
  """
  def handle_cast({:atacar, personaje_pid}, state) do
    case Map.get(state.jugadores, personaje_pid) do
      nil ->
        Logger.info("Error: No hay un jugador con ese nombre.")
        {:noreply, state}

      %{nombre: nombre_personaje, tipo: tipo_personaje} ->
        daño_infligido = elem(Map.get(state.tipos, tipo_personaje, {0, 0, 0, 0, 0}), 0)

        random_number = :rand.uniform(100)
        random_number2 = :rand.uniform(2)

        probabilidadAtaque = elem(Map.get(state.tipos, tipo_personaje, {0, 0, 0, 0, 0}), 3)

        if random_number <= probabilidadAtaque do
          nueva_vida_jefe = state.vida_jefe - daño_infligido

          nuevo_estado = %{state | vida_jefe: nueva_vida_jefe}

          Logger.info(
            "#{nombre_personaje} ha infligido #{daño_infligido} de daño a #{state.nombre_jefe} (ง'-'︠)ง"
          )

          if nueva_vida_jefe <= 0 do
            Logger.info("¡Has derrotado a #{state.nombre_jefe}! ヾ(-_- )ゞ. Ahora te abrirá un hilo en Twitter. ᕦ(° ͜ʖ°)ᕤ")
            Logger.info("La partida ha terminado! Puedes volver a unirte si deseas volver a enfrentarte a #{state.nombre_jefe}!")
            nuevo_estado = %{state | numero_jugadores: 0, vida_jefe: state.vida_inicial_jefe, jugadores: reiniciar_jugadores(state.jugadores)}
            {:noreply, nuevo_estado}
          else
            Logger.info("Vida actual de #{state.nombre_jefe}: #{nueva_vida_jefe}")
            GenServer.cast(personaje_pid, {:ataque_jefe, state.nombre_jefe})
            {:noreply, nuevo_estado}
          end
        else
          if random_number2 == 1 do
            Logger.info("#{nombre_personaje} ha esquivado el ataque de #{state.nombre_jefe} (ಠ_ಠ)")
            GenServer.cast(personaje_pid, {:ataque_jefe, state.nombre_jefe})
            {:noreply, state}
          else
            Logger.info("#{nombre_personaje} falló el ataque a #{state.nombre_jefe}! (╯°□°）╯")
            GenServer.cast(personaje_pid, {:ataque_jefe, state.nombre_jefe})
            {:noreply, state}
          end
        end
    end
  end

   @doc """
  Maneja la acción de usar un ataque especial por parte de un jugador.

  Esta función se llama al recibir un mensaje {:ataque_especial, personaje_pid}.

  ## Parámetros

  - `{:ataque_especial, personaje_pid}`: Mensaje que indica que un jugador desea usar un ataque especial.
  - `state`: El estado actual de la partida.

  ## Ejemplo

      iex> GenServer.cast(partida_pid, {:ataque_especial, j2_pid})
  """
  def handle_cast({:ataque_especial, personaje_pid}, state) do
    case Map.get(state.jugadores, personaje_pid) do
      nil ->
        Logger.info("Error: No hay un jugador con ese nombre.")
        {:noreply, state}

      %{nombre: nombre_personaje, tipo: tipo_personaje} ->

        nuevo_estado_ataques = GenServer.call(personaje_pid, :obtener_estado)

        ataquesEspecialesRestantes = nuevo_estado_ataques.ataques_especiales

        if ataquesEspecialesRestantes != 0 do
          GenServer.cast(personaje_pid, {:ataquesEspecialesRestantes})

          daño_infligido = elem(Map.get(state.tipos, tipo_personaje, {0, 0, 0, 0, 0}), 0)

          nueva_vida_jefe = state.vida_jefe - daño_infligido

          nuevo_estado = %{state | vida_jefe: nueva_vida_jefe}

          Logger.info("WoW, vaya ataque, #{nombre_personaje} ha infligido #{daño_infligido} de daño a #{state.nombre_jefe} (ง'-'︠)ง")

          if nueva_vida_jefe <= 0 do
            Logger.info("¡Has derrotado a #{state.nombre_jefe}! ヾ(-_- )ゞ. Ahora te abrirá un hilo en Twitter. ᕦ(° ͜ʖ°)ᕤ")
            Logger.info("La partida ha terminado! Puedes volver a unirte si deseas volver a enfrentarte a #{state.nombre_jefe}!")
            nuevo_estado = %{state | numero_jugadores: 0, vida_jefe: state.vida_inicial_jefe, jugadores: reiniciar_jugadores(state.jugadores)}
            {:noreply, nuevo_estado}
          else
            Logger.info("Vida actual de #{state.nombre_jefe}: #{nueva_vida_jefe}")
            GenServer.cast(personaje_pid, {:ataque_jefe, state.nombre_jefe})
            {:noreply, nuevo_estado}
          end
        else
          Logger.info(" Vaya no te quedan ataques especiales... ¯\\_(ツ)_/¯")
           {:noreply, state}
        end
      end
  end

  @doc """
  Maneja la acción de usar una poción por parte de un jugador.

  Esta función se llama al recibir un mensaje {:usar_pocion, personaje_pid}.

  ## Parámetros

  - `{:usar_pocion, personaje_pid}`: Mensaje que indica que un jugador desea usar una poción.
  - `state`: El estado actual de la partida.

  ## Ejemplo

      iex> GenServer.cast(partida_pid, {:usar_pocion, j_pid})
  """
  def handle_cast({:usar_pocion, personaje_pid}, state) do
    case Map.get(state.jugadores, personaje_pid) do
      nil ->
        Logger.info("Error: Jugador no encontrado en la partida :(.")
        {:noreply, state}

      %{nombre: nombre_personaje} ->
        GenServer.cast(personaje_pid, {:usar_pocion})
        Logger.info("#{nombre_personaje} usó una poción!")
        {:noreply, state}
    end
  end
end
