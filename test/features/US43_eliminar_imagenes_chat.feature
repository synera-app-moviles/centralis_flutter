# language: es
Característica: Eliminar imágenes enviadas en el chat
  Como usuario
  Quiero poder eliminar una imagen enviada en un chat
  Para corregir errores o evitar confusiones

  Escenario: Eliminar imagen propia recién enviada
    Dado que soy un usuario autenticado
    Y envié una imagen "documento_privado.jpg" hace 1 minuto
    Cuando elimino mi imagen
    Entonces la imagen debe desaparecer del chat
    Y debe mostrarse "Imagen eliminada" en su lugar

  Escenario: Eliminar imagen después de varios mensajes
    Dado que soy un usuario autenticado
    Y envié una imagen hace 5 minutos
    Y otros usuarios enviaron mensajes posteriores
    Cuando elimino mi imagen
    Entonces solo la imagen debe ser eliminada
    Y los mensajes posteriores deben permanecer intactos

  Escenario: Intentar eliminar imagen después del tiempo límite
    Dado que soy un usuario autenticado
    Y envié una imagen hace 3 horas
    Cuando intento eliminar mi imagen
    Entonces debo recibir un mensaje de tiempo límite excedido
    Y la imagen debe permanecer visible

  Escenario: Moderador elimina imagen inapropiada
    Dado que soy un gerente con permisos de moderador
    Y un usuario envió una imagen inapropiada
    Cuando elimino la imagen como moderador
    Entonces la imagen debe ser removida inmediatamente
    Y el usuario debe ser notificado de la acción