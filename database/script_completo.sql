-- ==========================================
-- SCRIPT DE CREACIÓN: PANADERÍA COZI
-- ==========================================

-- 1. LIMPIEZA TOTAL (Orden inverso para evitar errores)
DROP USER IF EXISTS 'usuario_cajero'@'localhost';
DROP USER IF EXISTS 'usuario_dueno'@'localhost';
DROP ROLE IF EXISTS 'cajero_panaderia', 'dueno_panaderia';
DROP DATABASE IF EXISTS panaderia;

-- 2. CREACIÓN DE LA BASE DE DATOS
CREATE DATABASE panaderia;
USE panaderia;

-- ==========================================
-- 3. CREACIÓN DE TABLAS (DDL)
-- ==========================================

CREATE TABLE CATEGORIAS (
    ID_Categoria INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL
);

CREATE TABLE PROVEEDORES (
    ID_Proveedor INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Telefono VARCHAR(20)
);

CREATE TABLE PRODUCTOS (
    ID_Producto INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    ID_Categoria INT NOT NULL,
    ID_Proveedor INT NOT NULL,
    Tipo_Venta VARCHAR(20) NOT NULL CHECK (Tipo_Venta IN ('UNIDAD', 'PESABLE', 'DOCENA')),
    Factor_Conversion INT NOT NULL DEFAULT 1,
    Stock_Base INT NOT NULL DEFAULT 0 CHECK (Stock_Base >= 0),
    Precio_Actual DECIMAL(10,2) NOT NULL CHECK (Precio_Actual > 0),
    Dias_Vida_Util INT NOT NULL DEFAULT 1,
    FOREIGN KEY (ID_Categoria) REFERENCES CATEGORIAS(ID_Categoria),
    FOREIGN KEY (ID_Proveedor) REFERENCES PROVEEDORES(ID_Proveedor)
);

CREATE TABLE HISTORIAL_PRECIOS (
    ID_Historial INT AUTO_INCREMENT PRIMARY KEY,
    ID_Producto INT NOT NULL,
    Fecha_Desde DATETIME DEFAULT CURRENT_TIMESTAMP,
    Precio DECIMAL(10,2) NOT NULL CHECK (Precio > 0),
    FOREIGN KEY (ID_Producto) REFERENCES PRODUCTOS(ID_Producto) ON DELETE CASCADE
);

CREATE TABLE CLIENTES (
    ID_Cliente INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Telefono VARCHAR(20)
);

CREATE TABLE VENTAS (
    ID_Venta INT AUTO_INCREMENT PRIMARY KEY,
    Fecha_Hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    ID_Cliente INT NOT NULL,
    Total DECIMAL(10,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (ID_Cliente) REFERENCES CLIENTES(ID_Cliente)
);

CREATE TABLE DETALLE_VENTAS (
    ID_Detalle INT AUTO_INCREMENT PRIMARY KEY,
    ID_Venta INT NOT NULL,
    ID_Producto INT NOT NULL,
    Cantidad_Vendida DECIMAL(10,2) NOT NULL CHECK (Cantidad_Vendida > 0),
    Precio_Unitario DECIMAL(10,2) NOT NULL CHECK (Precio_Unitario > 0),
    FOREIGN KEY (ID_Venta) REFERENCES VENTAS(ID_Venta) ON DELETE CASCADE,
    FOREIGN KEY (ID_Producto) REFERENCES PRODUCTOS(ID_Producto)
);

CREATE TABLE COMPRAS (
    ID_Compra INT AUTO_INCREMENT PRIMARY KEY,
    ID_Proveedor INT NOT NULL,
    Fecha_Hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    Total DECIMAL(10,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (ID_Proveedor) REFERENCES PROVEEDORES(ID_Proveedor)
);

CREATE TABLE DETALLE_COMPRAS (
    ID_Detalle_Compra INT AUTO_INCREMENT PRIMARY KEY,
    ID_Compra INT NOT NULL,
    ID_Producto INT NOT NULL,
    Cantidad DECIMAL(10,2) NOT NULL CHECK (Cantidad > 0),
    Precio_Costo DECIMAL(10,2) NOT NULL CHECK (Precio_Costo > 0),
    Fecha_Vencimiento DATE,
    FOREIGN KEY (ID_Compra) REFERENCES COMPRAS(ID_Compra) ON DELETE CASCADE,
    FOREIGN KEY (ID_Producto) REFERENCES PRODUCTOS(ID_Producto)
);

CREATE TABLE MERMAS (
    ID_Merma INT AUTO_INCREMENT PRIMARY KEY,
    ID_Producto INT NOT NULL,
    Fecha_Hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    Cantidad DECIMAL(10,2) NOT NULL CHECK (Cantidad > 0),
    Motivo VARCHAR(50) NOT NULL CHECK (Motivo IN ('Vencimiento', 'Deterioro', 'Hurto', 'Error administrativo')),
    FOREIGN KEY (ID_Producto) REFERENCES PRODUCTOS(ID_Producto)
);

-- ==========================================
-- 4. DATOS DE PRUEBA (DML)
-- ==========================================

INSERT INTO CATEGORIAS (Nombre) VALUES 
('Panificados'), ('Facturas'), ('Pastelería'), ('Bebidas'), ('Kiosco');

INSERT INTO PROVEEDORES (Nombre, Telefono) VALUES 
('Molino Córdoba', '351-1234567'),
('Distribuidora Láctea', '351-9876543'),
('Coca-Cola Andina', '0800-333-4444');

INSERT INTO PRODUCTOS (Nombre, ID_Categoria, ID_Proveedor, Tipo_Venta, Factor_Conversion, Stock_Base, Precio_Actual, Dias_Vida_Util) VALUES 
('Pan Francés', 1, 1, 'PESABLE', 1000, 50000, 800.00, 1),
('Pan de Miga', 1, 1, 'PESABLE', 1000, 20000, 1200.00, 2),
('Medialunas de Manteca', 2, 1, 'DOCENA', 12, 120, 4500.00, 1),
('Torta de Chocolate', 3, 2, 'UNIDAD', 1, 4, 5200.00, 5),
('Coca Cola 1.5L', 4, 3, 'UNIDAD', 1, 24, 2500.00, 180),
('Alfajor Triple', 5, 2, 'UNIDAD', 1, 50, 1200.00, 90);

INSERT INTO CLIENTES (Nombre, Telefono) VALUES 
('Juan Pérez', '351-555-1111'),
('María Gómez', '351-555-2222'),
('Panadería Escolar', '351-555-3333');

-- ==========================================
-- 5. SEGURIDAD Y ROLES
-- ==========================================

CREATE ROLE 'cajero_panaderia', 'dueno_panaderia';

-- Permisos Cajero
GRANT SELECT ON panaderia.PRODUCTOS TO 'cajero_panaderia';
GRANT SELECT, INSERT ON panaderia.CLIENTES TO 'cajero_panaderia';
GRANT SELECT, INSERT ON panaderia.VENTAS TO 'cajero_panaderia';
GRANT SELECT, INSERT ON panaderia.DETALLE_VENTAS TO 'cajero_panaderia';
GRANT UPDATE (Stock_Base) ON panaderia.PRODUCTOS TO 'cajero_panaderia';

-- Permisos Dueño
GRANT ALL PRIVILEGES ON panaderia.* TO 'dueno_panaderia';

-- Crear Usuarios
CREATE USER 'usuario_cajero'@'localhost' IDENTIFIED BY '1234';
CREATE USER 'usuario_dueno'@'localhost' IDENTIFIED BY '1234';

GRANT 'cajero_panaderia' TO 'usuario_cajero'@'localhost';
GRANT 'dueno_panaderia' TO 'usuario_dueno'@'localhost';

SET DEFAULT ROLE ALL TO 'usuario_cajero'@'localhost';
SET DEFAULT ROLE ALL TO 'usuario_dueno'@'localhost';
FLUSH PRIVILEGES;

-- ==========================================
-- 6. SIMULACIÓN DE VENTAS Y COMPRAS
-- ==========================================

-- Ventas
INSERT INTO VENTAS (ID_Cliente, Total) VALUES (1, 6100.00);
SET @id_venta1 = LAST_INSERT_ID();
INSERT INTO DETALLE_VENTAS (ID_Venta, ID_Producto, Cantidad_Vendida, Precio_Unitario) VALUES 
(@id_venta1, 1, 2000, 800.00), (@id_venta1, 3, 12, 4500.00);
UPDATE PRODUCTOS SET Stock_Base = Stock_Base - 2000 WHERE ID_Producto = 1;
UPDATE PRODUCTOS SET Stock_Base = Stock_Base - 12 WHERE ID_Producto = 3;

INSERT INTO VENTAS (ID_Cliente, Total) VALUES (2, 10200.00);
SET @id_venta2 = LAST_INSERT_ID();
INSERT INTO DETALLE_VENTAS (ID_Venta, ID_Producto, Cantidad_Vendida, Precio_Unitario) VALUES 
(@id_venta2, 4, 1, 5200.00), (@id_venta2, 5, 2, 2500.00);
UPDATE PRODUCTOS SET Stock_Base = Stock_Base - 1 WHERE ID_Producto = 4;
UPDATE PRODUCTOS SET Stock_Base = Stock_Base - 2 WHERE ID_Producto = 5;

INSERT INTO VENTAS (ID_Cliente, Total) VALUES (3, 4200.00);
SET @id_venta3 = LAST_INSERT_ID();
INSERT INTO DETALLE_VENTAS (ID_Venta, ID_Producto, Cantidad_Vendida, Precio_Unitario) VALUES 
(@id_venta3, 2, 500, 1200.00), (@id_venta3, 6, 3, 1200.00);
UPDATE PRODUCTOS SET Stock_Base = Stock_Base - 500 WHERE ID_Producto = 2;
UPDATE PRODUCTOS SET Stock_Base = Stock_Base - 3 WHERE ID_Producto = 6;

-- Compra simulada para la alerta de vencimiento
INSERT INTO COMPRAS (ID_Proveedor, Total) VALUES (2, 50000.00);
SET @id_compra = LAST_INSERT_ID();
INSERT INTO DETALLE_COMPRAS (ID_Compra, ID_Producto, Cantidad, Precio_Costo, Fecha_Vencimiento) VALUES 
(@id_compra, 6, 100, 800.00, DATE_ADD(CURDATE(), INTERVAL 1 DAY)), 
(@id_compra, 5, 50, 1500.00, DATE_ADD(CURDATE(), INTERVAL 2 DAY));