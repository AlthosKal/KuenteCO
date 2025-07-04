package org.kuenteco.backend.validations;

import jakarta.validation.Constraint;
import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import jakarta.validation.Payload;
import java.lang.annotation.*;
import java.time.YearMonth;
import org.kuenteco.backend.dto.subscription.wompi.request.api.TokenizeCardRequestDTO;

/** Anotación para validar que la fecha de expiración de la tarjeta no esté vencida */
@Documented
@Constraint(validatedBy = ValidCardExpiration.CardExpirationValidator.class)
@Target({ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
public @interface ValidCardExpiration {
    String message() default "La tarjeta está vencida";

    Class<?>[] groups() default {};

    Class<? extends Payload>[] payload() default {};

    /** Validador que verifica que la fecha de expiración no esté vencida */
    class CardExpirationValidator
            implements ConstraintValidator<ValidCardExpiration, TokenizeCardRequestDTO> {

        @Override
        public void initialize(ValidCardExpiration constraintAnnotation) {
            // No necesita inicialización
        }

        @Override
        public boolean isValid(TokenizeCardRequestDTO dto, ConstraintValidatorContext context) {
            if (dto == null || dto.getExpiryMonth() == null || dto.getExpiryYear() == null) {
                return true; // Deja que otras validaciones manejen campos nulos
            }

            try {
                YearMonth cardExpiration = dto.getExpirationYearMonth();
                YearMonth currentMonth = YearMonth.now();

                if (cardExpiration == null || cardExpiration.isBefore(currentMonth)) {
                    // Personalizar el mensaje de error
                    context.disableDefaultConstraintViolation();
                    context.buildConstraintViolationWithTemplate(
                                    "La tarjeta está vencida. Fecha de expiración: "
                                            + dto.getExpiryMonth()
                                            + "/"
                                            + dto.getExpiryYear())
                            .addConstraintViolation();
                    return false;
                }

                return true;

            } catch (Exception e) {
                // Si hay error al parsear las fechas, es inválido
                context.disableDefaultConstraintViolation();
                context.buildConstraintViolationWithTemplate(
                                "Formato de fecha de expiración inválido")
                        .addConstraintViolation();
                return false;
            }
        }
    }
}
