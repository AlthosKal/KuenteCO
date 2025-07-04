package org.kuenteco.backend.validations;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import java.time.LocalDate;
import org.kuenteco.backend.dto.subscription.wompi.request.api.TokenizeCardRequestDTO;

public class PayMethodValidator
        implements ConstraintValidator<PayMethodConstraint, TokenizeCardRequestDTO> {

    @Override
    public void initialize(PayMethodConstraint constraintAnnotation) {
        // Inicialización si es necesaria
    }

    @Override
    public boolean isValid(TokenizeCardRequestDTO request, ConstraintValidatorContext context) {
        if (request == null) {
            return true; // Deja que @NotNull maneje nulls
        }

        boolean valid = true;
        context.disableDefaultConstraintViolation();

        // Validar que la fecha de expiración no esté vencida
        if (request.getExpiryMonth() != null && request.getExpiryYear() != null) {
            try {
                LocalDate expiryDate =
                        LocalDate.of(
                                        Integer.parseInt(request.getExpiryYear()),
                                        Integer.parseInt(request.getExpiryMonth()),
                                        1)
                                .plusMonths(1)
                                .minusDays(1); // Último día del mes

                if (expiryDate.isBefore(LocalDate.now())) {
                    context.buildConstraintViolationWithTemplate("La tarjeta está vencida")
                            .addPropertyNode("expiryMonth")
                            .addConstraintViolation();
                    valid = false;
                }
            } catch (NumberFormatException e) {
                context.buildConstraintViolationWithTemplate("Fecha de expiración inválida")
                        .addPropertyNode("expiryMonth")
                        .addConstraintViolation();
                valid = false;
            }
        }

        // Validar algoritmo de Luhn para el número de tarjeta
        if (request.getCardNumber() != null && !isValidCardNumber(request.getCardNumber())) {
            context.buildConstraintViolationWithTemplate("Número de tarjeta inválido")
                    .addPropertyNode("cardNumber")
                    .addConstraintViolation();
            valid = false;
        }

        return valid;
    }

    private boolean isValidCardNumber(String cardNumber) {
        if (cardNumber == null || cardNumber.trim().isEmpty()) {
            return false;
        }

        String number = cardNumber.replaceAll("\\s+", "");
        if (!number.matches("\\d+")) {
            return false;
        }

        // Algoritmo de Luhn
        int sum = 0;
        boolean alternate = false;

        for (int i = number.length() - 1; i >= 0; i--) {
            int digit = Character.getNumericValue(number.charAt(i));

            if (alternate) {
                digit *= 2;
                if (digit > 9) {
                    digit = (digit % 10) + 1;
                }
            }

            sum += digit;
            alternate = !alternate;
        }

        return (sum % 10) == 0;
    }
}
