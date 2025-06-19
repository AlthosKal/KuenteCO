package org.kuenteco.backend.entity.extra;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DescriptionTransaction {
    private String contentTitle;
    private String description;
    private String typeTransaction;
    private String contentDetails;
}
