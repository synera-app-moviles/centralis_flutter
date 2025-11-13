# language: es
Característica: Modificación de eventos
  Como gerente
  Quiero modificar detalles de eventos existentes
  Para ajustar cambios de último momento

  Escenario: Modificar fecha de evento exitosamente
    Dado que soy un gerente autenticado
    Y existe un evento futuro "Reunión semanal" programado para "2025-11-15"
    Cuando cambio la fecha del evento a "2025-11-16"
    Entonces el evento debe ser actualizado exitosamente
    Y todos los invitados deben ser notificados del cambio

  Escenario: Modificar título y descripción de evento
    Dado que soy un gerente autenticado
    Y existe un evento "Meeting" con descripción "TBD"
    Cuando cambio el título a "Reunión Estratégica" y descripción a "Planificación Q4"
    Entonces los cambios deben guardarse correctamente
    Y los invitados deben ver la información actualizada

  Escenario: Intentar modificar evento sin permisos
    Dado que soy un empleado autenticado sin permisos de gerente
    Y existe un evento futuro "Presentación"
    Cuando intento modificar los detalles del evento
    Entonces debo recibir un error de permisos insuficientes
    Y el evento no debe ser modificado

  Escenario: Intentar modificar evento que ya pasó
    Dado que soy un gerente autenticado
    Y existe un evento pasado "Capacitación anterior"
    Cuando intento modificar la fecha del evento
    Entonces debo recibir un error de evento ya realizado
    Y el evento no debe ser modificado