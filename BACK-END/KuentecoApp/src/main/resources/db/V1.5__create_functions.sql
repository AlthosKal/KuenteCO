-- Extenciones de PostgreSQL para la tarea programada y la ejecución de la solicitud HTTP
CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS http;

-- Función de actualización de tasas de cambio CORREGIDA CON REINTENTOS
CREATE OR REPLACE FUNCTION update_exchange_rates()
    RETURNS VOID AS $$
DECLARE
    api_url TEXT;
    api_key TEXT := '1d3914b3aff44c30b1bb9bf4d8e302f0';
    response http_response; -- Usar el tipo correcto
    response_body TEXT;
    response_json JSONB;
    api_base_currency TEXT;
    rates JSONB;
    currency_record RECORD;
    rate_value NUMERIC;
    retry_count INTEGER := 0;
    max_retries INTEGER := 3;
    retry_delay INTEGER := 2; -- segundos entre reintentos
    success BOOLEAN := FALSE;
BEGIN
    -- Construir la URL de la API
    api_url := 'https://openexchangerates.org/api/latest.json?app_id=' || api_key;

    -- Implementar estrategia de reintentos
    WHILE retry_count <= max_retries AND NOT success LOOP
        BEGIN
            INSERT INTO exchange_rate_logs (log_message)
            VALUES ('Intento ' || (retry_count + 1) || ' de ' || (max_retries + 1) || ' para obtener tasas de cambio');
            
            -- Hacer la solicitud HTTP a la API con timeout aumentado
            response := http((
                              'GET',
                              api_url,
                              NULL,
                              'application/json',
                              '15000'  -- Timeout de 15 segundos
                )::http_request);
            
            success := TRUE; -- Si llega aquí, la petición fue exitosa
            
        EXCEPTION WHEN others THEN
            retry_count := retry_count + 1;
            
            INSERT INTO exchange_rate_logs (log_message)
            VALUES ('Fallo en intento ' || retry_count || ': ' || SQLERRM);
            
            -- Si no es el último intento, esperar antes del siguiente
            IF retry_count <= max_retries THEN
                INSERT INTO exchange_rate_logs (log_message)
                VALUES ('Esperando ' || retry_delay || ' segundos antes del siguiente intento...');
                PERFORM pg_sleep(retry_delay);
            ELSE
                -- Último intento falló, lanzar excepción
                INSERT INTO exchange_rate_logs (log_message)
                VALUES ('Todos los intentos fallaron. Error final: ' || SQLERRM);
                RAISE EXCEPTION 'Error al realizar la solicitud HTTP después de % intentos: %', max_retries + 1, SQLERRM;
            END IF;
        END;
    END LOOP;

    -- Verificar el status HTTP
    IF response.status != 200 THEN
        INSERT INTO exchange_rate_logs (log_message)
        VALUES ('Error HTTP: Status ' || response.status || ' - ' || response.content);
        RAISE EXCEPTION 'Error HTTP: Status % - %', response.status, response.content;
    END IF;

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
    IF response_json ? 'error' THEN
        INSERT INTO exchange_rate_logs (log_message)
        VALUES ('Error en la API: ' || (response_json->>'error') || ' - ' || (response_json->>'description'));
        RAISE EXCEPTION 'Error en la API: % - %', response_json->>'error', response_json->>'description';
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

    -- Verificar que la moneda base existe
    IF api_base_currency IS NULL THEN
        INSERT INTO exchange_rate_logs (log_message)
        VALUES ('Error: No se encontró la moneda base en la respuesta de la API.');
        RAISE EXCEPTION 'Error: No se encontró la moneda base en la respuesta de la API.';
    END IF;

    -- Recorrer las tasas de cambio y actualizar la tabla
    FOR currency_record IN
        SELECT key as currency, value as rate_json
        FROM jsonb_each(rates)
        LOOP
            BEGIN
                -- Convertir el valor JSONB a NUMERIC de forma segura
                rate_value := (currency_record.rate_json #>> '{}')::NUMERIC;

                -- Validar que la tasa es positiva
                IF rate_value <= 0 THEN
                    INSERT INTO exchange_rate_logs (log_message)
                    VALUES ('Advertencia: Tasa inválida para ' || currency_record.currency || ': ' || rate_value::TEXT);
                    CONTINUE;
                END IF;

                -- Insertar o actualizar la tasa de cambio en la tabla
                INSERT INTO exchange_rate (base_currency, target_currency, rate, last_updated)
                VALUES (api_base_currency, currency_record.currency, rate_value, NOW())
                ON CONFLICT (base_currency, target_currency)
                    DO UPDATE SET
                                  rate = EXCLUDED.rate,
                                  last_updated = EXCLUDED.last_updated;

            EXCEPTION WHEN others THEN
                -- Log del error pero continuar con las demás tasas
                INSERT INTO exchange_rate_logs (log_message)
                VALUES ('Error procesando tasa para ' || currency_record.currency || ': ' || SQLERRM);
                CONTINUE;
            END;
        END LOOP;

    -- Registrar éxito en la tabla de logs
    INSERT INTO exchange_rate_logs (log_message)
    VALUES ('Tasas de cambio actualizadas correctamente para ' || api_base_currency || '. Total procesadas: ' ||
            (SELECT count(*) FROM jsonb_object_keys(rates))::TEXT || ' monedas.');

EXCEPTION WHEN others THEN
    -- Log del error general
    INSERT INTO exchange_rate_logs (log_message)
    VALUES ('Error general en update_exchange_rates: ' || SQLERRM);
    RAISE;
END;
$$ LANGUAGE plpgsql;

-- Tarea programada para la actualización automática cada 2 horas de la tabla exchangeRate
-- Primero eliminar la tarea existente si existe (de forma segura)
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM cron.job 
        WHERE jobname = 'update-change-rates'
    ) THEN
        PERFORM cron.unschedule('update-change-rates');
    END IF;
END
$$;

-- Crear la nueva tarea programada
SELECT cron.schedule(
               'update-change-rates',
               '0 */2 * * *',
               $$ SELECT update_exchange_rates() $$
       );

-- Funcion para las conversiones de moneda (sin cambios)
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

-- Función auxiliar para limpiar logs antiguos (opcional)
CREATE OR REPLACE FUNCTION cleanup_exchange_rate_logs(days_to_keep INTEGER DEFAULT 30)
    RETURNS VOID AS $$
BEGIN
    DELETE FROM exchange_rate_logs
    WHERE log_timestamp < NOW() - INTERVAL '1 day' * days_to_keep;

    INSERT INTO exchange_rate_logs (log_message)
    VALUES ('Logs de tasas de cambio limpiados. Eliminados registros anteriores a ' || days_to_keep || ' días.');
END;
$$ LANGUAGE plpgsql;

-- Comentarios para pruebas
-- SELECT update_exchange_rates();
-- SELECT * FROM exchange_rate ORDER BY last_updated DESC;
-- SELECT * FROM exchange_rate_logs ORDER BY log_timestamp DESC LIMIT 10;
-- SELECT * FROM cron.job WHERE jobname = 'update-change-rates';