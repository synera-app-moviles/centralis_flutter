# language: es
Característica: Eliminación de chats grupales por gerentes
  Como gerente
  Quiero eliminar chats grupales obsoletos o inactivos
  Para mantener la lista de chats organizada y relevante

  Escenario: Eliminar chat grupal obsoleto
    Dado que soy un gerente autenticado
    Y existe un chat grupal "Proyecto 2023" que ya no es relevante
    Y el último mensaje fue enviado hace más de 6 meses
    Cuando elimino el chat grupal
    Entonces el chat debe ser eliminado exitosamente
    Y debe desaparecer de todas las listas de participantes

  Escenario: Confirmar eliminación de chat activo
    Dado que soy un gerente autenticado
    Y existe un chat grupal "Marketing Activo" con mensajes recientes
    Cuando intento eliminar el chat
    Entonces debo ver una advertencia sobre la actividad reciente
    Y debo confirmar explícitamente la eliminación

  Escenario: Archivar en lugar de eliminar chat importante
    Dado que soy un gerente autenticado
    Y existe un chat grupal "Decisiones Importantes" con historial valioso
    Cuando selecciono archivar en lugar de eliminar
    Entonces el chat debe moverse a "Archivados"
    Y debe ser recuperable posteriormente

  Escenario: Verificar permisos para eliminación
    Dado que soy un empleado con permisos limitados
    Y existe un chat grupal que quisiera eliminar
    Cuando intento eliminar el chat
    Entonces debo recibir un error de permisos insuficientes
    Y el chat debe permanecer activo