package org.kuenteco.backend.dto.logic.transaction.bancolombia.response.extra;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class Meta {
    @JsonProperty("_messageId")
    private String messageId;

    @JsonProperty("_requestDateTime")
    private String requestDateTime;

    @JsonProperty("_applicationId")
    private String applicationId;
}
