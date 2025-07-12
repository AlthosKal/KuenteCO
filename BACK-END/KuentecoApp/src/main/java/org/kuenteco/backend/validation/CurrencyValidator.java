package org.kuenteco.backend.validation;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import java.math.BigDecimal;

public class CurrencyValidator implements ConstraintValidator<ValidCurrency, BigDecimal> {

    private double min;
    private double max;
    private int decimalPlaces;
    private boolean allowNegative;

    @Override
    public void initialize(ValidCurrency constraintAnnotation) {
        this.min = constraintAnnotation.min();
        this.max = constraintAnnotation.max();
        this.decimalPlaces = constraintAnnotation.decimalPlaces();
        this.allowNegative = constraintAnnotation.allowNegative();
    }

    @Override
    public boolean isValid(BigDecimal value, ConstraintValidatorContext context) {
        if (value == null) {
            return true; // Use @NotNull for null checks
        }

        // Validar si permite valores negativos
        if (!allowNegative && value.compareTo(BigDecimal.ZERO) < 0) {
            buildConstraintViolation(context, "No se permiten valores negativos");
            return false;
        }

        // Validar rango
        if (value.doubleValue() < min || value.doubleValue() > max) {
            buildConstraintViolation(
                    context, String.format("El valor debe estar entre %.2f y %.2f", min, max));
            return false;
        }

        // Validar decimales
        if (value.scale() > decimalPlaces) {
            buildConstraintViolation(
                    context,
                    String.format("El valor no puede tener más de %d decimales", decimalPlaces));
            return false;
        }

        return true;
    }

    private void buildConstraintViolation(ConstraintValidatorContext context, String message) {
        context.disableDefaultConstraintViolation();
        context.buildConstraintViolationWithTemplate(message).addConstraintViolation();
    }
}
