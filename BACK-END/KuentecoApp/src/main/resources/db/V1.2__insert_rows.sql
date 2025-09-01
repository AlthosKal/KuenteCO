INSERT INTO public.role (id, name)
VALUES
    (0, 'ROLE_USER'),
    (1, 'ROLE_PROFILE')
ON CONFLICT (id) DO NOTHING;

-- Insertar usuario personal Password(password123)
INSERT INTO public.kuentecouser (id, version, id_role, id_image, username, email, password, type, account_state)
VALUES
    ('550e8400-e29b-41d4-a716-446655440001', 0, 0, NULL, 'usuario_personal', 'personal@kuenteco.com', '$2a$10$vwJQ47RK/8RbfNfMTNclXecZqR9Qwcho2xWKJsJtygoxG/k3XgREu', 'PERSONAL', 'ACTIVE');

-- Insertar subscription para el usuario personal  
INSERT INTO public.subscription (id_user, state, type)
VALUES
    ('550e8400-e29b-41d4-a716-446655440001', 'ACTIVE', 'BASIC');

-- Insertar usuario de negocio
INSERT INTO public.kuentecouser (id, version, id_role, id_image, username, email, password, type, account_state)
VALUES
    ('550e8400-e29b-41d4-a716-446655440002', 0, 0, NULL, 'usuario_negocio', 'negocio@kuenteco.com', '$2a$10$vwJQ47RK/8RbfNfMTNclXecZqR9Qwcho2xWKJsJtygoxG/k3XgREu', 'BUSINESS', 'ACTIVE');

-- Insertar subscription para el usuario de negocio
INSERT INTO public.subscription (id_user, state, type)
VALUES
    ('550e8400-e29b-41d4-a716-446655440002', 'ACTIVE', 'BASIC');

-- Insertar perfil asociado al usuario de negocio
INSERT INTO public.profile (id_user, id_role, id_image, username, email, password, start_date)
VALUES
    ('550e8400-e29b-41d4-a716-446655440002', 1, NULL, 'perfil_empleado', 'empleado@kuenteco.com', '$2a$10$vwJQ47RK/8RbfNfMTNclXecZqR9Qwcho2xWKJsJtygoxG/k3XgREu', CURRENT_TIMESTAMP);
