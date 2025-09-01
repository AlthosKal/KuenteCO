package org.kuenteco.backend.controller.logic.excel;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.kuenteco.backend.exception.ApiResponse;
import org.kuenteco.backend.service.logic.excel.ExcelService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Controlador REST para la gestión de importación y exportación de datos financieros en formato
 * Excel.
 *
 * <p>Este controlador maneja todas las operaciones relacionadas con: - Exportación de
 * transacciones, presupuestos, categorías y deudas a Excel - Importación de datos financieros desde
 * archivos Excel
 *
 * @author KuenteCO Team
 * @version 1.0
 * @since 2024
 */
@Slf4j
@RestController
@RequestMapping("v1/excel")
@AllArgsConstructor
public class ExcelController implements ExcelResource {
    private final ExcelService excelService;

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
