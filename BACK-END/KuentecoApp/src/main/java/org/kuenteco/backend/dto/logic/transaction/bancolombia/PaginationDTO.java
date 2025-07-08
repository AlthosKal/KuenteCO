package org.kuenteco.backend.dto.logic.transaction.bancolombia;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaginationDTO {
    @JsonProperty("page")
    private Integer page;

    @JsonProperty("page_size")
    private Integer pageSize;

    @JsonProperty("total_pages")
    private Integer totalPages;

    @JsonProperty("total_records")
    private Long totalRecords;

    @JsonProperty("has_next")
    private Boolean hasNext;

    @JsonProperty("has_previous")
    private Boolean hasPrevious;
}
