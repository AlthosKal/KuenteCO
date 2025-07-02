package org.kuenteco.backend.service.wompi;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.dto.subscription.request.WompiTokenizeCardRequestDTO;
import org.kuenteco.backend.dto.subscription.request.api.TokenizeCardRequestDTO;
import org.kuenteco.backend.dto.subscription.response.WompiTokenResponseDTO;
import org.kuenteco.backend.dto.subscription.response.api.PaymentTokenResponseDTO;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.entity.UserPaymentToken;
import org.kuenteco.backend.exception.exceptions.TokenizationException;
import org.kuenteco.backend.repository.master.MasterUserPaymentTokenRepository;
import org.kuenteco.backend.repository.slave.SlaveUserPaymentTokenRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class PaymentTokenServiceImpl implements PaymentTokenService {
    private final WompiService wompiService;
    private final MasterUserPaymentTokenRepository masterTokenRepository;
    private final SlaveUserPaymentTokenRepository slaveTokenRepository;

    @Override
    public PaymentTokenResponseDTO tokenizeAndSaveCard(User user, TokenizeCardRequestDTO request) {
        try {
            log.info("Iniciando tokenización de tarjeta para usuario: {}", user.getEmail());

            // Desactivar tokens anteriores del usuario
            deactivatePreviousTokens(user);

            // Tokenizar en Wompi
            WompiTokenizeCardRequestDTO wompiRequest = WompiTokenizeCardRequestDTO.builder()
                    .number(request.getCardNumber())
                    .cvc(request.getCvc())
                    .expMonth(request.getExpiryMonth())
                    .expYear(request.getExpiryYear())
                    .cardHolder(request.getCardHolder())
                    .build();

            WompiTokenResponseDTO wompiResponse = wompiService.tokenizeCard(wompiRequest);

            if (wompiResponse.getData() == null) {
                throw new TokenizationException("Respuesta inválida de Wompi");
            }

            // Guardar token en BD
            UserPaymentToken token = UserPaymentToken.builder()
                    .user(user)
                    .wompiToken(wompiResponse.getData().getId())
                    .cardLastFour(wompiResponse.getData().getLastFour())
                    .cardBrand(wompiResponse.getData().getBrand())
                    .expiryMonth(wompiResponse.getData().getExpMonth())
                    .expiryYear(wompiResponse.getData().getExpYear())
                    .createdAt(LocalDateTime.now())
                    .isActive(true)
                    .build();

            token = masterTokenRepository.save(token);

            log.info("Token de pago guardado exitosamente para usuario: {}", user.getEmail());

            return PaymentTokenResponseDTO.builder()
                    .tokenId(token.getId())
                    .cardLastFour(token.getCardLastFour())
                    .cardBrand(token.getCardBrand())
                    .expiryMonth(token.getExpiryMonth())
                    .expiryYear(token.getExpiryYear())
                    .createdAt(token.getCreatedAt())
                    .isActive(token.getIsActive())
                    .build();

        } catch (Exception e) {
            log.error("Error al tokenizar tarjeta para usuario {}: {}", user.getEmail(), e.getMessage(), e);
            throw new TokenizationException("Error al tokenizar tarjeta: " + e.getMessage(), e);
        }
    }

    @Override
    public void deactivatePreviousTokens(User user) {
        List<UserPaymentToken> activeTokens = slaveTokenRepository.findByUserAndIsActiveTrue(user);
        activeTokens.forEach(token -> token.setIsActive(false));
        masterTokenRepository.saveAll(activeTokens);
        log.info("Desactivados {} tokens anteriores para usuario: {}", activeTokens.size(), user.getEmail());
    }

    @Override
    public List<PaymentTokenResponseDTO> getUserActiveTokens(User user) {
        return slaveTokenRepository.findByUserAndIsActiveTrue(user)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public UserPaymentToken getActiveTokenById(Integer tokenId, User user) {
        return slaveTokenRepository.findByIdAndUserAndIsActiveTrue(tokenId, user)
                .orElseThrow(() -> new TokenizationException("Token no encontrado o inactivo"));
    }

    //Proximamente se realizará con un Mapper de Mapstruct
    private PaymentTokenResponseDTO mapToResponse(UserPaymentToken token) {
        return PaymentTokenResponseDTO.builder()
                .tokenId(token.getId())
                .cardLastFour(token.getCardLastFour())
                .cardBrand(token.getCardBrand())
                .expiryMonth(token.getExpiryMonth())
                .expiryYear(token.getExpiryYear())
                .createdAt(token.getCreatedAt())
                .isActive(token.getIsActive())
                .build();
    }
}
