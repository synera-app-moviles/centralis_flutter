# language: es
Característica: Acceder a las descripciones de las imágenes
  Como visitante que utiliza un lector de pantalla
  Quiero que todas las imágenes significativas de la página de destino incluyan texto alternativo claro
  Para poder comprender el contenido visual y navegar por el sitio web

  Escenario: Verificar texto alternativo en imágenes principales
    Dado que utilizo un lector de pantalla
    Y estoy navegando en la landing page
    Cuando el lector encuentra una imagen del producto
    Entonces debe leer una descripción clara y significativa
    Y la descripción debe explicar el contenido de la imagen

  Escenario: Verificar accesibilidad en galería de imágenes
    Dado que utilizo un lector de pantalla
    Y navego por la galería de características
    Cuando el lector encuentra cada imagen
    Entonces debe leer el texto alternativo específico
    Y debe indicar la funcionalidad mostrada

  Escenario: Verificar logos y elementos decorativos
    Dado que utilizo un lector de pantalla
    Y navego por toda la landing page
    Cuando encuentro logos de empresas o elementos decorativos
    Entonces los elementos decorativos deben ser ignorados por el lector
    Y los logos importantes deben tener descripción apropiada

  Escenario: Verificar contraste y legibilidad
    Dado que tengo dificultades visuales
    Cuando navego por la landing page
    Entonces el contraste de texto debe ser suficiente
    Y el texto debe ser legible a diferentes tamaños