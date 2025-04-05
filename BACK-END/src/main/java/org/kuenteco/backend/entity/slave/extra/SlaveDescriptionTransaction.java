package org.kuenteco.backend.entity.slave.extra;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SlaveDescriptionTransaction implements Serializable {
    private String contentTitle;
    private String description;
    private String typeTransaction;
    private String contentDetails;
}