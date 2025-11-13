# language: es
Característica: Eventos prioritarios
  Como gerente
  Quiero marcar eventos como prioritarios
  Para que los empleados les presten especial atención

  Escenario: Marcar evento como prioritario
    Dado que soy un gerente autenticado
    Y existe un evento "Reunión urgente"
    Cuando marco el evento como prioritario
    Entonces el evento debe mostrar un indicador de prioridad
    Y debe aparecer destacado en la lista de eventos

  Escenario: Quitar prioridad de evento
    Dado que soy un gerente autenticado
    Y existe un evento prioritario "Junta directiva"
    Cuando quito la prioridad del evento
    Entonces el evento debe perder el indicador de prioridad
    Y debe aparecer como evento normal

  Escenario: Ver eventos prioritarios destacados
    Dado que soy un empleado autenticado
    Y existen eventos prioritarios y normales
    Cuando veo la lista de eventos
    Entonces los eventos prioritarios deben aparecer al principio
    Y deben tener un indicador visual distintivo

  Escenario: Notificación especial para eventos prioritarios
    Dado que soy un empleado autenticado
    Y se crea un evento prioritario "Emergencia"
    Cuando recibo la notificación del evento
    Entonces la notificación debe indicar que es prioritario
    Y debe tener mayor prominencia visual