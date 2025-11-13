# language: es
Característica: Subir imágenes en anuncios
  Como gerente
  Quiero poder adjuntar imágenes a los anuncios publicados
  Para que la información sea más clara y atractiva

  Escenario: Subir imagen en anuncio exitosamente
    Dado que soy un gerente autenticado
    Cuando creo un anuncio con título "Nueva política" y adjunto una imagen
    Entonces el anuncio debe ser creado con la imagen exitosamente
    Y la imagen debe ser visible en el anuncio

  Escenario: Subir imagen con formato válido
    Dado que soy un gerente autenticado
    Cuando intento subir una imagen en formato JPG de 2MB
    Entonces la imagen debe ser aceptada
    Y debe aparecer como vista previa

  Escenario: Rechazar imagen con formato inválido
    Dado que soy un gerente autenticado
    Cuando intento subir un archivo de formato TXT
    Entonces debo recibir un error de formato no válido
    Y la imagen no debe ser adjuntada

  Escenario: Rechazar imagen excesivamente grande
    Dado que soy un gerente autenticado
    Cuando intento subir una imagen de 50MB
    Entonces debo recibir un error de tamaño excesivo
    Y la imagen no debe ser adjuntada