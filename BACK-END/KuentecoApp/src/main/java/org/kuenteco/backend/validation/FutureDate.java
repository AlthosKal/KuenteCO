package org.kuenteco.backend.validation;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;
import java.lang.annotation.*;

@Target({ElementType.FIELD, ElementType.PARAMETER})
@Retention(RetentionPolicy.RUNTIME)
@Constraint(validatedBy = FutureDateValidator.class)
@Documented
public @interface FutureDate {
    String message() default "La fecha debe ser futura";

    Class<?>[] groups() default {};

    Class<? extends Payload>[] payload() default {};

    /** Días mínimos en el futuro (por defecto 0 = solo debe ser futura) */
    int minDaysInFuture() default 0;

    /** Días máximos en el futuro (por defecto sin límite) */
    int maxDaysInFuture() default Integer.MAX_VALUE;
}
