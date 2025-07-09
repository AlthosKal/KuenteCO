package org.kuenteco.backend.dto.logic.transaction.bancolombia.response;

import org.kuenteco.backend.dto.logic.transaction.bancolombia.response.extra.Data;
import org.kuenteco.backend.dto.logic.transaction.bancolombia.response.extra.Meta;

@lombok.Data
public class TransactionalInfoResponse {
    private Meta meta;
    private Data data;
}
