package org.kuenteco.backend.validation;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;
import java.lang.annotation.*;

@Target({ElementType.FIELD, ElementType.PARAMETER})
@Retention(RetentionPolicy.RUNTIME)
@Constraint(validatedBy = CurrencyValidator.class)
@Documented
public @interface ValidCurrency {
    String message() default "El valor monetario no es válido";

    Class<?>[] groups() default {};

    Class<? extends Payload>[] payload() default {};

    /** Valor mínimo permitido */
    double min() default 0.0;

    /** Valor máximo permitido */
    double max() default Double.MAX_VALUE;

    /** Número máximo de decimales permitidos */
    int decimalPlaces() default 2;

    /** Si permite valores negativos */
    boolean allowNegative() default false;
}
