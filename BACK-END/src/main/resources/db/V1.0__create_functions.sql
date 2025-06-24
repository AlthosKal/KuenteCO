-- Extenciónes de PostgreSQL para la tarea programada y la ejecución de la solicitud HTTP
CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS http;

-- Función de actualización de tasas de cambio
CREATE OR REPLACE FUNCTION update_exchange_rates()
    RETURNS VOID AS $$
DECLARE
    api_url TEXT;
    api_key TEXT := '1d3914b3aff44c30b1bb9bf4d8e302f0'; -- Reemplaza con tu API key de Open Exchange Rates
    response RECORD; -- Cambiamos el tipo a RECORD para manejar la respuesta compuesta
    response_body TEXT; -- Almacenará el cuerpo de la respuesta
    response_json JSONB;
    api_base_currency TEXT;
    rates JSONB;
    api_target_currency TEXT;
    rate NUMERIC;
BEGIN
    -- Construir la URL de la API
    api_url := 'https://openexchangerates.org/api/latest.json?app_id=' || api_key;

    -- Hacer la solicitud HTTP a la API
    response := http_get(api_url);

    -- Extraer el cuerpo de la respuesta
    response_body := response.content;

    -- Verificar si la respuesta es nula o está vacía
    IF response_body IS NULL OR response_body = '' THEN
        INSERT INTO exchange_rate_logs (log_message)
        VALUES ('Error: La respuesta de la API está vacía o es nula.');
        RAISE EXCEPTION 'Error: La respuesta de la API está vacía o es nula.';
    END IF;

    -- Intentar convertir el cuerpo de la respuesta a JSON
    BEGIN
        response_json := response_body::JSONB;
    EXCEPTION WHEN others THEN
        INSERT INTO exchange_rate_logs (log_message)
        VALUES ('Error: La respuesta de la API no es un JSON válido: ' || response_body);
        RAISE EXCEPTION 'Error: La respuesta de la API no es un JSON válido: %', response_body;
    END;

    -- Verificar si la respuesta contiene un error
    IF response_json->>'error' IS NOT NULL THEN
        INSERT INTO exchange_rate_logs (log_message)
        VALUES ('Error en la API: ' || response_json->>'error');
        RAISE EXCEPTION 'Error en la API: %', response_json->>'error';
    END IF;

    -- Extraer la moneda base y las tasas de cambio
    api_base_currency := response_json->>'base';
    rates := response_json->'rates';

    -- Verificar si las tasas de cambio están presentes
    IF rates IS NULL THEN
        INSERT INTO exchange_rate_logs (log_message)
        VALUES ('Error: No se encontraron tasas de cambio en la respuesta de la API.');
        RAISE EXCEPTION 'Error: No se encontraron tasas de cambio en la respuesta de la API.';
    END IF;

    -- Recorrer las tasas de cambio y actualizar la tabla
    FOR api_target_currency, rate IN SELECT * FROM jsonb_each(rates) LOOP
            -- Insertar o actualizar la tasa de cambio en la tabla
            INSERT INTO exchange_rate (base_currency, target_currency, rate, last_updated)
            VALUES (api_base_currency, api_target_currency, rate, now())
            ON CONFLICT (base_currency, target_currency)
                DO UPDATE SET rate = EXCLUDED.rate, last_updated = EXCLUDED.last_updated;
        END LOOP;

    -- Registrar éxito en la tabla de logs
    INSERT INTO exchange_rate_logs (log_message)
    VALUES ('Tasas de cambio actualizadas correctamente.');
END;
$$ LANGUAGE plpgsql;

-- Tarea programada para la actualización automática cada 2 horas de la tabla exchangeRate
SELECT cron.schedule(
               'update-change-rates',
               '0 */2 * * *',
               $$ SELECT update_exchange_rates() $$
       );

-- Funcion para las conversiones de moneda
CREATE OR REPLACE FUNCTION convert_currency(
    p_amount NUMERIC,
    p_base_currency VARCHAR(10),
    p_target_currency VARCHAR(10)
) RETURNS NUMERIC AS $$
DECLARE
    v_rate NUMERIC;
BEGIN
    -- Obtener la tasa de cambio más reciente
    SELECT rate INTO v_rate
    FROM exchange_rate
    WHERE base_currency = p_base_currency
      AND target_currency = p_target_currency
      AND last_updated = (SELECT MAX(last_updated) FROM exchange_rate);

    -- Si no se encuentra la tasa de cambio, lanzar un error
    IF v_rate IS NULL THEN
        RAISE EXCEPTION 'Tasa de cambio no encontrada para % a %', p_base_currency, p_target_currency;
    END IF;

    -- Retornar la cantidad convertida
    RETURN p_amount * v_rate;
END;
$$ LANGUAGE plpgsql;

-- Pruebas de las funciones y extensiones

SELECT  update_exchange_rates();
