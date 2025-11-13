# language: es
Característica: Cancelación de eventos
  Como gerente
  Quiero cancelar eventos cuando sea necesario
  Para evitar confusiones

  Escenario: Cancelar evento exitosamente
    Dado que soy un gerente autenticado
    Y existe un evento futuro "Reunión de ventas"
    Cuando cancelo el evento "Reunión de ventas" con motivo "Cambio de prioridades"
    Entonces el evento debe marcarse como cancelado
    Y todos los invitados deben ser notificados

  Escenario: Intentar cancelar evento pasado
    Dado que soy un gerente autenticado
    Y existe un evento pasado "Conferencia anual"
    Cuando intento cancelar el evento "Conferencia anual"
    Entonces debo recibir un error de evento ya realizado
    Y el evento no debe ser modificado

  Escenario: Intentar cancelar evento sin permisos
    Dado que soy un empleado autenticado sin permisos de gerente
    Y existe un evento futuro "Workshop técnico"
    Cuando intento cancelar el evento "Workshop técnico"
    Entonces debo recibir un error de permisos insuficientes
    Y el evento debe permanecer activo

  Escenario: Ver evento cancelado en la lista
    Dado que soy un empleado autenticado
    Y existe un evento cancelado "Reunión postergada"
    Cuando veo la lista de eventos
    Entonces debo ver el evento marcado como "CANCELADO"
    Y debo ver el motivo de la cancelación