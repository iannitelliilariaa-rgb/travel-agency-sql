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
| H4 · El canal de contratación se relaciona con el importe medio | No concluyente | ANOVA p = 0,606 |
| H5 · Los clientes recurrentes generan más importe acumulado | Respaldada | El 45,5 % de los clientes genera el 69,59 % del importe |
| H6 · Las reservas de mayor importe contratan más seguros | No respaldada | 33,53 % con seguro por debajo de 1.000 frente a 30,93 % desde 3.000 |
| H7 · Los destinos con más variedad de tours concentran más reservas | Respaldada | Spearman = 0,860; p < 0,001 |
| H8 · Los estados de pago varían según el canal | No concluyente | Chi-cuadrado p = 0,595 |

## Metodología

1. **Planificación:** organizamos las tareas y el reparto del trabajo en un [tablero Kanban de Trello](https://trello.com/invite/b/6b017cabdd6e8466bd2f83de/ATTI06f967975783e95de0447629a48f2d268FE7B5A1/proyecto-sql-agencia-de-viajes).
2. **Comprensión de los datos:** estudiamos el significado de cada columna de las cinco tablas.
3. **Modelo de datos:** dibujamos el diagrama entidad-relación (ERD) en MySQL Workbench y creamos las tablas con su tipo de dato (INTEGER para identificadores, VARCHAR para textos, DECIMAL(14,2) para precios e importes, DATE, TIMESTAMP y UUID).
4. **Limpieza:** convertimos cadenas vacías en NULL, normalizamos el texto, revisamos nulos y duplicados y comprobamos que no hubiera reservas huérfanas (sin cliente o sin tour).
5. **Carga:** cargamos las tablas en el orden de sus relaciones (primero `customers` y `tours`, después `bookings`, `flights` e `insurance`) para mantener la integridad referencial.
6. **Análisis en SQL:** una vista (`vw_booking_analysis`) que une reservas, clientes y tours, y 18 consultas con JOIN, GROUP BY, ORDER BY, CASE, subconsultas, CTE, NTILE y funciones ventana, más AVG, MIN, MAX y STDDEV_POP. Para contar seguros usamos `SELECT DISTINCT booking_id`, de modo que una reserva con varias pólizas cuenta una sola vez.
7. **Ranking de recomendación:** cada tour se puntúa de 0 a 100 en cuatro criterios normalizados con funciones ventana, ponderados así: reservas completadas 40 %, precio 25 %, tasa de finalización 20 % y tasa de seguro 15 %.
8. **Visualización y estadística:** exportamos los resultados a CSV y, en Python (pandas, matplotlib y seaborn), generamos 14 gráficos y las pruebas estadísticas (correlaciones, ANOVA y chi-cuadrado).

## Principales hallazgos

- **Viaje recomendado: Copenhague, tour Excursion group escape.** Obtiene la mejor puntuación del ranking (81,05 / 100): cuesta 202,83 por 11 días y se completaron 8 de sus 9 reservas (88,89 %).
- **Más reservas no significa mejor viaje.** Roma es el destino más reservado (27 reservas), pero su tour Nature queda segundo en el ranking (72,4) porque solo se completa el 50 % de sus reservas.
- **La demanda se concentra:** cinco de 33 destinos reúnen casi el 30 % de las reservas.
- **El precio va por libre:** no depende de la duración del viaje ni de la popularidad del destino.
- **Los clientes que repiten pesan mucho:** son el 45,5 % de los clientes y aportan el 69,59 % del importe, 2,74 veces más por cliente.
- **El seguro no depende del importe:** lo tiene el 30,79 % de las reservas, también las más baratas.

## Conclusiones: dos perspectivas

- **Para el viajero:** el viaje ideal es Copenhague con Excursion group escape, por precio y por probabilidad de que el viaje se complete.
- **Para la agencia:** los datos de clientes indican a quién ofrecerlo primero (clientes recurrentes y los diez que más han gastado, con más de 7.000 acumulados cada uno) y el canal indica por dónde llegar a ellos (la web reúne más de la mitad de las reservas completadas).

## Limitaciones

- No hay datos de edad, satisfacción, reseñas, costes, beneficio ni campañas, así que no medimos perfil del cliente, satisfacción ni rentabilidad.
- `booking_date` es la fecha de reserva, no la del viaje, y falta en muchos registros: no podemos hablar de temporada.
- Los importes incluyen todos los estados de pago, así que no equivalen a ingresos cobrados.
- Algunas consultas (destinos, canal, tours y top clientes) cuentan solo reservas completadas; el resto, todas las reservas.
- Los datos son sintéticos: las conclusiones ilustran el método, no un mercado real.

## Preguntas abiertas y próximos pasos

- Incorporar datos de costes para medir la rentabilidad de cada viaje.
- Añadir reseñas o valoraciones para medir la satisfacción.
- Conseguir la fecha real del viaje para estudiar la estacionalidad.
- Comprobar si ampliar el catálogo de tours en un destino aumenta sus reservas (hoy solo vemos asociación, no causalidad).
- Probar la sensibilidad del ranking a otros pesos.

## Estructura del repositorio

```
travel-agency-sql/
├── README.md
├── sql/            # creación de tablas, limpieza y analisis.sql
├── python/         # graficos.ipynb
├── data/           # CSV de resultados de las consultas
├── graficas/       # 14 gráficos en PNG
└── presentacion/   # Del_dato_al_destino_Proyecto_SQL.pdf
```

## Enlaces

- **Fuente de datos:** https://databasesample.com/datasets/travel-agency-management-database
- **Presentación (PDF):** [presentacion/Del_dato_al_destino_Proyecto_SQL.pdf](presentacion/Del_dato_al_destino_Proyecto_SQL.pdf)
- **Presentación en línea:** [AÑADIR ENLACE PÚBLICO A LAS DIAPOSITIVAS]
- **Tablero Kanban (Trello):** https://trello.com/invite/b/6b017cabdd6e8466bd2f83de/ATTI06f967975783e95de0447629a48f2d268FE7B5A1/proyecto-sql-agencia-de-viajes
