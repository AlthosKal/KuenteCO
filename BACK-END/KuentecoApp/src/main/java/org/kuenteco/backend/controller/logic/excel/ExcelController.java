package org.kuenteco.backend.controller.logic.excel;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.AllArgsConstructor;
import org.kuenteco.backend.exception.ApiResponse;
import org.kuenteco.backend.service.logic.excel.ExcelService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("v1/excel")
@AllArgsConstructor
public class ExcelController {
    private ExcelService excelService;

    @GetMapping("/export")
    public void exportExcel(HttpServletResponse response) {
        excelService.exportData(response);
    }

    @PostMapping("/import")
    public ResponseEntity<?> importExcel(HttpServletRequest request) {
        excelService.importData(request);
        return new ResponseEntity<>(
                ApiResponse.ok("Datos importados correctamente", null, request.getRequestURI()),
                HttpStatus.OK);
    }
}
