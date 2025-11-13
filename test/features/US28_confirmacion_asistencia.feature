# language: es
Característica: Confirmación de asistencia
  Como empleado
  Quiero confirmar mi asistencia a eventos
  Para que los organizadores sepan cuántos asistirán

  Escenario: Confirmar asistencia a evento
    Dado que soy un empleado autenticado
    Y he sido invitado al evento "Reunión mensual"
    Cuando confirmo mi asistencia al evento
    Entonces mi asistencia debe quedar registrada
    Y el organizador debe ver mi confirmación

  Escenario: Cancelar asistencia confirmada
    Dado que soy un empleado autenticado
    Y ya confirmé mi asistencia al evento "Capacitación"
    Cuando cancelo mi asistencia
    Entonces mi asistencia debe quedar como "No asistirá"
    Y el organizador debe ver el cambio

  Escenario: Intentar confirmar asistencia sin invitación
    Dado que soy un empleado autenticado
    Y existe un evento "Reunión directiva" al cual no fui invitado
    Cuando intento confirmar mi asistencia
    Entonces debo recibir un error de no invitado
    Y mi asistencia no debe quedar registrada

  Escenario: Ver estado de asistencia de evento
    Dado que soy un empleado autenticado
    Y he sido invitado al evento "Taller"
    Cuando veo los detalles del evento
    Entonces debo poder ver las opciones "Asistiré" y "No asistiré"
    Y debo ver mi estado actual de asistencia