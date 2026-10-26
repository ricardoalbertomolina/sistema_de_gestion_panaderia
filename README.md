# Sistema de Gestión "Panadería Cozi"

Aplicación de escritorio para la gestión integral de la Panadería Cozi.

## Descripción del Proyecto

Este repositorio contiene el desarrollo de una aplicación de escritorio diseñada para digitalizar y centralizar la administración de productos, control de stock, registro de clientes, proveedores, compras y ventas. El objetivo principal es reemplazar los métodos manuales por una solución informática ágil, segura y auditable, que contemple las complejidades operativas reales de un comercio, como la venta de productos pesables, el control de vencimientos y la gestión de mermas.

El proyecto se enmarca en el Trabajo Integrador ABP (Aprendizaje Basado en Proyectos) del Módulo Programador, integrando los espacios curriculares de Programación I y Base de Datos de la Tecnicatura Superior en Desarrollo de Software.

## Tecnologías Utilizadas

*   **Lenguaje:** Python 3 (versión 3.10 o superior).
*   **Interfaz Gráfica:** Tkinter (biblioteca estándar) y ttk.
*   **Base de Datos:** PostgreSQL (o MySQL).
*   **Control de Versiones:** Git y GitHub.

## Arquitectura del Sistema y Modelo de Datos

Para garantizar la escalabilidad y la integridad de la información, se diseñó un modelo de datos relacional normalizado (hasta Tercera Forma Normal - 3FN). El sistema resuelve las siguientes lógicas de negocio:

### 1. Gestión de Stock Flexible (Unidades y Pesables)
El sistema contempla la venta de productos por unidad, por peso (ej. pan suelto) y por docena (ej. facturas). Para evitar errores de inventario, se implementa una **unidad de stock base** (gramos para pesables, unidades para el resto) y un **factor de conversión**. Al registrar una operación, el sistema descuenta o suma automáticamente del stock base según la cantidad y el formato seleccionado.

### 2. Historial de Precios Inmutable
Para evitar la pérdida de información histórica, los precios de venta no se sobrescriben. Se implementa una tabla de `Historial_Precios` que registra cada actualización con su fecha correspondiente. Asimismo, las tablas de detalles de venta almacenan el precio unitario exacto al momento de la transacción, garantizando la consistencia de las facturas ante futuros aumentos.

### 3. Trazabilidad de Compras y Control de Vencimientos
El sistema permite registrar el ingreso de mercadería a través del módulo de Compras. Dado que todos los productos tienen una vida útil determinada, cada producto cuenta con una estimación de `Dias_Vida_Util` (ej. 1 día para el pan, 180 para alfajores, 365 para bebidas). Al registrar una compra, el sistema calcula automáticamente la fecha de vencimiento del lote, la cual puede ser ajustada por el usuario según lo indique el envase físico. Esto permite mantener una trazabilidad exacta por lote y generar alertas tempranas para evitar pérdidas.

### 4. Registro de Mermas
Para un control de pérdidas real, el sistema incluye un módulo de Mermas. Cuando un producto se vence, se deteriora, es hurtado o sufre un error administrativo, no se borra del stock arbitrariamente; se registra una merma con un motivo estricto validado por la base de datos. Esto permite auditar las pérdidas y ajustar el stock de manera transparente, evitando que el inventario se desincronice.

### 5. Seguridad y Roles de Acceso (SGBD)
Siguiendo los lineamientos de la cátedra, la seguridad se delega directamente al motor de base de datos, sin implementar un sistema de contraseñas a nivel de aplicación. Se definen dos roles con privilegios diferenciados:
*   **Rol Cajero:** Orientado a la atención al público. Tiene permisos de lectura sobre productos (para consultar precios y stock), y permisos de inserción en clientes y ventas. Puede actualizar el stock al concretar una venta, pero tiene denegado el acceso a la modificación de precios, compras, mermas y eliminación de registros.
*   **Rol Dueño/Administrador:** Orientado a la gestión del comercio. Posee permisos totales sobre el esquema. Es el único autorizado para registrar compras, dar de baja mercadería por mermas, actualizar precios en el historial y eliminar registros.

### 6. Estructura de Entidades
El modelo de base de datos está compuesto por las siguientes entidades principales:

*   **Categorías:** Clasificación de los productos (ej. Panificados, Pastelería, Bebidas).
*   **Proveedores:** Empresas o personas que abastecen el local.
*   **Productos:** Artículos en venta, configurados con su unidad de venta, factor de conversión y días de vida útil estimados.
*   **Historial_Precios:** Registro cronológico de los costos de venta de cada producto.
*   **Clientes:** Datos de contacto de los compradores.
*   **Compras y Detalle_Compras:** Registro de ingreso de mercadería y fechas de vencimiento reales por lote.
*   **Ventas y Detalle_Ventas:** Registro de transacciones y productos vendidos (resolviendo la relación de muchos a muchos).
*   **Mermas:** Registro de bajas de stock por pérdidas (vencimiento, deterioro, hurto, error administrativo).

## Construcción de la Base de Datos y Lógica de Consultas

El diseño y la implementación de la base de datos se realizaron siguiendo los principios de normalización (hasta 3FN) para evitar la redundancia de datos y garantizar la integridad referencial. A continuación, se detallan las decisiones técnicas más relevantes del script SQL y de las consultas documentadas.

### 1. Decisiones de Diseño (Script DDL)
*   **Uso de `AUTO_INCREMENT`:** Todas las claves primarias se definieron como enteros autoincrementales. Esto delega al motor de la base de datos la generación de identificadores únicos, evitando colisiones de datos y simplificando el código de Python al momento de insertar nuevos registros.
*   **Restricciones `CHECK`:** Se implementaron validaciones a nivel de motor para proteger la lógica del negocio. Por ejemplo, se restringió el campo `Tipo_Venta` a solo tres opciones ('UNIDAD', 'PESABLE', 'DOCENA'), se impidió que el `Stock_Base` sea menor a cero y se limitaron los motivos de merma a un listado cerrado. Esto evita que datos "basura" ingresen al sistema, incluso si el programa de Python falla.
*   **Integridad Referencial (`FOREIGN KEY`):** Las tablas transaccionales (como `DETALLE_VENTAS` y `DETALLE_COMPRAS`) dependen estrictamente de las tablas maestras (`PRODUCTOS`, `VENTAS`, `COMPRAS`). Se utilizó la cláusula `ON DELETE CASCADE` en las tablas de detalle para que, si se elimina una venta o compra por error, sus renglones asociados se borren automáticamente y no queden "huérfanos" en la base.

### 2. Lógica de las Consultas SQL Documentadas
Las consultas fueron diseñadas para resolver problemáticas reales de gestión de la panadería, demostrando el uso de herramientas avanzadas de SQL:

*   **Consulta 1 (JOIN básico):** Resuelve el reporte de facturación diaria cruzando la tabla de `VENTAS` con `CLIENTES`. Se utiliza un `INNER JOIN` para mostrar el nombre del cliente en lugar de su ID numérico, facilitando la lectura del reporte de caja.
*   **Consulta 2 (Uso de `CASE` y cálculo matemático):** Debido a que el sistema almacena el stock en su unidad base (gramos para productos pesables), esta consulta traduce ese número a un formato legible para el usuario (kilos o docenas). Se utiliza una estructura condicional `CASE` que divide el stock por el factor de conversión del producto, permitiendo al dueño saber exactamente cuántos kilos de pan o docenas de facturas le quedan.
*   **Consulta 3 (Funciones de agregación):** Utiliza `COUNT` y `SUM` junto con un `GROUP BY` sobre las categorías. Esta consulta es de vital importancia para la toma de decisiones gerenciales, ya que permite identificar qué rubro del negocio (panificados, pastelería, bebidas) genera mayores ingresos. Al igual que en la consulta anterior, se aplica la división por el factor de conversión para que la suma de dinero sea exacta y no calcule gramos como si fueran kilos.
*   **Consulta 4 (Subconsulta y control de vencimientos):** Implementa una subconsulta dentro de un `WHERE ... IN`. Primero, busca en la tabla `DETALLE_COMPRAS` todos los lotes de mercadería cuya fecha de vencimiento esté a 3 días o menos de la fecha actual (usando la función `DATE_ADD`). Luego, con ese resultado, busca en la tabla `PRODUCTOS` cuáles son los artículos afectados. Esta consulta es la base del sistema de alertas tempranas para evitar mermas por vencimiento.
*   **Consulta 5 (JOIN, agregación y subconsulta combinados):** Es la consulta más compleja y representa un reporte de rendimiento comercial. Cruza las ventas con los productos, calcula la recaudación total por producto y utiliza una subconsulta en el `SELECT` para traer el nombre de la categoría. Finalmente, ordena los resultados de mayor a menor (`ORDER BY ... DESC`) y limita la salida a los 3 primeros (`LIMIT 3`), identificando los productos estrella de la panadería.

### 3. Seguridad y Roles en el SGBD
Siguiendo las buenas prácticas de administración de bases de datos, no se implementó un sistema de contraseñas a nivel de aplicación. En su lugar, se crearon dos roles directamente en MySQL:
*   **`cajero_panaderia`**: Restringido a leer productos, registrar clientes y asentar ventas. Tiene prohibido modificar precios o alterar la estructura.
*   **`dueno_panaderia`**: Con permisos totales sobre el esquema, encargado de la gestión de compras, mermas y actualización de precios.
Esto garantiza que, independientemente de la interfaz que use el empleado, el motor de la base de datos proteja la información sensible.


## Estado del Proyecto

*   [x] Diseño del modelo Entidad-Relación ampliado y normalización (3FN).
*   [x] Implementación del esquema en el SGBD (Script DDL) y definición de roles de seguridad.
*   [x] Carga de datos de prueba (DML) y simulación de ventas/compras.
*   [x] Documentación de las 5 consultas SQL requeridas (JOIN, agregación, subconsultas).
*   [ ] Desarrollo de la interfaz gráfica (Tkinter).
*   [ ] Conexión e integración de operaciones CRUD y lógica de stock.

---
*Nota: Este documento se irá actualizando a medida que avance el desarrollo del proyecto.*
