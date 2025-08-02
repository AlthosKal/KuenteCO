package org.kuenteco.backend.entity.extra;

import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.TransactionType;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DescriptionTransaction {
    private String description;

    @Enumerated(EnumType.STRING)
    private TransactionType type;
}
