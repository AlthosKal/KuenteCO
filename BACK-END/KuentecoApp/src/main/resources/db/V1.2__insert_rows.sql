INSERT INTO public.role (id, name)
VALUES
    (0, 'ROLE_USER'),
    (1, 'ROLE_PROFILE')
ON CONFLICT (id) DO NOTHING;
