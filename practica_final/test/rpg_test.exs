defmodule RPGTest do
  use ExUnit.Case
  use GenServer
  test "Test 1: No se puede unir, partida llena" do
    {:ok, partida_pid} = RPG.Partida.start_link(1, 0, %{}, "Bowser", 500, 500, %{:cabra => {40, 150, 2, 90, 2}, :espadachin => {15, 100, 2, 60, 1}, :mago => {20, 100, 2, 33, 1}})

    estado_1_partida = GenServer.call(partida_pid, :obtener_estado)

    {:ok, j1_pid, partida_pid} = GenServer.call(partida_pid, {:unirse_a_partida, :cabra, "LA CABRA"})

    estado_1_j1 = GenServer.call(j1_pid, :obtener_estado)

    estado_2_partida = GenServer.call(partida_pid, :obtener_estado)
    assert estado_2_partida.numero_jugadores == 1

    assert j1_pid != nil
    assert estado_1_j1.nombre == "LA CABRA"
    assert estado_1_j1.tipo == :cabra
    assert estado_1_j1.vida == 150
    assert estado_1_j1.num_pociones == 2

    assert {:error, "Partida llena"} = GenServer.call(partida_pid, {:unirse_a_partida, :mago, "Mago"})
  end

  test "Test 2: No se puede unir, no existe ese tipo" do
    {:ok, partida_pid} = RPG.Partida.start_link(2, 0, %{}, "Bowser", 500, 500, %{:cabra => {40, 150, 2, 90, 2}, :espadachin => {15, 100, 2, 60, 1}, :mago => {20, 100, 2, 33, 1}})

    estado_1_partida = GenServer.call(partida_pid, :obtener_estado)


    {:ok, j1_pid, partida_pid} = GenServer.call(partida_pid, {:unirse_a_partida, :cabra, "LA CABRA"})

    estado_1_j1 = GenServer.call(j1_pid, :obtener_estado)

    estado_2_partida = GenServer.call(partida_pid, :obtener_estado)
    assert estado_2_partida.numero_jugadores == 1

    assert j1_pid != nil
    assert estado_1_j1.nombre == "LA CABRA"
    assert estado_1_j1.tipo == :cabra
    assert estado_1_j1.vida == 150
    assert estado_1_j1.num_pociones == 2

    assert {:error, "Tipo de personaje no válido"} = GenServer.call(partida_pid, {:unirse_a_partida, :tortuga, "Tortuguita"})
  end

  test "Test 3: No se puede unir, ya existe jugador con ese nombre" do
    {:ok, partida_pid} = RPG.Partida.start_link(2, 0, %{}, "Bowser", 500, 500, %{:cabra => {40, 150, 2, 90, 2}, :espadachin => {15, 100, 2, 60, 1}, :mago => {20, 100, 2, 33, 1}})

    estado_1_partida = GenServer.call(partida_pid, :obtener_estado)


    {:ok, j1_pid, partida_pid} = GenServer.call(partida_pid, {:unirse_a_partida, :cabra, "LA CABRA"})

    estado_1_j1 = GenServer.call(j1_pid, :obtener_estado)

    estado_2_partida = GenServer.call(partida_pid, :obtener_estado)
    assert estado_2_partida.numero_jugadores == 1

    assert j1_pid != nil
    assert estado_1_j1.nombre == "LA CABRA"
    assert estado_1_j1.tipo == :cabra
    assert estado_1_j1.vida == 150
    assert estado_1_j1.num_pociones == 2

    assert {:error, "Nombre de jugador duplicado"} = GenServer.call(partida_pid, {:unirse_a_partida, :cabra,  "LA CABRA"})
  end

  test "Test 4: Jugadores atacan al jefe " do
    {:ok, partida_pid} = RPG.Partida.start_link(3, 0, %{}, "Bowser", 500, 500, %{:cabra => {40, 150, 2, 90, 2}, :espadachin => {15, 100, 2, 60, 1}, :mago => {20, 100, 2, 33, 1}})

    estado_1_partida = GenServer.call(partida_pid, :obtener_estado)

    assert partida_pid != nil
    assert estado_1_partida.capacidad_jugadores == 3
    assert estado_1_partida.numero_jugadores == 0
    assert estado_1_partida.jugadores == %{}
    assert estado_1_partida.nombre_jefe == "Bowser"
    assert estado_1_partida.vida_inicial_jefe == 500
    assert estado_1_partida.vida_jefe == 500
    assert estado_1_partida.tipos == %{cabra: {40, 150, 2, 90, 2}, espadachin: {15, 100, 2, 60, 1}, mago: {20, 100, 2, 33, 1}}

    {:ok, _j1_pid, partida_pid} = GenServer.call(partida_pid, {:unirse_a_partida, :cabra, "LA CABRA"})
    {:ok, j2_pid, partida_pid} = GenServer.call(partida_pid, {:unirse_a_partida, :mago, "El mago"})
    {:ok, _j3_pid, partida_pid} = GenServer.call(partida_pid, {:unirse_a_partida, :espadachin, "El espadachin"})

    estado_2_partida = GenServer.call(partida_pid, :obtener_estado)
    assert estado_2_partida.numero_jugadores == 3

    GenServer.cast(partida_pid, {:atacar, j2_pid})

    estado_1_j2 = GenServer.call(j2_pid, :obtener_estado)

    if estado_1_j2.vida < estado_1_j2.vida_maxima do
      GenServer.cast(partida_pid, {:usar_pocion, j2_pid})
      estado_2_j2 = GenServer.call(j2_pid, :obtener_estado)
      assert estado_2_j2.num_pociones == 1
    end
  end

  test "Test 5: Jugador mata al jefe con ataque especial" do
    {:ok, partida_pid} = RPG.Partida.start_link(1, 0, %{}, "Bowser", 1, 1, %{:cabra => {40, 150, 2, 90, 1}, :espadachin => {15, 100, 2, 60, 1}, :mago => {20, 100, 2, 33, 1}})

    estado_1_partida = GenServer.call(partida_pid, :obtener_estado)


    {:ok, j1_pid, partida_pid} = GenServer.call(partida_pid, {:unirse_a_partida, :cabra, "LA CABRA"})

    estado_2_partida = GenServer.call(partida_pid, :obtener_estado)

    assert estado_2_partida.numero_jugadores == 1

    GenServer.cast(partida_pid,{:ataque_especial,j1_pid})

    estado_3_partida = GenServer.call(partida_pid, :obtener_estado)

    assert estado_3_partida.vida_inicial_jefe == 1

    assert estado_3_partida.numero_jugadores == 0

  end

  test "Test 6: Unirse y abandonar partida" do
    {:ok, partida_pid} = RPG.Partida.start_link(1, 0, %{}, "Bowser", 100, 100, %{:cabra => {40, 150, 2, 90, 1}, :espadachin => {15, 100, 2, 60, 1}, :mago => {20, 100, 2, 33, 1}})

    {:ok, j1_pid, partida_pid} = GenServer.call(partida_pid, {:unirse_a_partida, :cabra, "LA CABRA"})

    estado_2_partida = GenServer.call(partida_pid, :obtener_estado)

    assert estado_2_partida.numero_jugadores == 1

    GenServer.cast(partida_pid, {:abandonar_partida, j1_pid})

    estado_3_partida = GenServer.call(partida_pid, :obtener_estado)

    assert estado_3_partida.numero_jugadores == 0

  end

  test "Test 7:  Usar personaje" do
    {:ok, partida_pid} = RPG.Partida.start_link(3, 0, %{}, "Bowser", 1000, 1000, %{:cabra => {40, 150, 2, 90, 2}, :espadachin => {15, 100, 2, 60, 1}, :mago => {20, 100, 2, 33, 1}})


    {:ok, j1_pid, partida_pid} = GenServer.call(partida_pid, {:unirse_a_partida, :cabra, "LA CABRA"})
    {:ok, j2_pid, partida_pid} = GenServer.call(partida_pid, {:unirse_a_partida, :mago, "El mago"})
    {:ok, j3_pid, partida_pid} = GenServer.call(partida_pid, {:unirse_a_partida, :espadachin, "El espadachin"})

    estado_2_partida = GenServer.call(partida_pid, :obtener_estado)
    assert estado_2_partida.numero_jugadores == 3

    estado_1_j1 = GenServer.call(j1_pid, :obtener_estado)
    assert estado_1_j1.ataques_especiales == 2

    GenServer.cast(partida_pid, {:ataque_especial, j1_pid})
    Process.sleep(50)
    estado_2_j1 = GenServer.call(j1_pid, :obtener_estado)
    assert estado_2_j1.ataques_especiales == 1

    GenServer.cast(partida_pid,{:ataque_especial,j1_pid})
    Process.sleep(50)
    estado_3_j1 = GenServer.call(j1_pid, :obtener_estado)
    assert estado_3_j1.ataques_especiales == 0

  end

  test "Test 8: Peers" do
    {:ok, rpg_pid} = RPG.start_link(4)
    {:ok, _j1_pid, _partida_pid} = GenServer.call(rpg_pid, {:buscar_partida, :cabra, "LA CABRA"})
    {:ok, _j2_pid, _partida_pid} = GenServer.call(rpg_pid, {:buscar_partida, :cabra, "LA CABRA"})

  end

end
