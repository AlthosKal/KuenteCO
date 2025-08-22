-- Script para insertar datos de prueba necesarios para las pruebas de integración
-- Este script se ejecuta después de que Hibernate haya creado las tablas

-- Insertar roles necesarios para las pruebas (basado en V1.2__insert_rows.sql)
INSERT INTO public.role (id, name)
VALUES
    (0, 'ROLE_USER'),
    (1, 'ROLE_PROFILE')
ON CONFLICT (id) DO NOTHING;

-- Datos de prueba insertados correctamente
