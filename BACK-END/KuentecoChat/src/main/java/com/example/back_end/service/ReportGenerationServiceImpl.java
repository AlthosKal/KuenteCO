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
Image logo = Image.getInstance("src/main/resources/static/images/logo.png");
logo.scalePercent(50);
logo.setAlignment(Element.ALIGN_CENTER);
document.add(logo);

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
}
