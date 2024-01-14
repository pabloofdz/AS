# GOATS OF WAR 

## Breve descripción 

Nuestra propuesta se centra en el desarrollo de un videojuego de rol (RPG) donde los jugadores asumen el papel de diversos personajes con habilidades distintivas, unidos en la épica tarea de enfrentarse a un jefe final. Cada tipo de personaje posee atributos únicos que determinan el daño infligido al jefe y la cantidad de pociones disponibles para la curación. El combate se desarrolla por turnos, alternando entre los jugadores y el jefe, con la posibilidad de aciertos o fallos en los ataques, así como de poder esquivarlos. Los usuarios tienen la oportunidad de unirse a una partida existente (siempre que haya espacio), creando su propio personaje con nombre y tipo específico. Una vez dentro de la partida, los jugadores pueden participar en la lucha contra el jefe, llevando a cabo ataques estratégicos y utilizando pociones para mantenerse en la batalla. Este enfoque brinda a los jugadores una experiencia desafiante, donde la cooperación y la toma de decisiones tácticas son fundamentales para la victoria.

## Requisitos funcionales

- Registro de Jugadores:
 Los usuarios deben poder registrarse para unirse al juego. Se debe recopilar la información del nombre y el tipo de personaje elegido por el usuario durante el registro.

- Creación de Partida: 
 El sistema debe permitir la creación de partidas, estableciendo un límite de jugadores. Se deben asignar roles específicos a los jugadores, determinados por el tipo de personaje elegido.

- Combate por Turnos:
 Los jugadores deben participar en combates por turnos contra el jefe final. Cada turno, los jugadores tienen la opción de atacar al jefe y el jefe responde con un contraataque.

- Interacción con el Jefe:
 Los jugadores deben poder atacar al jefe final. El jefe debe tener la capacidad de contraatacar.
 
- Uso de Pociones: 
 Los jugadores pueden utilizar pociones para curarse durante el combate. La cantidad de pociones disponibles debe ser limitada y específica para cada tipo de personaje.

## Requisitos no funcionales
Requisitos no funcionales:

- Escalabilidad:
  La arquitectura P2P permite a los jugadores unirse a cualquier partida disponible, lo que facilita la escalabilidad al distribuir la carga entre los pares. La arquitectura Líder-Trabajador también contribuye a la escalabilidad al separar la gestión del juego de la funcionalidad del juego.

- Rendimiento:
  La combinación de arquitecturas P2P y Líder-Trabajador proporciona un rendimiento eficiente. La arquitectura P2P permite una distribución equitativa de la carga entre los pares, mientras que la arquitectura Líder-Trabajador divide las responsabilidades entre el líder (partida) y los trabajadores (personajes), mejorando así el rendimiento general del sistema.

- Confiabilidad:
  La arquitectura Líder-Trabajador incluye un líder encargado de gestionar y mantener el estado de la partida. Esto contribuye a la confiabilidad, ya que el líder puede tomar decisiones críticas, como añadir o eliminar trabajadores (personajes), actualizar el estado del juego y reiniciar la partida en caso de que el jefe muera.

- Interconectividad:
  La arquitectura P2P facilita la interconectividad al permitir que los jugadores se unan a cualquier partida disponible. El super-peer ayuda a encontrar partidas disponibles y a que los pares conozcan a sus vecinos, mejorando así la conexión entre los nodos del juego.

- Tiempo de Respuesta:
  La arquitectura P2P permite a los jugadores unirse rápidamente a partidas disponibles, ya que no hay una única entrada al sistema. La distribución de la carga de trabajo en la arquitectura Líder-Trabajador también contribuye a mantener bajos los tiempos de respuesta al dividir las tareas de manera eficiente.

- Flexibilidad y Mantenibilidad:
  La arquitectura Líder-Trabajador permite una fácil adaptación y mantenimiento al separar la lógica de gestión de la funcionalidad del juego. Esto facilita la introducción de nuevas características, ajustes de juego o actualizaciones sin afectar la integridad del sistema.

- Consistencia:
  La arquitectura Líder-Trabajador, al tener un líder que gestiona el estado de la partida, contribuye a la consistencia del juego al garantizar que todos los jugadores tengan una experiencia coherente y actualizada.

## Arquitectura. 
Para implementar este videojuego, hemos optado por combinar dos arquitecturas, P2P + Líder-Trabajador

- Arquitectura P2P:
Un jugador se puede unir a cualquier partida disponible, que está en un peer.
Tenemos un super-peer, encargado de crear las distintas partidas y de buscar una disponible, puesto que permite que los pares conozcan a sus vecinosde ser preciso.
Esta arquitectura nos permite que si una partida no está disponible, nos podamos unir a otra.

- Arquitectura Lider-Trabajador:
Tenemos un punto de entrada al sistema, el líder, que en nuestro caso es la partida (módulo RPG.Partida), que coordina y supervisa el flujo general del juego, gestionando la interacción entre los jugadores y el jefe final. Cada jugador, representado por el módulo RPG.Personaje, es un "trabajador" independiente que responde a los comandos del líder y ejecuta acciones específicas en el juego.
El líder distribuye el trabajo (ataques y uso de pociones) y tiene lógica de gestión (añadir nuevos trabajadores (personajes) y eliminarlos, actualizar el estado de la partida y reiniciarla cuando el jefe muere). La comunicación entre el líder y los trabajadores se realiza a través de mensajes, lo que facilita la coordinación del combate por turnos, el manejo de eventos como ataques y esquivas, y la gestión de recursos como las pociones.
Gracias a todo lo anterior, obtenemos un gran rendimiento y escalabilidad debido a la separación entre gestión y funcionalidad.

## C4
Diagramas disponibles en /doc
