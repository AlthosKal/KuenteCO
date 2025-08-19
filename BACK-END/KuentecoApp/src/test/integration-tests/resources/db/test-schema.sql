-- Script de inicialización para base de datos de pruebas de integración de KuenteCO
-- Este script se ejecuta automáticamente cuando se inicia el contenedor PostgreSQL de pruebas

-- Configuraciones iniciales
SET TIME ZONE 'America/Bogota';

-- Crear extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Insertar datos iniciales necesarios para las pruebas
-- Estos datos se usarán en las pruebas de integración para tener un estado inicial consistente

-- Nota: Las tablas se crean automáticamente por Hibernate con ddl-auto=create-drop
-- Este script se ejecuta ANTES de que Hibernate cree las tablas, por lo que
-- necesitamos insertar los datos después. Para eso usaremos @Sql en las pruebas.

-- Solo creamos extensiones y configuraciones iniciales aquí

-- Mensaje de confirmación
DO $$ 
BEGIN 
    RAISE NOTICE 'Schema de pruebas de integración inicializado correctamente para KuenteCO'; 
END $$;
