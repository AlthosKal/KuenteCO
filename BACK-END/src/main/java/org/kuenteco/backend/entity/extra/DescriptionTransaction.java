package org.kuenteco.backend.entity.extra;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DescriptionTransaction implements Serializable {
    private String contentTitle;
    private String description;
    private String typeTransaction;
    private String contentDetails;
}
