package com.example.back_end.service.report;

import com.example.back_end.dto.response.ai.BaseDynamicResponseDTO;
import org.springframework.core.io.Resource;
import org.springframework.http.ResponseEntity;

public interface ReportGenerationService {
    BaseDynamicResponseDTO generateReportResponse(
            String prompt, String functionName, Object data, String reportType);

    ResponseEntity<Resource> downloadReport(String reportId);
}
