# language: es
Característica: Invitación a departamentos específicos
  Como gerente
  Quiero invitar a departamentos específicos a eventos
  Para asegurar que solo participen los empleados requeridos

  Escenario: Invitar departamento específico a evento
    Dado que soy un gerente autenticado
    Y existe un departamento "Marketing"
    Cuando creo un evento "Reunión trimestral" e invito solo al departamento "Marketing"
    Entonces el evento debe ser creado exitosamente
    Y solo los empleados de "Marketing" deben recibir la invitación

  Escenario: Invitar múltiples departamentos a evento
    Dado que soy un gerente autenticado
    Y existen los departamentos "IT" y "Ventas"
    Cuando creo un evento "Capacitación general" e invito a "IT" y "Ventas"
    Entonces el evento debe ser creado exitosamente
    Y solo los empleados de "IT" y "Ventas" deben recibir la invitación

  Escenario: Crear evento sin invitar departamentos
    Dado que soy un gerente autenticado
    Cuando creo un evento "Reunión general" sin especificar departamentos
    Entonces el evento debe ser creado exitosamente
    Y todos los empleados deben recibir la invitación

  Escenario: Intentar invitar departamento inexistente
    Dado que soy un gerente autenticado
    Cuando creo un evento e intento invitar al departamento "Inexistente"
    Entonces debo recibir un error de departamento no encontrado