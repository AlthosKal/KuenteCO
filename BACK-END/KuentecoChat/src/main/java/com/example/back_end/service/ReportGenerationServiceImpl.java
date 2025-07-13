package com.example.back_end.service;

import com.example.back_end.connector.rest.budget.BudgetSummaryDTO;
import com.example.back_end.connector.rest.budget.BudgetVsActualDTO;
import com.example.back_end.connector.rest.debt.DebtDTO;
import com.example.back_end.connector.rest.transaction.TransactionSummaryDTO;
import com.example.back_end.dto.response.ai.BaseDynamicResponseDTO;
import com.example.back_end.dto.response.ai.ReportDownloadResponseDTO;
import com.itextpdf.text.*;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

@Service
public class ReportGenerationServiceImpl implements ReportGenerationService {

    private static final Logger LOGGER = LoggerFactory.getLogger(ReportGenerationServiceImpl.class);

    @Value("${app.reports.storage.path}")
    private String reportsStoragePath;

    @Value("${app.reports.expiration.hours}")
    private int reportExpirationHours;

    private final Map<String, ReportMetadata> reportMetadataCache = new ConcurrentHashMap<>();

    @Override
    public BaseDynamicResponseDTO generateReportResponse(
            String prompt, String functionName, Object data, String reportType) {
        try {
            String reportId = UUID.randomUUID().toString();
            String fileName = generateFileName(functionName, reportType);
            String filePath = reportsStoragePath + File.separator + fileName;

            // Crear directorio si no existe
            createDirectoryIfNotExists(reportsStoragePath);

            // Generar el reporte según el tipo
            long fileSize;
            if ("PDF".equalsIgnoreCase(reportType)) {
                fileSize = generatePDFReport(filePath, functionName, data);
            } else if ("EXCEL".equalsIgnoreCase(reportType)) {
                fileSize = generateExcelReport(filePath, functionName, data);
            } else {
                throw new IllegalArgumentException("Tipo de reporte no soportado: " + reportType);
            }

            // Guardar metadata del reporte
            ReportMetadata metadata =
                    new ReportMetadata(
                            reportId,
                            filePath,
                            fileName,
                            reportType,
                            functionName,
                            LocalDateTime.now().plusHours(reportExpirationHours));
            reportMetadataCache.put(reportId, metadata);
            String expirationDate =
                    metadata.getExpirationDate().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME);

            return new ReportDownloadResponseDTO(
                    "Reporte generado exitosamente",
                    "El reporte "
                            + reportType
                            + " ha sido generado y está disponible para descarga",
                    reportId,
                    fileName,
                    reportType,
                    functionName,
                    fileSize,
                    expirationDate);

        } catch (Exception e) {
            LOGGER.error("Error generando reporte: {}", e.getMessage(), e);
            throw new RuntimeException("Error al generar el reporte", e);
        }
    }

    @Override
    public ResponseEntity<Resource> downloadReport(String reportId) {
        ReportMetadata metadata = reportMetadataCache.get(reportId);

        if (metadata == null) {
            return ResponseEntity.notFound().build();
        }

        if (LocalDateTime.now().isAfter(metadata.getExpirationDate())) {
            reportMetadataCache.remove(reportId);
            deleteFile(metadata.getFilePath());
            return ResponseEntity.notFound().build();
        }

        try {
            File file = new File(metadata.getFilePath());
            if (!file.exists()) {
                return ResponseEntity.notFound().build();
            }

            Resource resource = new FileSystemResource(file);
            MediaType mediaType = determineMediaType(metadata.getReportType());

            return ResponseEntity.ok()
                    .contentType(mediaType)
                    .header(
                            HttpHeaders.CONTENT_DISPOSITION,
                            "attachment; filename=\"" + metadata.getFileName() + "\"")
                    .body(resource);

        } catch (Exception e) {
            LOGGER.error("Error descargando reporte: {}", e.getMessage(), e);
            return ResponseEntity.internalServerError().build();
        }
    }

    private long generatePDFReport(String filePath, String functionName, Object data)
            throws Exception {
        Document document = new Document();
        PdfWriter.getInstance(document, new FileOutputStream(filePath));
        document.open();

        // Título del reporte - CORREGIDO: Usar com.itextpdf.text.Font
        com.itextpdf.text.Font titleFont =
                new com.itextpdf.text.Font(
                        com.itextpdf.text.Font.FontFamily.HELVETICA,
                        18,
                        com.itextpdf.text.Font.BOLD);
        Paragraph title = new Paragraph("Reporte Financiero - " + functionName, titleFont);
        title.setAlignment(Element.ALIGN_CENTER);
        document.add(title);

        // Fecha de generación - CORREGIDO: Usar com.itextpdf.text.Font
        com.itextpdf.text.Font dateFont =
                new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.HELVETICA, 10);
        Paragraph date =
                new Paragraph(
                        "Generado el: "
                                + LocalDateTime.now()
                                        .format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")),
                        dateFont);
        date.setAlignment(Element.ALIGN_RIGHT);
        document.add(date);

        document.add(new Paragraph("\n"));

        // Contenido según el tipo de función
        generatePDFContent(document, functionName, data);

        document.close();

        return Files.size(Paths.get(filePath));
    }

    private long generateExcelReport(String filePath, String functionName, Object data)
            throws Exception {
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("Reporte Financiero");

        // Estilos - CORREGIDO: Usar org.apache.poi.ss.usermodel.Font
        CellStyle headerStyle = workbook.createCellStyle();
        org.apache.poi.ss.usermodel.Font headerFont = workbook.createFont();
        headerFont.setBold(true);
        headerStyle.setFont(headerFont);

        // Título
        Row titleRow = sheet.createRow(0);
        Cell titleCell = titleRow.createCell(0);
        titleCell.setCellValue("Reporte Financiero - " + functionName);
        titleCell.setCellStyle(headerStyle);

        // Fecha
        Row dateRow = sheet.createRow(1);
        Cell dateCell = dateRow.createCell(0);
        dateCell.setCellValue(
                "Generado el: "
                        + LocalDateTime.now()
                                .format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")));

        // Contenido
        generateExcelContent(sheet, functionName, data, headerStyle);

        // Auto-ajustar columnas
        for (int i = 0; i < 10; i++) {
            sheet.autoSizeColumn(i);
        }

        FileOutputStream fileOut = new FileOutputStream(filePath);
        workbook.write(fileOut);
        fileOut.close();
        workbook.close();

        return Files.size(Paths.get(filePath));
    }

    private void generatePDFContent(Document document, String functionName, Object data)
            throws DocumentException {
        switch (functionName) {
            case "BalanceOverTime":
            case "IncomesAndExpensesByPeriod":
                generateTransactionSummaryPDF(document, (List<TransactionSummaryDTO>) data);
                break;
            case "analyzeDebtRisk":
                generateDebtAnalysisPDF(document, (List<DebtDTO>) data);
                break;
            case "compareFinancialPeriods":
                generateBudgetComparisonPDF(document, (List<BudgetVsActualDTO>) data);
                break;
            case "financialStatement":
                generateBudgetSummaryPDF(document, (List<BudgetSummaryDTO>) data);
                break;
            default:
                document.add(new Paragraph("Datos del análisis: " + data.toString()));
        }
    }

    private void generateExcelContent(
            Sheet sheet, String functionName, Object data, CellStyle headerStyle) {
        switch (functionName) {
            case "BalanceOverTime":
            case "IncomesAndExpensesByPeriod":
                generateTransactionSummaryExcel(
                        sheet, (List<TransactionSummaryDTO>) data, headerStyle);
                break;
            case "analyzeDebtRisk":
                generateDebtAnalysisExcel(sheet, (List<DebtDTO>) data, headerStyle);
                break;
            case "compareFinancialPeriods":
                generateBudgetComparisonExcel(sheet, (List<BudgetVsActualDTO>) data, headerStyle);
                break;
            case "financialStatement":
                generateBudgetSummaryExcel(sheet, (List<BudgetSummaryDTO>) data, headerStyle);
                break;
            default:
                Row row = sheet.createRow(3);
                row.createCell(0).setCellValue("Datos del análisis:");
                row.createCell(1).setCellValue(data.toString());
        }
    }

    private void generateTransactionSummaryPDF(Document document, List<TransactionSummaryDTO> data)
            throws DocumentException {
        PdfPTable table = new PdfPTable(4);
        table.setWidthPercentage(100);

        // Headers
        table.addCell("Categoría");
        table.addCell("Ingresos");
        table.addCell("Gastos");
        table.addCell("Balance");

        // Data
        for (TransactionSummaryDTO item : data) {
            table.addCell(item.getCategoryName() != null ? item.getCategoryName() : "N/A");
            table.addCell(formatAmount(item.getTotalIncome()));
            table.addCell(formatAmount(item.getTotalExpenses()));
            table.addCell(formatAmount(item.getNetAmount()));
        }

        document.add(table);
    }

    private void generateTransactionSummaryExcel(
            Sheet sheet, List<TransactionSummaryDTO> data, CellStyle headerStyle) {
        Row headerRow = sheet.createRow(3);
        headerRow.createCell(0).setCellValue("Categoría");
        headerRow.createCell(1).setCellValue("Ingresos");
        headerRow.createCell(2).setCellValue("Gastos");
        headerRow.createCell(3).setCellValue("Balance");

        for (Cell cell : headerRow) {
            cell.setCellStyle(headerStyle);
        }

        int rowNum = 4;
        for (TransactionSummaryDTO item : data) {
            Row row = sheet.createRow(rowNum++);
            row.createCell(0)
                    .setCellValue(item.getCategoryName() != null ? item.getCategoryName() : "N/A");
            row.createCell(1).setCellValue(getDoubleValue(item.getTotalIncome()));
            row.createCell(2).setCellValue(getDoubleValue(item.getTotalExpenses()));
            row.createCell(3).setCellValue(getDoubleValue(item.getNetAmount()));
        }
    }

    private void generateDebtAnalysisPDF(Document document, List<DebtDTO> data)
            throws DocumentException {
        PdfPTable table = new PdfPTable(4);
        table.setWidthPercentage(100);

        table.addCell("Deuda ID");
        table.addCell("Monto Pendiente");
        table.addCell("Estado");
        table.addCell("Fecha de Inicio"); // CORREGIDO: Usar startDate en lugar de createdAt

        for (DebtDTO debt : data) {
            table.addCell(debt.getId() != null ? debt.getId().toString() : "N/A");
            table.addCell(formatAmount(debt.getPendingAmount()));
            table.addCell(debt.getState() != null ? debt.getState().name() : "N/A");
            table.addCell(
                    debt.getStartDate() != null
                            ? debt.getStartDate().toString()
                            : "N/A"); // CORREGIDO
        }

        document.add(table);
    }

    private void generateDebtAnalysisExcel(Sheet sheet, List<DebtDTO> data, CellStyle headerStyle) {
        Row headerRow = sheet.createRow(3);
        headerRow.createCell(0).setCellValue("Deuda ID");
        headerRow.createCell(1).setCellValue("Monto Pendiente");
        headerRow.createCell(2).setCellValue("Estado");
        headerRow.createCell(3).setCellValue("Fecha de Inicio"); // CORREGIDO

        for (Cell cell : headerRow) {
            cell.setCellStyle(headerStyle);
        }

        int rowNum = 4;
        for (DebtDTO debt : data) {
            Row row = sheet.createRow(rowNum++);
            row.createCell(0).setCellValue(debt.getId() != null ? debt.getId().toString() : "N/A");
            row.createCell(1).setCellValue(getDoubleValue(debt.getPendingAmount()));
            row.createCell(2)
                    .setCellValue(debt.getState() != null ? debt.getState().name() : "N/A");
            row.createCell(3)
                    .setCellValue(
                            debt.getStartDate() != null
                                    ? debt.getStartDate().toString()
                                    : "N/A"); // CORREGIDO
        }
    }

    private void generateBudgetComparisonPDF(Document document, List<BudgetVsActualDTO> data)
            throws DocumentException {
        PdfPTable table = new PdfPTable(3);
        table.setWidthPercentage(100);

        table.addCell("Categoría");
        table.addCell("Presupuesto");
        table.addCell("Gasto Real");

        for (BudgetVsActualDTO item : data) {
            table.addCell(item.getCategoryName() != null ? item.getCategoryName() : "N/A");
            table.addCell(formatAmount(item.getAssignedAmount()));
            table.addCell(formatAmount(item.getActualSpent()));
        }

        document.add(table);
    }

    private void generateBudgetComparisonExcel(
            Sheet sheet, List<BudgetVsActualDTO> data, CellStyle headerStyle) {
        Row headerRow = sheet.createRow(3);
        headerRow.createCell(0).setCellValue("Categoría");
        headerRow.createCell(1).setCellValue("Presupuesto");
        headerRow.createCell(2).setCellValue("Gasto Real");

        for (Cell cell : headerRow) {
            cell.setCellStyle(headerStyle);
        }

        int rowNum = 4;
        for (BudgetVsActualDTO item : data) {
            Row row = sheet.createRow(rowNum++);
            row.createCell(0)
                    .setCellValue(item.getCategoryName() != null ? item.getCategoryName() : "N/A");
            row.createCell(1).setCellValue(getDoubleValue(item.getAssignedAmount()));
            row.createCell(2).setCellValue(getDoubleValue(item.getActualSpent()));
        }
    }

    private void generateBudgetSummaryPDF(Document document, List<BudgetSummaryDTO> data)
            throws DocumentException {
        PdfPTable table = new PdfPTable(2);
        table.setWidthPercentage(100);

        table.addCell("Usuario");
        table.addCell("Presupuesto Total");

        for (BudgetSummaryDTO item : data) {
            table.addCell(item.getUsername() != null ? item.getUsername() : "N/A");
            table.addCell(formatAmount(item.getTotalBudgetAmount()));
        }

        document.add(table);
    }

    private void generateBudgetSummaryExcel(
            Sheet sheet, List<BudgetSummaryDTO> data, CellStyle headerStyle) {
        Row headerRow = sheet.createRow(3);
        headerRow.createCell(0).setCellValue("Usuario");
        headerRow.createCell(1).setCellValue("Presupuesto Total");

        for (Cell cell : headerRow) {
            cell.setCellStyle(headerStyle);
        }

        int rowNum = 4;
        for (BudgetSummaryDTO item : data) {
            Row row = sheet.createRow(rowNum++);
            row.createCell(0).setCellValue(item.getUsername() != null ? item.getUsername() : "N/A");
            row.createCell(1).setCellValue(getDoubleValue(item.getTotalBudgetAmount()));
        }
    }

    private String formatAmount(BigDecimal amount) {
        return amount != null ? "$" + amount.toString() : "$0.00";
    }

    private double getDoubleValue(BigDecimal amount) {
        return amount != null ? amount.doubleValue() : 0.0;
    }

    private String generateFileName(String functionName, String reportType) {
        String timestamp =
                LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
        String extension = "PDF".equalsIgnoreCase(reportType) ? "pdf" : "xlsx";
        return String.format("reporte_%s_%s.%s", functionName, timestamp, extension);
    }

    private void createDirectoryIfNotExists(String directoryPath) throws IOException {
        Path path = Paths.get(directoryPath);
        if (!Files.exists(path)) {
            Files.createDirectories(path);
        }
    }

    private void deleteFile(String filePath) {
        try {
            Files.deleteIfExists(Paths.get(filePath));
        } catch (IOException e) {
            LOGGER.warn("No se pudo eliminar el archivo: {}", filePath, e);
        }
    }

    private MediaType determineMediaType(String reportType) {
        if ("PDF".equalsIgnoreCase(reportType)) {
            return MediaType.APPLICATION_PDF;
        } else if ("EXCEL".equalsIgnoreCase(reportType)) {
            return MediaType.parseMediaType(
                    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        }
        return MediaType.APPLICATION_OCTET_STREAM;
    }

    // Clase interna para metadata de reportes
    private static class ReportMetadata {
        private final String reportId;
        private final String filePath;
        private final String fileName;
        private final String reportType;
        private final String functionName;
        private final LocalDateTime expirationDate;

        public ReportMetadata(
                String reportId,
                String filePath,
                String fileName,
                String reportType,
                String functionName,
                LocalDateTime expirationDate) {
            this.reportId = reportId;
            this.filePath = filePath;
            this.fileName = fileName;
            this.reportType = reportType;
            this.functionName = functionName;
            this.expirationDate = expirationDate;
        }

        // Getters
        public String getReportId() {
            return reportId;
        }

        public String getFilePath() {
            return filePath;
        }

        public String getFileName() {
            return fileName;
        }

        public String getReportType() {
            return reportType;
        }

        public String getFunctionName() {
            return functionName;
        }

        public LocalDateTime getExpirationDate() {
            return expirationDate;
        }
    }
}
