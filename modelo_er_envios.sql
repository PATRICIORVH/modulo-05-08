-- =====================================================
-- SISTEMA 1: ENVÍO DE ENCOMIENDAS
-- =====================================================
-- Base de datos: modulo_05_08
-- Objetivo: Crear tablas normalizadas para un sistema
--           de envío de encomiendas con 4 entidades.

-- =====================================================
-- PASO 1: ANÁLISIS ER Y NORMALIZACIÓN
-- =====================================================

-- Entidades identificadas:
-- 1. CLIENTE    → Personas que envían encomiendas
-- 2. SUCURSAL   → Puntos de envío y recepción
-- 3. ENCOMIENDA → Paquetes a enviar (1:N con Cliente)
-- 4. ENVÍO      → Registro de despacho (1:1 con Encomienda)

-- Relaciones:
-- Cliente (1) -----> (N) Encomienda
-- Encomienda (1) -----> (1) Envío
-- Sucursal (1) -----> (N) Envío (origen)
-- Sucursal (1) -----> (N) Envío (destino)

-- Cardinalidades: 1:1, 1:N
-- Normalización: Todas las tablas cumplen 3FN

-- =====================================================
-- PASO 2: CREAR TABLAS (DDL)
-- =====================================================

-- Tabla 1: CLIENTE (entidad)
-- Atributos: id_cliente, nombre, email, teléfono, dirección, ciudad
-- PK: id_cliente
-- Restricciones: email UNIQUE, NOT NULL en campos obligatorios

DROP TABLE IF EXISTS cliente CASCADE;

CREATE TABLE cliente (
  id_cliente SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  telefono VARCHAR(20) NOT NULL,
  direccion TEXT NOT NULL,
  ciudad VARCHAR(50) NOT NULL
);

-- Tabla 2: SUCURSAL (entidad)
-- Atributos: id_sucursal, nombre, ciudad, dirección, teléfono
-- PK: id_sucursal
-- Restricciones: NOT NULL en campos obligatorios

DROP TABLE IF EXISTS sucursal CASCADE;

CREATE TABLE sucursal (
  id_sucursal SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  ciudad VARCHAR(50) NOT NULL,
  direccion TEXT NOT NULL,
  telefono VARCHAR(20) NOT NULL
);

-- Tabla 3: ENCOMIENDA (entidad, depende de CLIENTE)
-- Atributos: id_encomienda, id_cliente (FK), descripción, peso, valor_declarado, 
--            fecha_creacion, estado
-- PK: id_encomienda
-- FK: id_cliente REFERENCES cliente(id_cliente)
-- Restricciones: peso > 0, valor_declarado >= 0, CHECK para estado

DROP TABLE IF EXISTS encomienda CASCADE;

CREATE TABLE encomienda (
  id_encomienda SERIAL PRIMARY KEY,
  id_cliente INT NOT NULL REFERENCES cliente(id_cliente) ON DELETE CASCADE,
  descripcion TEXT NOT NULL,
  peso NUMERIC(10, 2) NOT NULL CHECK (peso > 0),
  valor_declarado NUMERIC(12, 2) NOT NULL DEFAULT 0 CHECK (valor_declarado >= 0),
  fecha_creacion DATE NOT NULL DEFAULT CURRENT_DATE,
  estado VARCHAR(50) NOT NULL DEFAULT 'Pendiente' CHECK (estado IN ('Pendiente', 'Enviado', 'Entregado', 'Cancelado'))
);

-- Tabla 4: ENVÍO (entidad, depende de ENCOMIENDA y SUCURSAL)
-- Atributos: id_envio, id_encomienda (FK UNIQUE), id_sucursal_origen (FK), 
--            id_sucursal_destino (FK), fecha_envio, costo
-- PK: id_envio
-- FK: id_encomienda REFERENCES encomienda(id_encomienda) - ÚNICA (relación 1:1)
-- FK: id_sucursal_origen REFERENCES sucursal(id_sucursal)
-- FK: id_sucursal_destino REFERENCES sucursal(id_sucursal)
-- Restricciones: costo > 0, fecha_envio >= fecha_creacion

DROP TABLE IF EXISTS envio CASCADE;

CREATE TABLE envio (
  id_envio SERIAL PRIMARY KEY,
  id_encomienda INT NOT NULL UNIQUE REFERENCES encomienda(id_encomienda) ON DELETE CASCADE,
  id_sucursal_origen INT NOT NULL REFERENCES sucursal(id_sucursal) ON DELETE RESTRICT,
  id_sucursal_destino INT NOT NULL REFERENCES sucursal(id_sucursal) ON DELETE RESTRICT,
  fecha_envio DATE NOT NULL,
  costo NUMERIC(10, 2) NOT NULL CHECK (costo > 0)
);

-- =====================================================
-- PASO 3: INSERTAR DATOS DE PRUEBA
-- =====================================================

-- Datos de prueba para CLIENTE
INSERT INTO cliente (nombre, email, telefono, direccion, ciudad) VALUES
('Juan Pérez', 'juan.perez@email.com', '912345678', 'Calle Principal 123', 'Concepción'),
('María García', 'maria.garcia@email.com', '987654321', 'Avenida Central 456', 'Talcahuano'),
('Carlos López', 'carlos.lopez@email.com', '956789012', 'Pasaje Norte 789', 'San Pedro de la Paz');

-- Datos de prueba para SUCURSAL
INSERT INTO sucursal (nombre, ciudad, direccion, telefono) VALUES
('Sucursal Centro', 'Concepción', 'Calle O''Higgins 100', '222100100'),
('Sucursal Talcahuano', 'Talcahuano', 'Avenida Merino 200', '222200200'),
('Sucursal San Pedro', 'San Pedro de la Paz', 'Calle Chacabuco 300', '222300300');

-- Datos de prueba para ENCOMIENDA
INSERT INTO encomienda (id_cliente, descripcion, peso, valor_declarado, fecha_creacion, estado) VALUES
(1, 'Libro de programación', 1.50, 45000, '2026-02-01', 'Pendiente'),
(1, 'Ropa de invierno', 3.20, 75000, '2026-02-01', 'Pendiente'),
(2, 'Electrónica - monitor', 5.00, 250000, '2026-02-02', 'Enviado'),
(3, 'Documentos importantes', 0.50, 5000, '2026-02-02', 'Pendiente');

-- Datos de prueba para ENVÍO
INSERT INTO envio (id_encomienda, id_sucursal_origen, id_sucursal_destino, fecha_envio, costo) VALUES
(1, 1, 2, '2026-02-02', 5000),
(2, 1, 3, '2026-02-02', 6000),
(3, 1, 2, '2026-02-02', 8000),
(4, 2, 1, '2026-02-03', 4500);

-- =====================================================
-- PASO 4: CONSULTAS DE VERIFICACIÓN
-- =====================================================

-- Verificar la tabla CLIENTE
SELECT * FROM cliente;

-- Verificar la tabla SUCURSAL
SELECT * FROM sucursal;

-- Verificar la tabla ENCOMIENDA
SELECT * FROM encomienda;

-- Verificar la tabla ENVÍO
SELECT * FROM envio;

-- Consulta JOIN: Ver encomiendas con datos del cliente
SELECT 
  c.nombre AS cliente,
  e.descripcion,
  e.peso,
  e.valor_declarado,
  e.estado
FROM encomienda e
JOIN cliente c ON e.id_cliente = c.id_cliente
ORDER BY e.id_encomienda;

-- Consulta JOIN: Ver envíos completos con origen, destino y encomienda
SELECT 
  e.id_envio,
  enc.descripcion,
  s_origen.nombre AS sucursal_origen,
  s_destino.nombre AS sucursal_destino,
  e.fecha_envio,
  e.costo
FROM envio e
JOIN encomienda enc ON e.id_encomienda = enc.id_encomienda
JOIN sucursal s_origen ON e.id_sucursal_origen = s_origen.id_sucursal
JOIN sucursal s_destino ON e.id_sucursal_destino = s_destino.id_sucursal
ORDER BY e.id_envio;
