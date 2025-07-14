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
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.BaseFont;
import com.itextpdf.text.pdf.draw.LineSeparator;
import com.itextpdf.text.pdf.draw.VerticalPositionMark;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
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
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFChart;
import org.apache.poi.xssf.usermodel.XSSFDrawing;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFClientAnchor;
import org.openxmlformats.schemas.drawingml.x2006.chart.CTChart;
import org.openxmlformats.schemas.drawingml.x2006.chart.CTPlotArea;
import org.openxmlformats.schemas.drawingml.x2006.chart.CTBarChart;
import org.openxmlformats.schemas.drawingml.x2006.chart.CTBarSer;
import org.openxmlformats.schemas.drawingml.x2006.chart.STBarDir;
import org.openxmlformats.schemas.drawingml.x2006.chart.STBarGrouping;
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
    private final ChartGenerationService chartGenerationService;
    
    // Colores corporativos
    private static final BaseColor PRIMARY_COLOR = new BaseColor(41, 128, 185);
    private static final BaseColor SECONDARY_COLOR = new BaseColor(52, 152, 219);
    private static final BaseColor ACCENT_COLOR = new BaseColor(231, 76, 60);
    
    public ReportGenerationServiceImpl(ChartGenerationService chartGenerationService) {
        this.chartGenerationService = chartGenerationService;
    }

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

// Header con logo
InputStream logoStream = getClass().getClassLoader().getResourceAsStream("static/images/logo.png");
if (logoStream != null) {
    Image logo = Image.getInstance(logoStream.readAllBytes());
    logo.scalePercent(50);
    logo.setAlignment(Element.ALIGN_CENTER);
    document.add(logo);
    logoStream.close();
}

document.add(new Paragraph("\n"));

// Título del reporte
com.itextpdf.text.Font titleFont = new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.HELVETICA, 18, com.itextpdf.text.Font.BOLD);
Paragraph title = new Paragraph("Reporte Financiero - " + functionName, titleFont);
title.setAlignment(Element.ALIGN_CENTER);
document.add(title);

document.add(new Paragraph("\n"));

// Fecha de generación 
com.itextpdf.text.Font dateFont = new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.HELVETICA, 10);
Paragraph date = new Paragraph("Generado el: " + LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")), dateFont);
date.setAlignment(Element.ALIGN_RIGHT);
document.add(date);

document.add(new Paragraph("\n"));

// Línea separadora
LineSeparator separator = new LineSeparator();
separator.setOffset(-2);
document.add(separator);

document.add(new Paragraph("\n"));

        // Contenido según el tipo de función
        generatePDFContent(document, functionName, data);

        document.close();

        return Files.size(Paths.get(filePath));
    }

    private long generateExcelReport(String filePath, String functionName, Object data)
            throws Exception {
        Workbook workbook = new XSSFWorkbook();
        
        // Crear estilos
        CellStyle headerStyle = createHeaderStyle(workbook);
        CellStyle titleStyle = createTitleStyle(workbook);
        CellStyle dateStyle = createDateStyle(workbook);
        CellStyle positiveStyle = createPositiveStyle(workbook);
        CellStyle negativeStyle = createNegativeStyle(workbook);
        
        // Hoja principal de datos
        Sheet dataSheet = workbook.createSheet("Datos");
        
        // Título de la hoja
        Row titleRow = dataSheet.createRow(0);
        Cell titleCell = titleRow.createCell(0);
        titleCell.setCellValue("Reporte Financiero - " + functionName);
        titleCell.setCellStyle(titleStyle);
        
        // Fusionar celdas para el título
        dataSheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 5));
        
        // Fecha
        Row dateRow = dataSheet.createRow(1);
        Cell dateCell = dateRow.createCell(0);
        dateCell.setCellValue(
                "Generado el: "
                        + LocalDateTime.now()
                                .format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")));
        dateCell.setCellStyle(dateStyle);
        
        // Contenido principal
        generateExcelContent(dataSheet, functionName, data, headerStyle);
        
        // Aplicar formato condicional
        applyConditionalFormatting(dataSheet, functionName);
        
        // Hoja de resumen
        Sheet summarySheet = workbook.createSheet("Resumen");
        generateSummarySheet(summarySheet, functionName, data, headerStyle, titleStyle);
        
        // Hoja de gráficos (solo datos para gráficos)
        Sheet chartsSheet = workbook.createSheet("Gráficos");
        generateChartsSheet(chartsSheet, functionName, data, headerStyle);
        
        // Auto-ajustar columnas en todas las hojas
        for (Sheet sheet : workbook) {
            for (int i = 0; i < 10; i++) {
                sheet.autoSizeColumn(i);
            }
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
            case "calculateFinancialHealthScore":
            case "analyzeUserSpendingPatterns":
                generateUserProfilesPDF(document, data);
                break;
            default:
                generateGenericDataPDF(document, data);
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
            case "calculateFinancialHealthScore":
            case "analyzeUserSpendingPatterns":
                generateUserProfilesExcel(sheet, data, headerStyle);
                break;
            default:
                generateGenericDataExcel(sheet, data);
        }
    }

    private void generateTransactionSummaryPDF(Document document, List<TransactionSummaryDTO> data)
            throws DocumentException {
        try {
            // Generar gráfico de gastos por categoría
            Map<String, Double> categoryExpensesData = new java.util.HashMap<>();
            for (TransactionSummaryDTO item : data) {
                if (item.getTotalExpenses() != null) {
                    categoryExpensesData.put(
                        item.getCategoryName() != null ? item.getCategoryName() : "N/A",
                        item.getTotalExpenses().doubleValue());
                }
            }
            
            if (!categoryExpensesData.isEmpty()) {
                byte[] chartBytes = chartGenerationService.generateCategoryExpenseChart(categoryExpensesData);
                if (chartBytes.length > 0) {
                    Image chart = Image.getInstance(chartBytes);
                    chart.scalePercent(80);
                    chart.setAlignment(Element.ALIGN_CENTER);
                    document.add(chart);
                    document.add(new Paragraph("\n"));
                }
            }
        } catch (Exception e) {
            LOGGER.warn("Error generando gráfico: {}", e.getMessage());
        }
        
        // Crear tabla con mejor formato
        PdfPTable table = new PdfPTable(4);
        table.setWidthPercentage(100);
        table.setWidths(new float[]{3, 2, 2, 2});

        // Headers con estilo
        com.itextpdf.text.Font headerFont = new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.HELVETICA, 12, com.itextpdf.text.Font.BOLD);
        
        PdfPCell headerCell1 = new PdfPCell(new Phrase("Categoría", headerFont));
        headerCell1.setBackgroundColor(PRIMARY_COLOR);
        headerCell1.setHorizontalAlignment(Element.ALIGN_CENTER);
        headerCell1.setPadding(8);
        table.addCell(headerCell1);
        
        PdfPCell headerCell2 = new PdfPCell(new Phrase("Ingresos", headerFont));
        headerCell2.setBackgroundColor(PRIMARY_COLOR);
        headerCell2.setHorizontalAlignment(Element.ALIGN_CENTER);
        headerCell2.setPadding(8);
        table.addCell(headerCell2);
        
        PdfPCell headerCell3 = new PdfPCell(new Phrase("Gastos", headerFont));
        headerCell3.setBackgroundColor(PRIMARY_COLOR);
        headerCell3.setHorizontalAlignment(Element.ALIGN_CENTER);
        headerCell3.setPadding(8);
        table.addCell(headerCell3);
        
        PdfPCell headerCell4 = new PdfPCell(new Phrase("Balance", headerFont));
        headerCell4.setBackgroundColor(PRIMARY_COLOR);
        headerCell4.setHorizontalAlignment(Element.ALIGN_CENTER);
        headerCell4.setPadding(8);
        table.addCell(headerCell4);

        // Data con formato alterno
        com.itextpdf.text.Font dataFont = new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.HELVETICA, 10);
        boolean alternate = false;
        
        for (TransactionSummaryDTO item : data) {
            BaseColor rowColor = alternate ? BaseColor.LIGHT_GRAY : BaseColor.WHITE;
            
            PdfPCell cell1 = new PdfPCell(new Phrase(item.getCategoryName() != null ? item.getCategoryName() : "N/A", dataFont));
            cell1.setBackgroundColor(rowColor);
            cell1.setPadding(5);
            table.addCell(cell1);
            
            PdfPCell cell2 = new PdfPCell(new Phrase(formatAmount(item.getTotalIncome()), dataFont));
            cell2.setBackgroundColor(rowColor);
            cell2.setHorizontalAlignment(Element.ALIGN_RIGHT);
            cell2.setPadding(5);
            table.addCell(cell2);
            
            PdfPCell cell3 = new PdfPCell(new Phrase(formatAmount(item.getTotalExpenses()), dataFont));
            cell3.setBackgroundColor(rowColor);
            cell3.setHorizontalAlignment(Element.ALIGN_RIGHT);
            cell3.setPadding(5);
            table.addCell(cell3);
            
            PdfPCell cell4 = new PdfPCell(new Phrase(formatAmount(item.getNetAmount()), dataFont));
            cell4.setBackgroundColor(rowColor);
            cell4.setHorizontalAlignment(Element.ALIGN_RIGHT);
            cell4.setPadding(5);
            table.addCell(cell4);
            
            alternate = !alternate;
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
    
    // Métodos auxiliares para estilos Excel
    private CellStyle createHeaderStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        org.apache.poi.ss.usermodel.Font font = workbook.createFont();
        font.setBold(true);
        font.setColor(IndexedColors.WHITE.getIndex());
        style.setFont(font);
        style.setFillForegroundColor(IndexedColors.DARK_BLUE.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setAlignment(HorizontalAlignment.CENTER);
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
        return style;
    }
    
    private CellStyle createTitleStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        org.apache.poi.ss.usermodel.Font font = workbook.createFont();
        font.setBold(true);
        font.setFontHeightInPoints((short) 16);
        font.setColor(IndexedColors.DARK_BLUE.getIndex());
        style.setFont(font);
        style.setAlignment(HorizontalAlignment.CENTER);
        return style;
    }
    
    private CellStyle createDateStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        org.apache.poi.ss.usermodel.Font font = workbook.createFont();
        font.setItalic(true);
        font.setFontHeightInPoints((short) 10);
        style.setFont(font);
        return style;
    }
    
    private CellStyle createPositiveStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        org.apache.poi.ss.usermodel.Font font = workbook.createFont();
        font.setColor(IndexedColors.GREEN.getIndex());
        style.setFont(font);
        return style;
    }
    
    private CellStyle createNegativeStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        org.apache.poi.ss.usermodel.Font font = workbook.createFont();
        font.setColor(IndexedColors.RED.getIndex());
        style.setFont(font);
        return style;
    }
    
    private void applyConditionalFormatting(Sheet sheet, String functionName) {
        // Aplicar formato condicional según el tipo de reporte
        if ("BalanceOverTime".equals(functionName) || "IncomesAndExpensesByPeriod".equals(functionName)) {
            // Aplicar formato condicional para valores positivos/negativos en columna Balance (columna D)
            // Nota: Esta funcionalidad requiere implementación específica de POI
            LOGGER.info("Aplicando formato condicional para: {}", functionName);
        }
    }
    
    private void generateSummarySheet(Sheet sheet, String functionName, Object data, CellStyle headerStyle, CellStyle titleStyle) {
        // Título
        Row titleRow = sheet.createRow(0);
        Cell titleCell = titleRow.createCell(0);
        titleCell.setCellValue("Resumen - " + functionName);
        titleCell.setCellStyle(titleStyle);
        
        // Generar resumen según el tipo de función
        switch (functionName) {
            case "BalanceOverTime":
            case "IncomesAndExpensesByPeriod":
                generateTransactionSummary(sheet, (List<TransactionSummaryDTO>) data, headerStyle);
                break;
            case "analyzeDebtRisk":
                generateDebtSummary(sheet, (List<DebtDTO>) data, headerStyle);
                break;
            case "compareFinancialPeriods":
                generateBudgetSummary(sheet, (List<BudgetVsActualDTO>) data, headerStyle);
                break;
            default:
                Row row = sheet.createRow(2);
                row.createCell(0).setCellValue("Resumen no disponible para este tipo de reporte");
        }
    }
    
    private void generateChartsSheet(Sheet sheet, String functionName, Object data, CellStyle headerStyle) {
        // Título
        Row titleRow = sheet.createRow(0);
        Cell titleCell = titleRow.createCell(0);
        titleCell.setCellValue("Datos para Gráficos - " + functionName);
        titleCell.setCellStyle(headerStyle);
        
        // Preparar datos para gráficos
        if ("BalanceOverTime".equals(functionName) || "IncomesAndExpensesByPeriod".equals(functionName)) {
            prepareChartData(sheet, (List<TransactionSummaryDTO>) data, headerStyle);
        }
    }
    
    private void generateTransactionSummary(Sheet sheet, List<TransactionSummaryDTO> data, CellStyle headerStyle) {
        Row headerRow = sheet.createRow(2);
        headerRow.createCell(0).setCellValue("Métrica");
        headerRow.createCell(1).setCellValue("Valor");
        
        for (Cell cell : headerRow) {
            cell.setCellStyle(headerStyle);
        }
        
        // Calcular totales
        double totalIncome = data.stream().mapToDouble(item -> getDoubleValue(item.getTotalIncome())).sum();
        double totalExpenses = data.stream().mapToDouble(item -> getDoubleValue(item.getTotalExpenses())).sum();
        double totalBalance = data.stream().mapToDouble(item -> getDoubleValue(item.getNetAmount())).sum();
        
        int rowNum = 3;
        
        Row row1 = sheet.createRow(rowNum++);
        row1.createCell(0).setCellValue("Total Ingresos");
        row1.createCell(1).setCellValue(totalIncome);
        
        Row row2 = sheet.createRow(rowNum++);
        row2.createCell(0).setCellValue("Total Gastos");
        row2.createCell(1).setCellValue(totalExpenses);
        
        Row row3 = sheet.createRow(rowNum++);
        row3.createCell(0).setCellValue("Balance Total");
        row3.createCell(1).setCellValue(totalBalance);
        
        Row row4 = sheet.createRow(rowNum++);
        row4.createCell(0).setCellValue("Categorías Analizadas");
        row4.createCell(1).setCellValue(data.size());
    }
    
    private void generateDebtSummary(Sheet sheet, List<DebtDTO> data, CellStyle headerStyle) {
        Row headerRow = sheet.createRow(2);
        headerRow.createCell(0).setCellValue("Métrica");
        headerRow.createCell(1).setCellValue("Valor");
        
        for (Cell cell : headerRow) {
            cell.setCellStyle(headerStyle);
        }
        
        double totalDebt = data.stream().mapToDouble(item -> getDoubleValue(item.getPendingAmount())).sum();
        long activeDebts = data.stream().filter(debt -> debt.getState() != null && !debt.getState().name().equals("PAID")).count();
        
        int rowNum = 3;
        
        Row row1 = sheet.createRow(rowNum++);
        row1.createCell(0).setCellValue("Total Deuda Pendiente");
        row1.createCell(1).setCellValue(totalDebt);
        
        Row row2 = sheet.createRow(rowNum++);
        row2.createCell(0).setCellValue("Deudas Activas");
        row2.createCell(1).setCellValue(activeDebts);
        
        Row row3 = sheet.createRow(rowNum++);
        row3.createCell(0).setCellValue("Total Deudas");
        row3.createCell(1).setCellValue(data.size());
    }
    
    private void generateBudgetSummary(Sheet sheet, List<BudgetVsActualDTO> data, CellStyle headerStyle) {
        Row headerRow = sheet.createRow(2);
        headerRow.createCell(0).setCellValue("Métrica");
        headerRow.createCell(1).setCellValue("Valor");
        
        for (Cell cell : headerRow) {
            cell.setCellStyle(headerStyle);
        }
        
        double totalBudget = data.stream().mapToDouble(item -> getDoubleValue(item.getAssignedAmount())).sum();
        double totalSpent = data.stream().mapToDouble(item -> getDoubleValue(item.getActualSpent())).sum();
        double variance = totalBudget - totalSpent;
        
        int rowNum = 3;
        
        Row row1 = sheet.createRow(rowNum++);
        row1.createCell(0).setCellValue("Presupuesto Total");
        row1.createCell(1).setCellValue(totalBudget);
        
        Row row2 = sheet.createRow(rowNum++);
        row2.createCell(0).setCellValue("Gasto Total");
        row2.createCell(1).setCellValue(totalSpent);
        
        Row row3 = sheet.createRow(rowNum++);
        row3.createCell(0).setCellValue("Variación");
        row3.createCell(1).setCellValue(variance);
        
        Row row4 = sheet.createRow(rowNum++);
        row4.createCell(0).setCellValue("Utilización %");
        row4.createCell(1).setCellValue(totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0);
    }
    
    private void prepareChartData(Sheet sheet, List<TransactionSummaryDTO> data, CellStyle headerStyle) {
        Row headerRow = sheet.createRow(2);
        headerRow.createCell(0).setCellValue("Categoría");
        headerRow.createCell(1).setCellValue("Gastos");
        headerRow.createCell(2).setCellValue("Ingresos");
        
        for (Cell cell : headerRow) {
            cell.setCellStyle(headerStyle);
        }
        
        int rowNum = 3;
        for (TransactionSummaryDTO item : data) {
            Row row = sheet.createRow(rowNum++);
            row.createCell(0).setCellValue(item.getCategoryName() != null ? item.getCategoryName() : "N/A");
            row.createCell(1).setCellValue(getDoubleValue(item.getTotalExpenses()));
            row.createCell(2).setCellValue(getDoubleValue(item.getTotalIncome()));
        }
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
    
    // Métodos para manejar UserProfilesWithTransactionsDTO
    private void generateUserProfilesPDF(Document document, Object data) throws DocumentException {
        if (data instanceof List<?>) {
            List<?> userProfiles = (List<?>) data;
            if (!userProfiles.isEmpty() && userProfiles.get(0).getClass().getSimpleName().contains("UserProfiles")) {
                generateFormattedUserProfilesPDF(document, userProfiles);
                return;
            }
        }
        // Fallback a formato genérico si no es el tipo esperado
        generateGenericDataPDF(document, data);
    }
    
    private void generateUserProfilesExcel(Sheet sheet, Object data, CellStyle headerStyle) {
        if (data instanceof List<?>) {
            List<?> userProfiles = (List<?>) data;
            if (!userProfiles.isEmpty() && userProfiles.get(0).getClass().getSimpleName().contains("UserProfiles")) {
                generateFormattedUserProfilesExcel(sheet, userProfiles, headerStyle);
                return;
            }
        }
        // Fallback a formato genérico si no es el tipo esperado
        generateGenericDataExcel(sheet, data);
    }
    
    private void generateFormattedUserProfilesPDF(Document document, List<?> userProfiles) throws DocumentException {
        // Título de sección
        com.itextpdf.text.Font sectionFont = new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.HELVETICA, 14, com.itextpdf.text.Font.BOLD);
        Paragraph sectionTitle = new Paragraph("Resumen de Actividad Financiera", sectionFont);
        sectionTitle.setAlignment(Element.ALIGN_LEFT);
        document.add(sectionTitle);
        document.add(new Paragraph("\n"));
        
        try {
            // Usamos reflexión para extraer información de forma segura
            for (Object userProfile : userProfiles) {
                Class<?> clazz = userProfile.getClass();
                
                // Información del usuario
                com.itextpdf.text.Font userFont = new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.HELVETICA, 12, com.itextpdf.text.Font.BOLD);
                
                String username = getFieldValue(userProfile, "username", String.class, "Usuario no especificado");
                String email = getFieldValue(userProfile, "email", String.class, "Email no especificado");
                
                Paragraph userInfo = new Paragraph("Usuario: " + username + " (" + email + ")", userFont);
                document.add(userInfo);
                document.add(new Paragraph("\n"));
                
                // Obtener lista de perfiles
                List<?> profiles = getFieldValue(userProfile, "profiles", List.class, java.util.Collections.emptyList());
                
                for (Object profile : profiles) {
                    generateProfileSectionPDF(document, profile);
                }
            }
        } catch (Exception e) {
            LOGGER.error("Error procesando datos de usuario: {}", e.getMessage());
            // Fallback a mostrar información básica
            document.add(new Paragraph("Se encontraron " + userProfiles.size() + " perfiles de usuario con información financiera."));
        }
    }
    
    private void generateProfileSectionPDF(Document document, Object profile) throws DocumentException {
        try {
            String profileName = getFieldValue(profile, "username", String.class, "Perfil sin nombre");
            String profileEmail = getFieldValue(profile, "email", String.class, "N/A");
            Integer transactionCount = getFieldValue(profile, "transactionCount", Integer.class, 0);
            Double totalAmount = getFieldValue(profile, "totalAmount", Double.class, 0.0);
            
            // Información del perfil
            com.itextpdf.text.Font profileFont = new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.HELVETICA, 11, com.itextpdf.text.Font.BOLD);
            Paragraph profileInfo = new Paragraph("Perfil: " + profileName, profileFont);
            document.add(profileInfo);
            
            // Crear tabla de resumen
            PdfPTable summaryTable = new PdfPTable(2);
            summaryTable.setWidthPercentage(70);
            summaryTable.setWidths(new float[]{1.5f, 1f});
            
            com.itextpdf.text.Font labelFont = new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.HELVETICA, 10, com.itextpdf.text.Font.BOLD);
            com.itextpdf.text.Font valueFont = new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.HELVETICA, 10);
            
            // Email del perfil
            PdfPCell emailLabelCell = new PdfPCell(new Phrase("Email:", labelFont));
            emailLabelCell.setBorder(Rectangle.NO_BORDER);
            emailLabelCell.setPadding(3);
            summaryTable.addCell(emailLabelCell);
            
            PdfPCell emailValueCell = new PdfPCell(new Phrase(profileEmail, valueFont));
            emailValueCell.setBorder(Rectangle.NO_BORDER);
            emailValueCell.setPadding(3);
            summaryTable.addCell(emailValueCell);
            
            // Número de transacciones
            PdfPCell transLabelCell = new PdfPCell(new Phrase("Total de Transacciones:", labelFont));
            transLabelCell.setBorder(Rectangle.NO_BORDER);
            transLabelCell.setPadding(3);
            summaryTable.addCell(transLabelCell);
            
            PdfPCell transValueCell = new PdfPCell(new Phrase(transactionCount.toString(), valueFont));
            transValueCell.setBorder(Rectangle.NO_BORDER);
            transValueCell.setPadding(3);
            summaryTable.addCell(transValueCell);
            
            // Monto total
            PdfPCell amountLabelCell = new PdfPCell(new Phrase("Monto Total Analizado:", labelFont));
            amountLabelCell.setBorder(Rectangle.NO_BORDER);
            amountLabelCell.setPadding(3);
            summaryTable.addCell(amountLabelCell);
            
            PdfPCell amountValueCell = new PdfPCell(new Phrase("$" + String.format("%.2f", totalAmount), valueFont));
            amountValueCell.setBorder(Rectangle.NO_BORDER);
            amountValueCell.setPadding(3);
            summaryTable.addCell(amountValueCell);
            
            document.add(summaryTable);
            
            // Información de transacciones resumida
            List<?> transactions = getFieldValue(profile, "transactions", List.class, java.util.Collections.emptyList());
            if (!transactions.isEmpty()) {
                generateTransactionSummaryForProfilePDF(document, transactions);
            }
            
            document.add(new Paragraph("\n"));
            
        } catch (Exception e) {
            LOGGER.error("Error procesando perfil: {}", e.getMessage());
            document.add(new Paragraph("Error procesando información del perfil"));
        }
    }
    
    private void generateTransactionSummaryForProfilePDF(Document document, List<?> transactions) throws DocumentException {
        // Agrupar transacciones por tipo
        Map<String, Double> incomesByCategory = new java.util.HashMap<>();
        Map<String, Double> expensesByCategory = new java.util.HashMap<>();
        double totalIncome = 0.0;
        double totalExpenses = 0.0;
        
        LOGGER.info("Procesando {} transacciones para el reporte", transactions.size());
        
        for (Object transaction : transactions) {
            try {
                // Intentar diferentes formas de extraer el monto
                Double amount = null;
                if (amount == null) amount = getFieldValue(transaction, "amount", Double.class, null);
                if (amount == null) {
                    BigDecimal amountBD = getFieldValue(transaction, "amount", BigDecimal.class, null);
                    if (amountBD != null) amount = amountBD.doubleValue();
                }
                if (amount == null) {
                    Integer amountInt = getFieldValue(transaction, "amount", Integer.class, null);
                    if (amountInt != null) amount = amountInt.doubleValue();
                }
                
                if (amount == null || amount == 0.0) {
                    LOGGER.debug("Transacción sin monto válido: {}", transaction.getClass().getSimpleName());
                    continue;
                }
                
                Object description = getFieldValue(transaction, "description", Object.class, null);
                String type = "UNKNOWN";
                String descText = "Sin descripción";
                
                if (description != null) {
                    descText = getFieldValue(description, "description", String.class, "Sin descripción");
                    type = getFieldValue(description, "type", String.class, "UNKNOWN");
                } else {
                    // Intentar obtener el tipo directamente de la transacción
                    type = getFieldValue(transaction, "type", String.class, "UNKNOWN");
                    descText = getFieldValue(transaction, "description", String.class, "Sin descripción");
                }
                
                LOGGER.debug("Procesando transacción: tipo={}, monto={}, descripción={}", type, amount, descText);
                
                if ("INCOME".equals(type)) {
                    totalIncome += amount;
                    incomesByCategory.merge(descText, amount, Double::sum);
                } else if ("EXPENSE".equals(type)) {
                    totalExpenses += amount;
                    expensesByCategory.merge(descText, amount, Double::sum);
                } else {
                    // Si no tiene tipo específico, asumimos que es gasto si el campo no está definido
                    LOGGER.debug("Tipo de transacción desconocido '{}', agregando como gasto", type);
                    totalExpenses += amount;
                    expensesByCategory.merge(descText, amount, Double::sum);
                }
            } catch (Exception e) {
                LOGGER.warn("Error procesando transacción individual: {}", e.getMessage(), e);
            }
        }
        
        LOGGER.info("Resumen procesado - Ingresos: {}, Gastos: {}", totalIncome, totalExpenses);
        
        // Crear tabla de resumen financiero
        PdfPTable financialTable = new PdfPTable(3);
        financialTable.setWidthPercentage(90);
        financialTable.setWidths(new float[]{2f, 1f, 1f});
        
        // Headers
        com.itextpdf.text.Font headerFont = new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.HELVETICA, 10, com.itextpdf.text.Font.BOLD);
        
        PdfPCell header1 = new PdfPCell(new Phrase("Resumen Financiero", headerFont));
        header1.setBackgroundColor(SECONDARY_COLOR);
        header1.setHorizontalAlignment(Element.ALIGN_CENTER);
        header1.setPadding(5);
        financialTable.addCell(header1);
        
        PdfPCell header2 = new PdfPCell(new Phrase("Total Ingresos", headerFont));
        header2.setBackgroundColor(SECONDARY_COLOR);
        header2.setHorizontalAlignment(Element.ALIGN_CENTER);
        header2.setPadding(5);
        financialTable.addCell(header2);
        
        PdfPCell header3 = new PdfPCell(new Phrase("Total Gastos", headerFont));
        header3.setBackgroundColor(SECONDARY_COLOR);
        header3.setHorizontalAlignment(Element.ALIGN_CENTER);
        header3.setPadding(5);
        financialTable.addCell(header3);
        
        // Datos
        com.itextpdf.text.Font dataFont = new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.HELVETICA, 10);
        
        PdfPCell balanceCell = new PdfPCell(new Phrase("Balance: $" + String.format("%.2f", totalIncome - totalExpenses), dataFont));
        balanceCell.setPadding(5);
        financialTable.addCell(balanceCell);
        
        PdfPCell incomeCell = new PdfPCell(new Phrase("$" + String.format("%.2f", totalIncome), dataFont));
        incomeCell.setHorizontalAlignment(Element.ALIGN_RIGHT);
        incomeCell.setPadding(5);
        financialTable.addCell(incomeCell);
        
        PdfPCell expenseCell = new PdfPCell(new Phrase("$" + String.format("%.2f", totalExpenses), dataFont));
        expenseCell.setHorizontalAlignment(Element.ALIGN_RIGHT);
        expenseCell.setPadding(5);
        financialTable.addCell(expenseCell);
        
        document.add(financialTable);
        document.add(new Paragraph("\n"));
        
        // Generar gráfico de distribución de transacciones
        try {
            if (!incomesByCategory.isEmpty() || !expensesByCategory.isEmpty()) {
                Map<String, Double> combinedData = new java.util.HashMap<>();
                combinedData.putAll(expensesByCategory);
                
                byte[] chartBytes = chartGenerationService.generateCategoryExpenseChart(combinedData);
                if (chartBytes.length > 0) {
                    Image chart = Image.getInstance(chartBytes);
                    chart.scalePercent(60);
                    chart.setAlignment(Element.ALIGN_CENTER);
                    document.add(chart);
                    document.add(new Paragraph("\n"));
                }
            }
        } catch (Exception e) {
            LOGGER.warn("Error generando gráfico de transacciones: {}", e.getMessage());
        }
        
        // Agregar análisis de salud financiera
        generateHealthScoreSection(document, totalIncome, totalExpenses, transactions.size());
        document.add(new Paragraph("\n"));
    }
    
    private void generateFormattedUserProfilesExcel(Sheet sheet, List<?> userProfiles, CellStyle headerStyle) {
        int rowNum = 3;
        
        // Headers
        Row headerRow = sheet.createRow(rowNum++);
        headerRow.createCell(0).setCellValue("Usuario");
        headerRow.createCell(1).setCellValue("Email");
        headerRow.createCell(2).setCellValue("Perfil");
        headerRow.createCell(3).setCellValue("Total Transacciones");
        headerRow.createCell(4).setCellValue("Monto Total");
        
        for (Cell cell : headerRow) {
            cell.setCellStyle(headerStyle);
        }
        
        // Datos
        for (Object userProfile : userProfiles) {
            try {
                String username = getFieldValue(userProfile, "username", String.class, "N/A");
                String email = getFieldValue(userProfile, "email", String.class, "N/A");
                List<?> profiles = getFieldValue(userProfile, "profiles", List.class, java.util.Collections.emptyList());
                
                for (Object profile : profiles) {
                    Row dataRow = sheet.createRow(rowNum++);
                    
                    String profileName = getFieldValue(profile, "username", String.class, "N/A");
                    Integer transactionCount = getFieldValue(profile, "transactionCount", Integer.class, 0);
                    Double totalAmount = getFieldValue(profile, "totalAmount", Double.class, 0.0);
                    
                    dataRow.createCell(0).setCellValue(username);
                    dataRow.createCell(1).setCellValue(email);
                    dataRow.createCell(2).setCellValue(profileName);
                    dataRow.createCell(3).setCellValue(transactionCount);
                    dataRow.createCell(4).setCellValue(totalAmount);
                }
            } catch (Exception e) {
                LOGGER.error("Error procesando datos para Excel: {}", e.getMessage());
                Row errorRow = sheet.createRow(rowNum++);
                errorRow.createCell(0).setCellValue("Error procesando datos");
            }
        }
    }
    
    private void generateGenericDataPDF(Document document, Object data) throws DocumentException {
        com.itextpdf.text.Font infoFont = new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.HELVETICA, 12);
        
        Paragraph info = new Paragraph("Información del Análisis", infoFont);
        info.setAlignment(Element.ALIGN_LEFT);
        document.add(info);
        document.add(new Paragraph("\n"));
        
        if (data instanceof List<?>) {
            List<?> dataList = (List<?>) data;
            Paragraph listInfo = new Paragraph("Se analizaron " + dataList.size() + " elementos de datos financieros.", infoFont);
            document.add(listInfo);
            
            if (!dataList.isEmpty()) {
                Paragraph typeInfo = new Paragraph("Tipo de datos: " + dataList.get(0).getClass().getSimpleName(), infoFont);
                document.add(typeInfo);
            }
        } else {
            Paragraph genericInfo = new Paragraph("Datos financieros procesados exitosamente.", infoFont);
            document.add(genericInfo);
        }
    }
    
    private void generateGenericDataExcel(Sheet sheet, Object data) {
        Row headerRow = sheet.createRow(3);
        headerRow.createCell(0).setCellValue("Información del Análisis");
        
        Row dataRow = sheet.createRow(4);
        if (data instanceof List<?>) {
            List<?> dataList = (List<?>) data;
            dataRow.createCell(0).setCellValue("Elementos analizados: " + dataList.size());
            
            if (!dataList.isEmpty()) {
                Row typeRow = sheet.createRow(5);
                typeRow.createCell(0).setCellValue("Tipo de datos: " + dataList.get(0).getClass().getSimpleName());
            }
        } else {
            dataRow.createCell(0).setCellValue("Datos financieros procesados exitosamente");
        }
    }
    
    // Método auxiliar para extraer valores de campos usando reflexión de forma segura
    @SuppressWarnings("unchecked")
    private <T> T getFieldValue(Object object, String fieldName, Class<T> expectedType, T defaultValue) {
        try {
            Class<?> clazz = object.getClass();
            
            // Intentar primero con el campo directo
            try {
                java.lang.reflect.Field field = clazz.getDeclaredField(fieldName);
                field.setAccessible(true);
                Object value = field.get(object);
                
                if (value != null && expectedType.isAssignableFrom(value.getClass())) {
                    return (T) value;
                } else if (value != null && expectedType == Double.class && value instanceof Number) {
                    return (T) Double.valueOf(((Number) value).doubleValue());
                } else if (value != null && expectedType == Integer.class && value instanceof Number) {
                    return (T) Integer.valueOf(((Number) value).intValue());
                } else if (value != null && expectedType == BigDecimal.class && value instanceof Number) {
                    return (T) new BigDecimal(value.toString());
                }
            } catch (NoSuchFieldException e) {
                // Intentar con getter method
                String getterName = "get" + fieldName.substring(0, 1).toUpperCase() + fieldName.substring(1);
                try {
                    java.lang.reflect.Method getter = clazz.getMethod(getterName);
                    Object value = getter.invoke(object);
                    
                    if (value != null && expectedType.isAssignableFrom(value.getClass())) {
                        return (T) value;
                    } else if (value != null && expectedType == Double.class && value instanceof Number) {
                        return (T) Double.valueOf(((Number) value).doubleValue());
                    } else if (value != null && expectedType == Integer.class && value instanceof Number) {
                        return (T) Integer.valueOf(((Number) value).intValue());
                    } else if (value != null && expectedType == BigDecimal.class && value instanceof Number) {
                        return (T) new BigDecimal(value.toString());
                    }
                } catch (Exception me) {
                    LOGGER.debug("No se pudo acceder al getter '{}': {}", getterName, me.getMessage());
                }
            }
        } catch (Exception e) {
            LOGGER.debug("No se pudo extraer el campo '{}': {}", fieldName, e.getMessage());
        }
        return defaultValue;
    }
    
    // Método para generar sección de puntuación de salud financiera
    private void generateHealthScoreSection(Document document, double totalIncome, double totalExpenses, int transactionCount) throws DocumentException {
        double balance = totalIncome - totalExpenses;
        int healthScore = calculateFinancialHealthScore(totalIncome, totalExpenses, transactionCount);
        String healthGrade = getHealthGrade(healthScore);
        
        // Título de la sección
        com.itextpdf.text.Font sectionFont = new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.HELVETICA, 12, com.itextpdf.text.Font.BOLD);
        Paragraph healthTitle = new Paragraph("Evaluación de Salud Financiera", sectionFont);
        healthTitle.setAlignment(Element.ALIGN_LEFT);
        document.add(healthTitle);
        document.add(new Paragraph("\n"));
        
        // Crear tabla de puntuación
        PdfPTable scoreTable = new PdfPTable(2);
        scoreTable.setWidthPercentage(60);
        scoreTable.setWidths(new float[]{1.2f, 0.8f});
        
        com.itextpdf.text.Font labelFont = new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.HELVETICA, 10, com.itextpdf.text.Font.BOLD);
        com.itextpdf.text.Font valueFont = new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.HELVETICA, 10);
        
        // Score
        PdfPCell scoreLabelCell = new PdfPCell(new Phrase("Puntuación de Salud Financiera:", labelFont));
        scoreLabelCell.setBorder(Rectangle.BOX);
        scoreLabelCell.setPadding(5);
        scoreLabelCell.setBackgroundColor(BaseColor.LIGHT_GRAY);
        scoreTable.addCell(scoreLabelCell);
        
        PdfPCell scoreValueCell = new PdfPCell(new Phrase(healthScore + "/10 (" + healthGrade + ")", valueFont));
        scoreValueCell.setBorder(Rectangle.BOX);
        scoreValueCell.setPadding(5);
        scoreValueCell.setHorizontalAlignment(Element.ALIGN_CENTER);
        scoreTable.addCell(scoreValueCell);
        
        // Ratio Gastos/Ingresos
        double expenseRatio = totalIncome > 0 ? (totalExpenses / totalIncome) * 100 : 0;
        PdfPCell ratioLabelCell = new PdfPCell(new Phrase("Porcentaje de Gastos vs Ingresos:", labelFont));
        ratioLabelCell.setBorder(Rectangle.BOX);
        ratioLabelCell.setPadding(5);
        ratioLabelCell.setBackgroundColor(BaseColor.LIGHT_GRAY);
        scoreTable.addCell(ratioLabelCell);
        
        PdfPCell ratioValueCell = new PdfPCell(new Phrase(String.format("%.1f%%", expenseRatio), valueFont));
        ratioValueCell.setBorder(Rectangle.BOX);
        ratioValueCell.setPadding(5);
        ratioValueCell.setHorizontalAlignment(Element.ALIGN_CENTER);
        scoreTable.addCell(ratioValueCell);
        
        // Ahorro estimado
        PdfPCell savingsLabelCell = new PdfPCell(new Phrase("Capacidad de Ahorro:", labelFont));
        savingsLabelCell.setBorder(Rectangle.BOX);
        savingsLabelCell.setPadding(5);
        savingsLabelCell.setBackgroundColor(BaseColor.LIGHT_GRAY);
        scoreTable.addCell(savingsLabelCell);
        
        PdfPCell savingsValueCell = new PdfPCell(new Phrase(balance >= 0 ? "$" + String.format("%.2f", balance) : "Déficit", valueFont));
        savingsValueCell.setBorder(Rectangle.BOX);
        savingsValueCell.setPadding(5);
        savingsValueCell.setHorizontalAlignment(Element.ALIGN_CENTER);
        scoreTable.addCell(savingsValueCell);
        
        document.add(scoreTable);
        document.add(new Paragraph("\n"));
        
        // Recomendaciones
        generateRecommendations(document, healthScore, expenseRatio, balance);
    }
    
    private void generateRecommendations(Document document, int healthScore, double expenseRatio, double balance) throws DocumentException {
        com.itextpdf.text.Font recFont = new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.HELVETICA, 11, com.itextpdf.text.Font.BOLD);
        Paragraph recTitle = new Paragraph("Recomendaciones:", recFont);
        recTitle.setAlignment(Element.ALIGN_LEFT);
        document.add(recTitle);
        
        com.itextpdf.text.Font listFont = new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.HELVETICA, 10);
        com.itextpdf.text.List recommendations = new com.itextpdf.text.List(false, 10);
        recommendations.setListSymbol("• ");
        
        if (healthScore >= 8) {
            recommendations.add(new ListItem("¡Excelente! Mantén tus hábitos financieros actuales.", listFont));
            recommendations.add(new ListItem("Considera aumentar tus inversiones para hacer crecer tu patrimonio.", listFont));
            recommendations.add(new ListItem("Evalúa crear un fondo de emergencia equivalente a 6 meses de gastos.", listFont));
        } else if (healthScore >= 6) {
            recommendations.add(new ListItem("Tu salud financiera es buena, pero hay espacio para mejorar.", listFont));
            if (expenseRatio > 70) {
                recommendations.add(new ListItem("Intenta reducir tus gastos al 70% o menos de tus ingresos.", listFont));
            }
            recommendations.add(new ListItem("Establece metas de ahorro específicas y automáticas.", listFont));
            recommendations.add(new ListItem("Revisa tus gastos mensuales para identificar áreas de mejora.", listFont));
        } else if (healthScore >= 4) {
            recommendations.add(new ListItem("Tu situación financiera requiere atención.", listFont));
            recommendations.add(new ListItem("Crea un presupuesto detallado y síguelo estrictamente.", listFont));
            if (balance < 0) {
                recommendations.add(new ListItem("Prioriza reducir gastos innecesarios para evitar el déficit.", listFont));
            }
            recommendations.add(new ListItem("Considera buscar fuentes adicionales de ingresos.", listFont));
        } else {
            recommendations.add(new ListItem("Tu situación financiera requiere acción inmediata.", listFont));
            recommendations.add(new ListItem("Busca asesoría financiera profesional.", listFont));
            recommendations.add(new ListItem("Implementa un plan de reducción de gastos urgente.", listFont));
            recommendations.add(new ListItem("Considera restructurar deudas si las tienes.", listFont));
        }
        
        document.add(recommendations);
    }
    
    private int calculateFinancialHealthScore(double totalIncome, double totalExpenses, int transactionCount) {
        if (totalIncome <= 0) return 1;
        
        double balance = totalIncome - totalExpenses;
        double expenseRatio = totalExpenses / totalIncome;
        
        int score = 10; // Comenzar con puntuación perfecta
        
        // Penalizar por ratio de gastos alto
        if (expenseRatio > 0.9) {
            score -= 4; // Gastos > 90% de ingresos
        } else if (expenseRatio > 0.8) {
            score -= 3; // Gastos > 80% de ingresos
        } else if (expenseRatio > 0.7) {
            score -= 2; // Gastos > 70% de ingresos
        } else if (expenseRatio > 0.6) {
            score -= 1; // Gastos > 60% de ingresos
        }
        
        // Penalizar por balance negativo
        if (balance < 0) {
            score -= 3;
        } else if (balance < totalIncome * 0.1) {
            score -= 1; // Ahorro < 10% de ingresos
        }
        
        // Bonificar por consistencia (más transacciones indica actividad regular)
        if (transactionCount >= 20) {
            score += 1;
        }
        
        // Bonificar por balance positivo alto
        if (balance > totalIncome * 0.3) {
            score += 1;
        }
        
        return Math.max(1, Math.min(10, score));
    }
    
    private String getHealthGrade(int score) {
        if (score >= 9) return "Excelente";
        if (score >= 7) return "Muy Bueno";
        if (score >= 5) return "Bueno";
        if (score >= 3) return "Regular";
        return "Crítico";
    }
}
