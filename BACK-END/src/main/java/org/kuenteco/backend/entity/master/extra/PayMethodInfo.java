package org.kuenteco.backend.entity.master.extra;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Embeddable
@NoArgsConstructor
@AllArgsConstructor
public class PayMethodInfo {
    @Column(name = "method")
    private String method;

    @Column(columnDefinition = "JSONB")
    private DescriptionPaymentHistory details;
}
