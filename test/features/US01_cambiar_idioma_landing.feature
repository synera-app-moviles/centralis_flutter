# language: es
Característica: Cambiar el idioma de la landing page
  Como visitante
  Quiero traducir la página
  Para leer el contenido en mi idioma preferido

  Escenario: Cambiar idioma a español
    Dado que estoy en la landing page en inglés
    Cuando selecciono "Español" en el selector de idioma
    Entonces todo el contenido debe mostrarse en español
    Y la URL debe reflejar el cambio de idioma

  Escenario: Cambiar idioma a inglés
    Dado que estoy en la landing page en español
    Cuando selecciono "English" en el selector de idioma
    Entonces todo el contenido debe mostrarse en inglés
    Y el selector debe mostrar la opción activa

  Escenario: Persistir selección de idioma
    Dado que cambié el idioma a español
    Cuando recargo la página
    Entonces el idioma debe permanecer en español
    Y no debe volver al idioma por defecto

  Escenario: Idioma por defecto según navegador
    Dado que mi navegador está configurado en español
    Cuando accedo a la landing page por primera vez
    Entonces la página debe mostrarse en español automáticamente
    Y el selector debe reflejar la selección