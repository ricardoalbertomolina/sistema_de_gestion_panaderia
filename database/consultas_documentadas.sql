USE panaderia;

-- ==========================================
-- CONSULTA 1: Reporte de Ventas con Datos del Cliente (JOIN)
-- ==========================================
-- Resuelve la necesidad de la caja de listar facturas. 
-- Usa un JOIN para unir ventas con clientes sin duplicar el nombre en cada venta.
SELECT 
    VENTAS.ID_Venta AS Nro_Factura, 
    CLIENTES.Nombre AS Cliente, 
    VENTAS.Fecha_Hora, 
    VENTAS.Total
FROM VENTAS
INNER JOIN CLIENTES ON VENTAS.ID_Cliente = CLIENTES.ID_Cliente
ORDER BY VENTAS.Fecha_Hora DESC;

-- ==========================================
-- CONSULTA 2: Stock Visible Traducido (CASE)
-- ==========================================
-- Convierte el stock base (gramos/unidades) a un formato legible (kilos/docenas).
SELECT 
    Nombre,
    Tipo_Venta,
    CASE 
        WHEN Tipo_Venta = 'PESABLE' THEN CONCAT(ROUND(Stock_Base / Factor_Conversion, 2), ' Kilos')
        WHEN Tipo_Venta = 'DOCENA' THEN CONCAT(ROUND(Stock_Base / Factor_Conversion, 2), ' Docenas')
        ELSE CONCAT(Stock_Base, ' Unidades')
    END AS Stock_Visible
FROM PRODUCTOS;

-- ==========================================
-- CONSULTA 3: Recaudación por Categoría (Agregación - SUM, COUNT)
-- ==========================================
-- Suma los ingresos reales (cantidad / factor * precio) agrupados por rubro.
SELECT 
    Cat.Nombre AS Categoria,
    COUNT(DV.ID_Detalle) AS Cantidad_Operaciones,
    ROUND(SUM((DV.Cantidad_Vendida / P.Factor_Conversion) * DV.Precio_Unitario), 2) AS Ingresos_Totales
FROM DETALLE_VENTAS DV
INNER JOIN PRODUCTOS P ON DV.ID_Producto = P.ID_Producto
INNER JOIN CATEGORIAS Cat ON P.ID_Categoria = Cat.ID_Categoria
GROUP BY Cat.Nombre
ORDER BY Ingresos_Totales DESC;

-- ==========================================
-- CONSULTA 4: Alerta de Productos por Vencer (Subconsulta)
-- ==========================================
-- Busca lotes que vencen en los próximos 3 días mediante una subconsulta.
SELECT Nombre, Stock_Base, Precio_Actual
FROM PRODUCTOS
WHERE ID_Producto IN (
    SELECT ID_Producto 
    FROM DETALLE_COMPRAS 
    WHERE Fecha_Vencimiento <= DATE_ADD(CURDATE(), INTERVAL 3 DAY)
);

-- ==========================================
-- CONSULTA 5: Top 3 Productos Más Vendidos (JOIN + Agregación + Subconsulta)
-- ==========================================
-- Identifica los productos estrella calculando la recaudación real.
SELECT 
    P.Nombre AS Producto,
    (SELECT Nombre FROM CATEGORIAS WHERE ID_Categoria = P.ID_Categoria) AS Categoria,
    ROUND(SUM(DV.Cantidad_Vendida / P.Factor_Conversion), 2) AS Total_Vendido,
    ROUND(SUM((DV.Cantidad_Vendida / P.Factor_Conversion) * DV.Precio_Unitario), 2) AS Recaudacion
FROM DETALLE_VENTAS DV
INNER JOIN PRODUCTOS P ON DV.ID_Producto = P.ID_Producto
GROUP BY P.ID_Producto, P.Nombre
ORDER BY Recaudacion DESC
LIMIT 3;