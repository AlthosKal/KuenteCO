package org.kuenteco.backend.service.subscription.wompi;

import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.config.api.WompiConfig;
import org.kuenteco.backend.dto.subscription.wompi.request.WompiTokenizeCardRequestDTO;
import org.kuenteco.backend.dto.subscription.wompi.request.WompiTransactionRequestDTO;
import org.kuenteco.backend.dto.subscription.wompi.response.WompiTokenResponseDTO;
import org.kuenteco.backend.dto.subscription.wompi.response.WompiTransactionResponseDTO;
import org.kuenteco.backend.enums.CurrencyType;
import org.kuenteco.backend.exception.exceptions.WompiException;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Slf4j
@Service
@RequiredArgsConstructor
public class WompiServiceImpl implements WompiService {
    private final WompiConfig wompiConfig;
    private final RestTemplate restTemplate;

    @Override
    public WompiTokenResponseDTO tokenizeCard(WompiTokenizeCardRequestDTO request) {
        String endpointTokenCards = "/tokens/cards";
        String url = wompiConfig.getBaseUrl() + endpointTokenCards;

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(wompiConfig.getPublicKey());

        HttpEntity<WompiTokenizeCardRequestDTO> entity = new HttpEntity<>(request, headers);

        log.info("Tokenizando la targeta en Wompi para {}", request.getCardHolder());

        ResponseEntity<WompiTokenResponseDTO> response =
                restTemplate.exchange(url, HttpMethod.POST, entity, WompiTokenResponseDTO.class);

        if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
            log.info(
                    "Targeta tokenizada correctamente. Token ID: {}",
                    response.getBody().getData().getId());
            return response.getBody();
        } else {
            throw new WompiException("Error al tokenizar la tarjeta: " + response.getStatusCode());
        }
    }

    @Override
    public WompiTransactionResponseDTO createTransaction(WompiTransactionRequestDTO request) {
        String endpointTransactions = "/transactions";

        String url = wompiConfig.getBaseUrl() + endpointTransactions;

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(wompiConfig.getPrivateKey());

        HttpEntity<WompiTransactionRequestDTO> entity = new HttpEntity<>(request, headers);

        log.info(
                "Creando la transacción de Wompi. Referencia: {}, Monto: {}",
                request.getReference(),
                request.getAmountInCents());

        ResponseEntity<WompiTransactionResponseDTO> response =
                restTemplate.exchange(
                        url, HttpMethod.POST, entity, WompiTransactionResponseDTO.class);

        if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
            log.info(
                    "Transacción creada exitosamente. ID: {}, Estado: {}",
                    response.getBody().getData().getId(),
                    response.getBody().getData().getStatus());
            return response.getBody();
        } else {
            throw new WompiException("Error al crear la transacción: " + response.getStatusCode());
        }
    }

    @Override
    public WompiTransactionResponseDTO getTransaction(String transactionId) {
        String endpointTransactions = "/transactions/" + transactionId;
        String url = wompiConfig.getBaseUrl() + endpointTransactions;

        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(wompiConfig.getPublicKey());

        HttpEntity<?> entity = new HttpEntity<>(headers);

        ResponseEntity<WompiTransactionResponseDTO> response =
                restTemplate.exchange(
                        url, HttpMethod.GET, entity, WompiTransactionResponseDTO.class);

        if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
            return response.getBody();
        } else {
            throw new WompiException("Error al consultar transacción: " + response.getStatusCode());
        }
    }

    @Override
    public String generateSignature(
            String reference, BigDecimal amount, CurrencyType currency, String integritySecret)
            throws NoSuchAlgorithmException {
        long amountInCents = amount.multiply(BigDecimal.valueOf(100)).longValue();
        String concatenatedString = reference + amountInCents + currency + integritySecret;

        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        byte[] hash = digest.digest(concatenatedString.getBytes(StandardCharsets.UTF_8));

        return bytesToHex(hash);
    }

    private String bytesToHex(byte[] bytes) {
        StringBuilder result = new StringBuilder();
        for (byte b : bytes) {
            result.append(String.format("%02x", b));
        }
        return result.toString();
    }
}
