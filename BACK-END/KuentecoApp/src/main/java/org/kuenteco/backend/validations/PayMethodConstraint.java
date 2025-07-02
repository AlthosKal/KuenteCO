package org.kuenteco.backend.validations;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;
import java.lang.annotation.*;

@Documented
@Constraint(validatedBy = PayMethodValidator.class)
@Target({ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
public @interface PayMethodConstraint {
    String message() default "Información de método de pago inválida";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}
