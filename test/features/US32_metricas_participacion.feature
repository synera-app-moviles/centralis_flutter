# language: es
Característica: Métricas de participación
  Como gerente
  Quiero ver métricas de participación en eventos
  Para medir el engagement del equipo

  Escenario: Ver métricas básicas de evento
    Dado que soy un gerente autenticado
    Y existe un evento "Capacitación" con 20 invitados
    Y 15 empleados confirmaron asistencia
    Cuando veo las métricas del evento
    Entonces debo ver "75% de confirmaciones"
    Y debo ver el número total de invitados

  Escenario: Ver métricas por departamento
    Dado que soy un gerente autenticado
    Y existe un evento con invitados de "IT" y "Marketing"
    Y tengo diferentes tasas de confirmación por departamento
    Cuando veo las métricas detalladas
    Entonces debo ver el porcentaje de confirmación por departamento
    Y debo ver gráficos comparativos

  Escenario: Ver historial de participación
    Dado que soy un gerente autenticado
    Y existen eventos pasados con datos de participación
    Cuando accedo al dashboard de métricas
    Entonces debo ver tendencias de participación
    Y debo ver empleados con mayor/menor engagement

  Escenario: Exportar reporte de métricas
    Dado que soy un gerente autenticado
    Y existen métricas de múltiples eventos
    Cuando solicito exportar el reporte
    Entonces debo poder descargar un archivo con las métricas
    Y el archivo debe incluir datos detallados por evento y empleado