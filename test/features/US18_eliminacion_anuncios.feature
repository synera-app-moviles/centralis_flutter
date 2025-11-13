# language: es
Característica: Eliminación de anuncios
  Como gerente
  Quiero eliminar anuncios obsoletos
  Para mantener la información actualizada

  Escenario: Eliminar un anuncio exitosamente
    Dado que soy un gerente autenticado
    Y existe un anuncio con título "Evento cancelado"
    Cuando elimino el anuncio "Evento cancelado"
    Entonces el anuncio debe ser eliminado exitosamente
    Y no debe aparecer en la lista de anuncios

  Escenario: Intentar eliminar anuncio sin permisos
    Dado que soy un empleado autenticado sin permisos de gerente
    Y existe un anuncio con título "Reunión importante"
    Cuando intento eliminar el anuncio "Reunión importante"
    Entonces debo recibir un error de permisos insuficientes
    Y el anuncio debe permanecer en la lista

  Escenario: Intentar eliminar anuncio inexistente
    Dado que soy un gerente autenticado
    Cuando intento eliminar un anuncio que no existe
    Entonces debo recibir un error de anuncio no encontrado