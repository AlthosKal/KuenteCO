package org.kuenteco.backend.controller.logic.exchange_rate;

import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.dto.logic.exchange_rate.ConvertCurrencyRequestDTO;
import org.kuenteco.backend.dto.logic.exchange_rate.ConvertCurrencyResponseDTO;
import org.kuenteco.backend.dto.logic.exchange_rate.ExchangeRateDTO;
import org.kuenteco.backend.service.logic.exchange_rate.ExchangeRateService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Controlador REST para la gestión de tasas de cambio y conversión de monedas.
 *
 * <p>Este controlador maneja todas las operaciones relacionadas con: - Consulta de tasas de cambio
 * disponibles - Conversión entre diferentes monedas usando tasas actualizadas - Sincronización
 * automática con proveedores externos de tasas de cambio
 *
 * @author KuenteCO Team
 * @version 1.0
 * @since 2024
 */
@Slf4j
@RestController
@RequestMapping("/v1/exchange-rates")
@RequiredArgsConstructor
public class ExchangeRateController implements ExchangeRateResource {

    private final ExchangeRateService exchangeRateService;

    @GetMapping
    public ResponseEntity<List<ExchangeRateDTO>> getAllRates() {
        List<ExchangeRateDTO> rates = exchangeRateService.getAllRates();
        return ResponseEntity.ok(rates);
    }

    @PostMapping("/convert")
    public ResponseEntity<ConvertCurrencyResponseDTO> convert(
            @Valid @RequestBody ConvertCurrencyRequestDTO dto) {
        ConvertCurrencyResponseDTO response = exchangeRateService.convert(dto);
        return ResponseEntity.ok(response);
    }
}
