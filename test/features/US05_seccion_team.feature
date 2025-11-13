# language: es
Característica: Sección Team
  Como visitante
  Quiero conocer al equipo detrás de Centralis
  Para humanizar la marca y generar confianza

  Escenario: Ver información del equipo
    Dado que estoy en la landing page
    Cuando navego a la sección "Team"
    Entonces debo ver los perfiles de los miembros del equipo
    Y cada perfil debe incluir foto, nombre y rol

  Escenario: Ver detalles de miembro del equipo
    Dado que estoy en la sección "Team"
    Cuando hago clic en el perfil de un miembro
    Entonces debo ver información detallada del miembro
    Y debo ver su experiencia y especialidades

  Escenario: Contactar miembro del equipo
    Dado que estoy viendo el perfil de un miembro
    Cuando hago clic en "Contactar"
    Entonces debo poder enviar un mensaje
    Y debo ver opciones de contacto profesional

  Escenario: Ver equipo en diferentes dispositivos
    Dado que accedo a la sección Team desde móvil
    Cuando veo los perfiles del equipo
    Entonces la información debe adaptarse al tamaño de pantalla
    Y debe mantenerse la legibilidad