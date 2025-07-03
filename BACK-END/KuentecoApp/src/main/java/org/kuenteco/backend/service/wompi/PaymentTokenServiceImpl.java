package org.kuenteco.backend.service.wompi;

import static org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials;

import java.time.LocalDateTime;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.config.jwt.AuthCredentials;
import org.kuenteco.backend.dto.subscription.request.WompiTokenizeCardRequestDTO;
import org.kuenteco.backend.dto.subscription.request.api.TokenizeCardRequestDTO;
import org.kuenteco.backend.dto.subscription.response.WompiTokenResponseDTO;
import org.kuenteco.backend.dto.subscription.response.api.PaymentTokenResponseDTO;
import org.kuenteco.backend.entity.User;
import org.kuenteco.backend.entity.UserPaymentToken;
import org.kuenteco.backend.exception.exceptions.TokenizationException;
import org.kuenteco.backend.mapper.subscription.PaymentTokenMapper;
import org.kuenteco.backend.mapper.subscription.WompiMapper;
import org.kuenteco.backend.repository.master.MasterUserPaymentTokenRepository;
import org.kuenteco.backend.repository.slave.SlaveUserPaymentTokenRepository;
import org.kuenteco.backend.repository.slave.SlaveUserRepository;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class PaymentTokenServiceImpl implements PaymentTokenService {
    private final WompiService wompiService;
    private final MasterUserPaymentTokenRepository masterTokenRepository;
    private final SlaveUserPaymentTokenRepository slaveTokenRepository;
    private final SlaveUserRepository slaveUserRepository;
    private final PaymentTokenMapper paymentTokenMapper;
    private final WompiMapper wompiMapper;

    @Override
    public PaymentTokenResponseDTO tokenizeAndSaveCard(TokenizeCardRequestDTO request) {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(
                                () ->
                                        new TokenizationException(
                                                "Usuario no encontrado con el email " + email));
        log.info("Iniciando tokenización de tarjeta para usuario: {}", email);

        // Desactivar tokens anteriores del usuario
        deactivatePreviousTokens(user);

        // Tokenizar en Wompi
        WompiTokenizeCardRequestDTO wompiRequest = wompiMapper.toWompiTokenizeRequest(request);
        WompiTokenResponseDTO wompiResponse = wompiService.tokenizeCard(wompiRequest);

        if (wompiResponse.getData() == null) {
            throw new TokenizationException("Respuesta inválida de Wompi");
        }

        // Guardar token en BD
        UserPaymentToken token = paymentTokenMapper.toEntity(wompiResponse);
        token.setUser(user);
        token.setCreatedAt(LocalDateTime.now());
        token.setIsActive(true);

        token = masterTokenRepository.save(token);

        log.info("Token de pago guardado exitosamente para usuario: {}", user.getEmail());

        return paymentTokenMapper.toDTO(token);
    }

    private void deactivatePreviousTokens(User user) {
        List<UserPaymentToken> activeTokens = slaveTokenRepository.findByUserAndIsActiveTrue(user);
        activeTokens.forEach(token -> token.setIsActive(false));
        masterTokenRepository.saveAll(activeTokens);
        log.info(
                "Desactivados {} tokens anteriores para usuario: {}",
                activeTokens.size(),
                user.getEmail());
    }

    @Override
    public List<PaymentTokenResponseDTO> getUserActiveTokens() {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(
                                () ->
                                        new TokenizationException(
                                                "Usuario no encontrado con el email " + email));
        List<UserPaymentToken> tokens = slaveTokenRepository.findByUserAndIsActiveTrue(user);
        return paymentTokenMapper.toDTOList(tokens);
    }
}
