package org.kuenteco.backend.controller.logic.exchange_rate;

import java.util.List;
import lombok.RequiredArgsConstructor;
import org.kuenteco.backend.dto.logic.exchange_rate.ConvertCurrencyRequestDTO;
import org.kuenteco.backend.dto.logic.exchange_rate.ConvertCurrencyResponseDTO;
import org.kuenteco.backend.dto.logic.exchange_rate.ExchangeRateDTO;
import org.kuenteco.backend.service.logic.exchange_rate.ExchangeRateServiceImpl;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/exchange-rates")
@RequiredArgsConstructor
public class ExchangeRateController {

    private final ExchangeRateServiceImpl exchangeRateService;

    @GetMapping
    public ResponseEntity<List<ExchangeRateDTO>> getAllRates() {
        return ResponseEntity.ok(exchangeRateService.getAllRates());
    }

    @PostMapping("/convert")
    public ResponseEntity<ConvertCurrencyResponseDTO> convert(
            @RequestBody ConvertCurrencyRequestDTO dto) {
        return ResponseEntity.ok(exchangeRateService.convert(dto));
    }
}
