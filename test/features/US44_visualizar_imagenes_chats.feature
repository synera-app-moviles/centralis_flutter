# language: es
Característica: Visualizar imágenes en chats
  Como empleado
  Quiero ver todos los chats de los que forma parte
  Para encontrar rápidamente conversaciones específicas

  Escenario: Ver imagen en tamaño completo
    Dado que soy un empleado autenticado
    Y existe una imagen en el chat "equipo_marketing.jpg"
    Cuando toco la imagen
    Entonces la imagen debe abrirse en pantalla completa
    Y debo poder hacer zoom para ver detalles

  Escenario: Ver miniaturas de imágenes en conversación
    Dado que soy un empleado autenticado
    Y existe un chat con múltiples imágenes enviadas
    Cuando veo la conversación
    Entonces debo ver miniaturas de todas las imágenes
    Y las miniaturas deben cargar rápidamente

  Escenario: Descargar imagen del chat
    Dado que soy un empleado autenticado
    Y existe una imagen "informe_mensual.png" en el chat
    Cuando mantengo presionada la imagen
    Y selecciono "Descargar"
    Entonces la imagen debe guardarse en mi dispositivo
    Y debo recibir confirmación de descarga exitosa

  Escenario: Ver galería de imágenes del chat
    Dado que soy un empleado autenticado
    Y existe un chat con múltiples imágenes históricas
    Cuando accedo a la galería del chat
    Entonces debo ver todas las imágenes organizadas cronológicamente
    Y debo poder navegar entre ellas fácilmente