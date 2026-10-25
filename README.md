# sistema_de_gestion_panaderia
aplicación de escritorio para la gestión integral de la Panadería

Este repositorio contiene el desarrollo de una aplicación de escritorio para la gestión integral de la Panadería Cozi. El sistema está diseñado para digitalizar la administración de productos, control de stock, registro de clientes, proveedores y ventas, reemplazando los métodos manuales por una solución informática centralizada, ágil y segura.

El proyecto se enmarca en el Trabajo Integrador ABP (Aprendizaje Basado en Proyectos) del Módulo Programador, integrando los espacios curriculares de Programación I y Base de Datos de la Tecnicatura Superior en Desarrollo de Software.

Tecnologías Utilizadas
Lenguaje: Python 3 (versión 3.10 o superior).

Interfaz Gráfica: Tkinter (biblioteca estándar) y ttk.

Base de Datos: PostgreSQL (o MySQL).

Control de Versiones: Git y GitHub.

Arquitectura del Sistema y Modelo de Datos
Para garantizar la escalabilidad y la integridad de la información, se diseñó un modelo de datos relacional normalizado (hasta Tercera Forma Normal - 3FN). El sistema resuelve las siguientes lógicas de negocio:

1. Gestión de Stock Flexible
El sistema contempla la venta de productos por unidad, por peso (ej. pan) y por docena (ej. facturas). Para evitar errores de inventario, se implementa una unidad de stock base (gramos para pesables, unidades para el resto) y un factor de conversión. Al registrar una venta, el sistema descuenta automáticamente del stock base según la cantidad y el formato de venta seleccionado.

2. Historial de Precios
Para evitar la pérdida de información histórica, los precios de los productos no se sobrescriben. Se implementa una tabla de Historial_Precios que registra cada actualización con su fecha correspondiente. Asimismo, la tabla de detalles de venta almacena el precio unitario exacto al momento de la transacción, garantizando la consistencia de las facturas ante futuros aumentos.

3. Estructura de Entidades
El modelo de base de datos está compuesto por las siguientes entidades principales:

Categorías: Clasificación de los productos (ej. Panificados, Pastelería).

Proveedores: Empresas o personas que abastecen el local.

Productos: Artículos en venta, vinculados a una categoría y a un proveedor.

Historial_Precios: Registro cronológico de los costos de cada producto.

Clientes: Datos de contacto de los compradores.

Ventas: Cabecera de la transacción (cliente, fecha, total).

Detalle_Ventas: Tabla intermedia que resuelve la relación de muchos a muchos, detallando qué productos se vendieron en cada factura, la cantidad y el precio aplicado.
