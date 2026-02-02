-- =====================================================
-- SISTEMA 2: VENTA DE PRODUCTOS (RETAIL)
-- =====================================================
-- Base de datos: modulo_05_08
-- Objetivo: Crear tablas normalizadas para un sistema
--           de e-commerce con 6 entidades.

-- =====================================================
-- ANÁLISIS ER Y NORMALIZACIÓN
-- =====================================================

-- Entidades identificadas:
-- 1. CLIENTE      → Personas que compran
-- 2. CATEGORÍA    → Clasificación de productos
-- 3. PRODUCTO     → Artículos disponibles (1:N con Categoría)
-- 4. PEDIDO       → Órdenes de compra (1:N con Cliente)
-- 5. DETALLE_PEDIDO → Items en pedido (M:N entre Pedido-Producto)
-- 6. PAGO         → Pagos de pedidos (1:1 con Pedido)

-- Relaciones:
-- Cliente (1) -----> (N) Pedido
-- Categoría (1) -----> (N) Producto
-- Pedido (1) -----> (N) Detalle_Pedido (con PK compuesta)
-- Producto (1) -----> (N) Detalle_Pedido
-- Pedido (1) -----> (1) Pago

-- Cardinalidades: 1:1, 1:N, M:N
-- Normalización: Todas las tablas cumplen 3FN

-- =====================================================
-- CREAR TABLAS (DDL)
-- =====================================================

-- Tabla 1: CLIENTE
DROP TABLE IF EXISTS cliente_retail CASCADE;

CREATE TABLE cliente_retail (
  id_cliente SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  telefono VARCHAR(20) NOT NULL,
  direccion TEXT NOT NULL,
  ciudad VARCHAR(50) NOT NULL,
  fecha_registro DATE NOT NULL DEFAULT CURRENT_DATE
);

-- Tabla 2: CATEGORÍA
DROP TABLE IF EXISTS categoria CASCADE;

CREATE TABLE categoria (
  id_categoria SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL UNIQUE,
  descripcion TEXT
);

-- Tabla 3: PRODUCTO (1:N con Categoría)
DROP TABLE IF EXISTS producto CASCADE;

CREATE TABLE producto (
  id_producto SERIAL PRIMARY KEY,
  id_categoria INT NOT NULL REFERENCES categoria(id_categoria) ON DELETE RESTRICT,
  nombre VARCHAR(150) NOT NULL,
  descripcion TEXT,
  precio NUMERIC(10, 2) NOT NULL CHECK (precio > 0),
  cantidad_stock INT NOT NULL DEFAULT 0 CHECK (cantidad_stock >= 0),
  fecha_creacion DATE NOT NULL DEFAULT CURRENT_DATE
);

-- Tabla 4: PEDIDO (1:N con Cliente)
DROP TABLE IF EXISTS pedido CASCADE;

CREATE TABLE pedido (
  id_pedido SERIAL PRIMARY KEY,
  id_cliente INT NOT NULL REFERENCES cliente_retail(id_cliente) ON DELETE CASCADE,
  fecha_pedido DATE NOT NULL DEFAULT CURRENT_DATE,
  estado VARCHAR(50) NOT NULL DEFAULT 'Pendiente' CHECK (estado IN ('Pendiente', 'Confirmado', 'Enviado', 'Entregado', 'Cancelado')),
  total_pedido NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (total_pedido >= 0)
);

-- Tabla 5: DETALLE_PEDIDO (M:N entre Pedido y Producto)
-- Esta tabla maneja la relación muchos-a-muchos
DROP TABLE IF EXISTS detalle_pedido CASCADE;

CREATE TABLE detalle_pedido (
  id_pedido INT NOT NULL REFERENCES pedido(id_pedido) ON DELETE CASCADE,
  id_producto INT NOT NULL REFERENCES producto(id_producto) ON DELETE RESTRICT,
  cantidad INT NOT NULL CHECK (cantidad > 0),
  precio_unitario NUMERIC(10, 2) NOT NULL CHECK (precio_unitario > 0),
  subtotal NUMERIC(12, 2) NOT NULL CHECK (subtotal > 0),
  PRIMARY KEY (id_pedido, id_producto)
);

-- Tabla 6: PAGO (1:1 con Pedido)
DROP TABLE IF EXISTS pago CASCADE;

CREATE TABLE pago (
  id_pago SERIAL PRIMARY KEY,
  id_pedido INT NOT NULL UNIQUE REFERENCES pedido(id_pedido) ON DELETE CASCADE,
  tipo_pago VARCHAR(50) NOT NULL CHECK (tipo_pago IN ('Tarjeta Débito', 'Tarjeta Crédito', 'Transferencia', 'Efectivo')),
  fecha_pago DATE NOT NULL,
  monto NUMERIC(12, 2) NOT NULL CHECK (monto > 0),
  estado_pago VARCHAR(50) NOT NULL DEFAULT 'Pendiente' CHECK (estado_pago IN ('Pendiente', 'Completado', 'Rechazado'))
);

-- =====================================================
-- INSERTAR DATOS DE PRUEBA
-- =====================================================

-- Datos de prueba para CLIENTE_RETAIL
INSERT INTO cliente_retail (nombre, email, telefono, direccion, ciudad) VALUES
('Ana Martínez', 'ana.martinez@email.com', '912345678', 'Calle 1 Nro 100', 'Concepción'),
('Bruno González', 'bruno.gonzalez@email.com', '987654321', 'Avenida 2 Nro 200', 'Talcahuano'),
('Carla Flores', 'carla.flores@email.com', '956789012', 'Calle 3 Nro 300', 'San Pedro de la Paz');

-- Datos de prueba para CATEGORÍA
INSERT INTO categoria (nombre, descripcion) VALUES
('Electrónica', 'Dispositivos electrónicos y accesorios'),
('Ropa', 'Prendas de vestir para hombre y mujer'),
('Libros', 'Libros físicos y digitales');

-- Datos de prueba para PRODUCTO
INSERT INTO producto (id_categoria, nombre, descripcion, precio, cantidad_stock) VALUES
(1, 'Monitor 24 pulgadas', 'Monitor Full HD 1920x1080', 250000, 15),
(1, 'Teclado Mecánico', 'Teclado gaming RGB', 120000, 30),
(2, 'Camiseta Básica', 'Camiseta 100% algodón', 15000, 50),
(2, 'Pantalones Jeans', 'Jeans denim azul oscuro', 45000, 25),
(3, 'Clean Code', 'Libro de programación', 45000, 12);

-- Datos de prueba para PEDIDO
INSERT INTO pedido (id_cliente, fecha_pedido, estado, total_pedido) VALUES
(1, '2026-02-01', 'Confirmado', 370000),
(2, '2026-02-02', 'Enviado', 515000),
(3, '2026-02-02', 'Pendiente', 60000);

-- Datos de prueba para DETALLE_PEDIDO
INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario, subtotal) VALUES
(1, 1, 1, 250000, 250000),    -- Pedido 1: 1 Monitor
(1, 5, 1, 45000, 45000),      -- Pedido 1: 1 Libro
(1, 3, 3, 15000, 45000),      -- Pedido 1: 3 Camisetas
(2, 2, 1, 120000, 120000),    -- Pedido 2: 1 Teclado
(2, 4, 1, 45000, 45000),      -- Pedido 2: 1 Pantalón
(2, 5, 7, 45000, 315000),     -- Pedido 2: 7 Libros
(3, 3, 4, 15000, 60000);      -- Pedido 3: 4 Camisetas

-- Datos de prueba para PAGO
INSERT INTO pago (id_pedido, tipo_pago, fecha_pago, monto, estado_pago) VALUES
(1, 'Tarjeta Crédito', '2026-02-01', 370000, 'Completado'),
(2, 'Transferencia', '2026-02-02', 515000, 'Completado'),
(3, 'Tarjeta Débito', '2026-02-03', 60000, 'Pendiente');

-- =====================================================
-- CONSULTAS DE VERIFICACIÓN
-- =====================================================

-- Verificar tabla CLIENTE_RETAIL
SELECT * FROM cliente_retail;

-- Verificar tabla CATEGORÍA
SELECT * FROM categoria;

-- Verificar tabla PRODUCTO
SELECT * FROM producto;

-- Verificar tabla PEDIDO
SELECT * FROM pedido;

-- Verificar tabla DETALLE_PEDIDO
SELECT * FROM detalle_pedido;

-- Verificar tabla PAGO
SELECT * FROM pago;

-- Consulta JOIN: Pedidos de clientes con detalles
SELECT 
  c.nombre AS cliente,
  p.id_pedido,
  p.fecha_pedido,
  p.estado,
  p.total_pedido
FROM pedido p
JOIN cliente_retail c ON p.id_cliente = c.id_cliente
ORDER BY p.id_pedido;

-- Consulta JOIN: Detalles completos de cada pedido
SELECT 
  p.id_pedido,
  c.nombre AS cliente,
  pr.nombre AS producto,
  dp.cantidad,
  dp.precio_unitario,
  dp.subtotal,
  cat.nombre AS categoria
FROM detalle_pedido dp
JOIN pedido p ON dp.id_pedido = p.id_pedido
JOIN cliente_retail c ON p.id_cliente = c.id_cliente
JOIN producto pr ON dp.id_producto = pr.id_producto
JOIN categoria cat ON pr.id_categoria = cat.id_categoria
ORDER BY p.id_pedido, pr.nombre;

-- Consulta: Resumen de pagos por pedido
SELECT 
  pag.id_pago,
  pag.id_pedido,
  ped.total_pedido,
  pag.tipo_pago,
  pag.monto,
  pag.estado_pago,
  (pag.monto - ped.total_pedido) AS diferencia
FROM pago pag
JOIN pedido ped ON pag.id_pedido = ped.id_pedido
JOIN cliente_retail c ON ped.id_cliente = c.id_cliente
ORDER BY pag.id_pago;
