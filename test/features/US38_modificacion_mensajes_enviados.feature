# language: es
Característica: Modificación de mensajes enviados
  Como empleado
  Quiero editar mensajes que ya envié
  Para corregir errores tipográficos

  Escenario: Editar mensaje propio con error tipográfico
    Dado que soy un empleado autenticado
    Y envié un mensaje "Hols, como estan?" hace 1 minuto
    Cuando edito el mensaje a "Hola, ¿cómo están?"
    Cuando guardo los cambios
    Entonces el mensaje debe mostrar el texto corregido
    Y debe indicar que fue editado

  Escenario: Intentar editar mensaje después del tiempo límite
    Dado que soy un empleado autenticado
    Y envié un mensaje hace 2 horas
    Cuando intento editar mi mensaje
    Entonces no debo ver la opción de editar
    Y el mensaje debe permanecer sin cambios

  Escenario: Ver historial de ediciones
    Dado que soy un empleado autenticado
    Y edité un mensaje "Reunión mañana" múltiples veces
    Cuando presiono prolongadamente el mensaje editado
    Entonces debo poder ver el historial de ediciones
    Y debo ver las versiones anteriores del mensaje

  Escenario: Intentar editar mensaje de otro usuario
    Dado que soy un empleado autenticado
    Y otro usuario envió un mensaje con errores
    Cuando intento editar ese mensaje
    Entonces no debo ver la opción de editar
    Y el mensaje debe permanecer sin cambios