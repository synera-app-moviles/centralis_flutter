# language: es
Característica: Eliminar grupos de chats
  Como gerente
  Quiero eliminar chats grupales
  Para mantener el orden de las conversaciones

  Escenario: Eliminar grupo de chat exitosamente
    Dado que soy un gerente autenticado
    Y existe un grupo de chat "Proyecto Antiguo" que ya no es necesario
    Cuando elimino el grupo de chat
    Entonces el grupo debe ser eliminado exitosamente
    Y no debe aparecer en mi lista de chats

  Escenario: Confirmar eliminación de grupo con mensajes
    Dado que soy un gerente autenticado
    Y existe un grupo de chat "Marketing 2023" con mensajes históricos
    Cuando intento eliminar el grupo
    Entonces debo ver una confirmación sobre la pérdida de mensajes
    Y debo confirmar la eliminación explícitamente

  Escenario: Intentar eliminar grupo sin permisos
    Dado que soy un empleado autenticado sin permisos de gerente
    Y existe un grupo de chat "Ventas General"
    Cuando intento eliminar el grupo
    Entonces debo recibir un error de permisos insuficientes
    Y el grupo debe permanecer activo

  Escenario: Notificar miembros sobre eliminación de grupo
    Dado que soy un gerente autenticado
    Y existe un grupo "Equipo Beta" con múltiples miembros
    Cuando elimino el grupo
    Entonces todos los miembros deben ser notificados
    Y el grupo debe desaparecer de sus listas de chat