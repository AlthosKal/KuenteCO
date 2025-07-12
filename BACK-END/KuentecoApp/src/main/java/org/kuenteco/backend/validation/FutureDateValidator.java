package org.kuenteco.backend.validation;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

public class FutureDateValidator implements ConstraintValidator<FutureDate, Object> {

    private int minDaysInFuture;
    private int maxDaysInFuture;

    @Override
    public void initialize(FutureDate constraintAnnotation) {
        this.minDaysInFuture = constraintAnnotation.minDaysInFuture();
        this.maxDaysInFuture = constraintAnnotation.maxDaysInFuture();
    }

    @Override
    public boolean isValid(Object value, ConstraintValidatorContext context) {
        if (value == null) {
            return true; // Use @NotNull for null checks
        }

        LocalDate dateToValidate = null;

        if (value instanceof LocalDate) {
            dateToValidate = (LocalDate) value;
        } else if (value instanceof LocalDateTime) {
            dateToValidate = ((LocalDateTime) value).toLocalDate();
        } else {
            return false; // Unsupported type
        }

        LocalDate now = LocalDate.now();
        long daysDifference = ChronoUnit.DAYS.between(now, dateToValidate);

        if (daysDifference < minDaysInFuture) {
            buildConstraintViolation(
                    context,
                    String.format(
                            "La fecha debe ser al menos %d días en el futuro", minDaysInFuture));
            return false;
        }

        if (daysDifference > maxDaysInFuture) {
            buildConstraintViolation(
                    context,
                    String.format(
                            "La fecha no puede ser más de %d días en el futuro", maxDaysInFuture));
            return false;
        }

        return true;
    }

    private void buildConstraintViolation(ConstraintValidatorContext context, String message) {
        context.disableDefaultConstraintViolation();
        context.buildConstraintViolationWithTemplate(message).addConstraintViolation();
    }
}
