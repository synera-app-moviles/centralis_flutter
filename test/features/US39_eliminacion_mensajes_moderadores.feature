# language: es
Característica: Eliminación de mensajes por moderadores
  Como gerente
  Quiero eliminar mensajes inapropiados de cualquier chat
  Para mantener la profesionalidad

  Escenario: Eliminar mensaje inapropiado como moderador
    Dado que soy un gerente autenticado con permisos de moderador
    Y existe un mensaje inapropiado "Contenido ofensivo" de un empleado
    Cuando elimino el mensaje como moderador
    Entonces el mensaje debe desaparecer del chat
    Y debe registrarse la acción de moderación

  Escenario: Eliminar mensaje con notificación al autor
    Dado que soy un gerente autenticado con permisos de moderador
    Y existe un mensaje "Spam promocional" de un usuario
    Cuando elimino el mensaje con motivo "Contenido no profesional"
    Entonces el usuario debe recibir una notificación sobre la eliminación
    Y debe incluir el motivo de la eliminación

  Escenario: Ver registro de acciones de moderación
    Dado que soy un gerente autenticado con permisos de moderador
    Y he eliminado varios mensajes como moderador
    Cuando accedo al registro de moderación
    Entonces debo ver todas mis acciones registradas
    Y debo ver fecha, usuario afectado y motivo

  Escenario: Intentar moderar sin permisos
    Dado que soy un empleado autenticado sin permisos de moderador
    Y existe un mensaje inapropiado de otro usuario
    Cuando intento eliminar el mensaje
    Entonces no debo ver la opción de moderación
    Y el mensaje debe permanecer visible