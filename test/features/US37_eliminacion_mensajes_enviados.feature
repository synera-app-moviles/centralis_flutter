# language: es
Característica: Eliminación de mensajes enviados
  Como empleado
  Quiero eliminar mensajes que envié por error
  Para corregir mis equivocaciones

  Escenario: Eliminar mensaje propio recién enviado
    Dado que soy un empleado autenticado
    Y envié un mensaje "Mensaje incorrecto" hace 2 minutos
    Cuando elimino mi mensaje
    Entonces el mensaje debe desaparecer del chat
    Y debe mostrar "Mensaje eliminado" a otros usuarios

  Escenario: Intentar eliminar mensaje después del tiempo límite
    Dado que soy un empleado autenticado
    Y envié un mensaje hace 1 hora
    Cuando intento eliminar mi mensaje
    Entonces debo recibir un error de tiempo límite excedido
    Y el mensaje debe permanecer visible

  Escenario: Eliminar mensaje con archivos adjuntos
    Dado que soy un empleado autenticado
    Y envié un mensaje con imagen adjunta hace 1 minuto
    Cuando elimino mi mensaje
    Entonces tanto el mensaje como la imagen deben ser eliminados
    Y debe mostrarse "Mensaje eliminado" en su lugar

  Escenario: Intentar eliminar mensaje de otro usuario
    Dado que soy un empleado autenticado
    Y otro usuario envió un mensaje "Mensaje ajeno"
    Cuando intento eliminar ese mensaje
    Entonces no debo ver la opción de eliminar
    Y el mensaje debe permanecer intacto