# Del dato al destino: 33 destinos, un solo viaje

Proyecto SQL: From Data to Insight · Ironhack · Ilaria Iannitelli y Adriana Rojas Rodríguez

## Introducción

Imaginamos que somos las responsables de una agencia de viajes con 33 destinos en el catálogo. Cuando un cliente pregunta «¿qué viaje me recomendáis?», la respuesta no debería depender de la intuición ni del gusto personal del agente. En este proyecto usamos SQL y Python para analizar clientes, reservas, tours, vuelos y seguros, y elegir un viaje que la agencia pueda recomendar con argumentos respaldados por datos.

## Datos y fuentes

- **Fuente:** [Travel Agency Management Database](https://databasesample.com/datasets/travel-agency-management-database) (databasesample.com).
- **Volumen:** 1.210 registros en cinco tablas relacionadas.
- **Naturaleza de los datos:** sintéticos y sin moneda indicada; los importes se interpretan como valores relativos.

| Tabla | Filas | Contenido |
| --- | --- | --- |
| customers | 200 | Clientes registrados (nombre, email, teléfono, país) |
| bookings | 380 | Reservas (cliente, tour, fecha, estado del pago, importe, canal) |
| tours | 50 | Tours disponibles (nombre, destino, duración, precio) |
| flights | 463 | Vuelos asociados a cada reserva |
| insurance | 117 | Seguros asociados a cada reserva |

Todas las tablas se relacionan a través de `bookings`: `customer_id` la une con `customers`, `tour_id` con `tours`, y `flights` e `insurance` dependen de cada reserva mediante `booking_id`.

## Preguntas de investigación

- **Pregunta principal:** ¿qué hace que un viaje merezca la pena y cuál deberíamos recomendar?
- **Pregunta secundaria:** ¿cuáles son los destinos más populares y qué factores influyen en su elección?

## Hipótesis y resultados

| Hipótesis | Resultado | Dato clave |
| --- | --- | --- |
| H1 · Algunos destinos concentran significativamente más reservas | Respaldada | Los 5 primeros de 33 destinos reúnen el 29,47 % de las reservas (chi-cuadrado p < 0,001) |
| H2 · Los tours más largos tienen precios más altos | No respaldada | Pearson r = 0,144; p = 0,318 |
| H3 · Los destinos más populares no son necesariamente los más caros | Respaldada | Spearman = −0,038 |
| H4 · El canal de contratación se
