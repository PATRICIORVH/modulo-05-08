-- =====================================================
-- SISTEMA 3: ADMINISTRADOR DE CUENTAS BANCARIAS
-- =====================================================
-- Base de datos: modulo_05_08
-- Objetivo: Crear tablas normalizadas para un sistema
--           bancario con 5 entidades.

-- =====================================================
-- ANÁLISIS ER Y NORMALIZACIÓN
-- =====================================================

-- Entidades identificadas:
-- 1. CLIENTE      → Titulares de cuentas
-- 2. CUENTA       → Cuentas bancarias (1:N con Cliente)
-- 3. TIPO_TRANSACCION → Categorización de movimientos
-- 4. TRANSACCIÓN  → Movimientos en cuentas (1:N con Cuenta)
-- 5. PRÉSTAMO     → Créditos otorgados (1:N con Cliente)

-- Relaciones:
-- Cliente (1) -----> (N) Cuenta
-- Cliente (1) -----> (N) Préstamo
-- Cuenta (1) -----> (N) Transacción
-- Tipo_Transaccion (1) -----> (N) Transacción

-- Cardinalidades: 1:N
-- Normalización: Todas las tablas cumplen 3FN

-- =====================================================
-- CREAR TABLAS (DDL)
-- =====================================================

-- Tabla 1: CLIENTE
DROP TABLE IF EXISTS cliente_banco CASCADE;

CREATE TABLE cliente_banco (
  id_cliente SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  telefono VARCHAR(20) NOT NULL,
  rut VARCHAR(12) UNIQUE NOT NULL,
  direccion TEXT NOT NULL,
  ciudad VARCHAR(50) NOT NULL,
  fecha_registro DATE NOT NULL DEFAULT CURRENT_DATE
);

-- Tabla 2: CUENTA (1:N con Cliente)
DROP TABLE IF EXISTS cuenta CASCADE;

CREATE TABLE cuenta (
  id_cuenta SERIAL PRIMARY KEY,
  id_cliente INT NOT NULL REFERENCES cliente_banco(id_cliente) ON DELETE CASCADE,
  numero_cuenta VARCHAR(20) UNIQUE NOT NULL,
  tipo_cuenta VARCHAR(50) NOT NULL CHECK (tipo_cuenta IN ('Ahorro', 'Corriente', 'Inversión')),
  saldo NUMERIC(15, 2) NOT NULL DEFAULT 0 CHECK (saldo >= 0),
  fecha_apertura DATE NOT NULL DEFAULT CURRENT_DATE,
  estado VARCHAR(50) NOT NULL DEFAULT 'Activa' CHECK (estado IN ('Activa', 'Suspendida', 'Cerrada'))
);

-- Tabla 3: TIPO_TRANSACCION
DROP TABLE IF EXISTS tipo_transaccion CASCADE;

CREATE TABLE tipo_transaccion (
  id_tipo SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL UNIQUE,
  descripcion TEXT,
  categoria VARCHAR(50) NOT NULL CHECK (categoria IN ('Depósito', 'Retiro', 'Transferencia', 'Pago'))
);

-- Tabla 4: TRANSACCIÓN (1:N con Cuenta y Tipo_Transaccion)
DROP TABLE IF EXISTS transaccion CASCADE;

CREATE TABLE transaccion (
  id_transaccion SERIAL PRIMARY KEY,
  id_cuenta INT NOT NULL REFERENCES cuenta(id_cuenta) ON DELETE CASCADE,
  id_tipo INT NOT NULL REFERENCES tipo_transaccion(id_tipo) ON DELETE RESTRICT,
  monto NUMERIC(15, 2) NOT NULL CHECK (monto > 0),
  fecha_transaccion DATE NOT NULL DEFAULT CURRENT_DATE,
  hora_transaccion TIME NOT NULL DEFAULT CURRENT_TIME,
  descripcion TEXT,
  saldo_posterior NUMERIC(15, 2) NOT NULL CHECK (saldo_posterior >= 0)
);

-- Tabla 5: PRÉSTAMO (1:N con Cliente)
DROP TABLE IF EXISTS prestamo CASCADE;

CREATE TABLE prestamo (
  id_prestamo SERIAL PRIMARY KEY,
  id_cliente INT NOT NULL REFERENCES cliente_banco(id_cliente) ON DELETE CASCADE,
  monto_solicitado NUMERIC(15, 2) NOT NULL CHECK (monto_solicitado > 0),
  monto_aprobado NUMERIC(15, 2) NOT NULL CHECK (monto_aprobado > 0),
  tasa_interes NUMERIC(5, 2) NOT NULL CHECK (tasa_interes > 0),
  plazo_meses INT NOT NULL CHECK (plazo_meses > 0),
  fecha_solicitud DATE NOT NULL DEFAULT CURRENT_DATE,
  fecha_aprobacion DATE,
  estado VARCHAR(50) NOT NULL DEFAULT 'Pendiente' CHECK (estado IN ('Pendiente', 'Aprobado', 'Rechazado', 'Pagado')),
  saldo_adeudado NUMERIC(15, 2) NOT NULL DEFAULT 0 CHECK (saldo_adeudado >= 0)
);

-- =====================================================
-- INSERTAR DATOS DE PRUEBA
-- =====================================================

-- Datos de prueba para CLIENTE_BANCO
INSERT INTO cliente_banco (nombre, email, telefono, rut, direccion, ciudad) VALUES
('Roberto Sánchez', 'roberto.sanchez@email.com', '912345678', '12345678-9', 'Calle A 100', 'Concepción'),
('Sandra Morales', 'sandra.morales@email.com', '987654321', '98765432-1', 'Calle B 200', 'Talcahuano'),
('Tomás Rivera', 'tomas.rivera@email.com', '956789012', '56789012-3', 'Calle C 300', 'San Pedro de la Paz');

-- Datos de prueba para CUENTA
INSERT INTO cuenta (id_cliente, numero_cuenta, tipo_cuenta, saldo, estado) VALUES
(1, '1000001-2', 'Ahorro', 2500000, 'Activa'),
(1, '1000002-3', 'Corriente', 5000000, 'Activa'),
(2, '1000003-4', 'Ahorro', 1800000, 'Activa'),
(3, '1000004-5', 'Inversión', 10000000, 'Activa');

-- Datos de prueba para TIPO_TRANSACCION
INSERT INTO tipo_transaccion (nombre, descripcion, categoria) VALUES
('Depósito en Efectivo', 'Ingreso de dinero en efectivo', 'Depósito'),
('Transferencia Recibida', 'Transferencia de otro banco', 'Transferencia'),
('Retiro en Cajero', 'Retiro en cajero automático', 'Retiro'),
('Pago de Servicios', 'Pago de luz, agua, teléfono', 'Pago'),
('Transferencia Enviada', 'Envío de dinero a otra cuenta', 'Transferencia');

-- Datos de prueba para TRANSACCIÓN
INSERT INTO transaccion (id_cuenta, id_tipo, monto, fecha_transaccion, hora_transaccion, descripcion, saldo_posterior) VALUES
(1, 1, 500000, '2026-02-01', '10:30:00', 'Depósito inicial', 3000000),
(2, 2, 1000000, '2026-02-01', '11:15:00', 'Transferencia recibida de cliente', 6000000),
(3, 3, 200000, '2026-02-02', '14:45:00', 'Retiro en cajero', 1600000),
(4, 4, 500000, '2026-02-02', '16:20:00', 'Pago de servicios básicos', 9500000),
(1, 5, 300000, '2026-02-03', '09:10:00', 'Transferencia a otra cuenta', 2700000);

-- Datos de prueba para PRÉSTAMO
INSERT INTO prestamo (id_cliente, monto_solicitado, monto_aprobado, tasa_interes, plazo_meses, fecha_aprobacion, estado, saldo_adeudado) VALUES
(1, 2000000, 2000000, 8.5, 24, '2026-01-20', 'Aprobado', 2000000),
(2, 5000000, 4500000, 9.2, 36, '2026-01-25', 'Aprobado', 4500000),
(3, 1000000, 1000000, 7.8, 12, '2026-02-01', 'Aprobado', 1000000);

-- =====================================================
-- CONSULTAS DE VERIFICACIÓN
-- =====================================================

-- Verificar tabla CLIENTE_BANCO
SELECT * FROM cliente_banco;

-- Verificar tabla CUENTA
SELECT * FROM cuenta;

-- Verificar tabla TIPO_TRANSACCION
SELECT * FROM tipo_transaccion;

-- Verificar tabla TRANSACCIÓN
SELECT * FROM transaccion;

-- Verificar tabla PRÉSTAMO
SELECT * FROM prestamo;

-- Consulta JOIN: Cuentas de clientes con saldo actual
SELECT 
  c.nombre AS cliente,
  cu.numero_cuenta,
  cu.tipo_cuenta,
  cu.saldo,
  cu.estado
FROM cuenta cu
JOIN cliente_banco c ON cu.id_cliente = c.id_cliente
ORDER BY c.nombre, cu.numero_cuenta;

-- Consulta JOIN: Transacciones con tipo y cliente
SELECT 
  c.nombre AS cliente,
  cu.numero_cuenta,
  tt.nombre AS tipo_transaccion,
  t.monto,
  t.fecha_transaccion,
  t.hora_transaccion,
  t.saldo_posterior
FROM transaccion t
JOIN cuenta cu ON t.id_cuenta = cu.id_cuenta
JOIN cliente_banco c ON cu.id_cliente = c.id_cliente
JOIN tipo_transaccion tt ON t.id_tipo = tt.id_tipo
ORDER BY t.fecha_transaccion DESC, t.hora_transaccion DESC;

-- Consulta JOIN: Préstamos con datos del cliente
SELECT 
  c.nombre AS cliente,
  c.rut,
  p.monto_solicitado,
  p.monto_aprobado,
  p.tasa_interes,
  p.plazo_meses,
  p.estado,
  p.saldo_adeudado,
  ROUND((p.saldo_adeudado * p.tasa_interes / 100 / 12), 2) AS interes_mensual
FROM prestamo p
JOIN cliente_banco c ON p.id_cliente = c.id_cliente
ORDER BY p.estado, c.nombre;
