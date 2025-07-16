package org.kuenteco.backend.service.logic.excel;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public interface ExcelService {
    void exportData(HttpServletResponse response);

    void importData(HttpServletRequest request);
}
