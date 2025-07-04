package org.kuenteco.backend.mapper.subscription.wompi;

import java.util.List;
import org.kuenteco.backend.dto.subscription.wompi.response.WompiTokenResponseDTO;
import org.kuenteco.backend.dto.subscription.wompi.response.api.PaymentTokenResponseDTO;
import org.kuenteco.backend.entity.UserPaymentToken;
import org.mapstruct.*;

/** Mapper para conversiones relacionadas con tokens de pago */
@Mapper(componentModel = "spring")
public interface PaymentTokenMapper {

    /** Convierte UserPaymentToken entity a PaymentTokenResponseDTO */
    @Mapping(target = "tokenId", source = "id")
    @Mapping(target = "cardLastFour", source = "cardLastFour")
    @Mapping(target = "cardBrand", source = "cardBrand")
    @Mapping(target = "expiryMonth", source = "expiryMonth")
    @Mapping(target = "expiryYear", source = "expiryYear")
    @Mapping(target = "createdAt", source = "createdAt")
    @Mapping(target = "isActive", source = "isActive")
    PaymentTokenResponseDTO toDTO(UserPaymentToken token);

    List<PaymentTokenResponseDTO> toDTOList(List<UserPaymentToken> tokens);

    @Mapping(target = "wompiToken", source = "data.id")
    @Mapping(target = "cardLastFour", source = "data.lastFour")
    @Mapping(target = "cardBrand", source = "data.brand")
    @Mapping(target = "expiryMonth", source = "data.expMonth")
    @Mapping(target = "expiryYear", source = "data.expYear")
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "user", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "isActive", ignore = true)
    UserPaymentToken toEntity(WompiTokenResponseDTO dto);
}
