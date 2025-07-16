package org.kuenteco.backend.service.logic.excel.tool;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.usermodel.Row;
import org.kuenteco.backend.exception.exceptions.ExcelException;

public class ExcelValidator {

    public static String validateRequiredTextCell(Row row, int index, String fieldName) {
        Cell cell = row.getCell(index);
        if (cell == null || cell.getCellType() == CellType.BLANK) {
            throw new ExcelException(
                    "Campo obligatorio vacío: " + fieldName + ", fila " + row.getRowNum());
        }
        if (cell.getCellType() == CellType.FORMULA) {
            throw new ExcelException(
                    "Fórmulas no permitidas en: " + fieldName + ", fila " + row.getRowNum());
        }
        return cell.getStringCellValue().trim();
    }

    public static double validateRequiredNumericCell(Row row, int index, String fieldName) {
        Cell cell = row.getCell(index);
        if (cell == null || cell.getCellType() != CellType.NUMERIC) {
            throw new ExcelException(
                    "Campo numérico inválido: " + fieldName + ", fila " + row.getRowNum());
        }
        return cell.getNumericCellValue();
    }

    public static String validateDateCellAsString(Row row, int index, String fieldName) {
        Cell cell = row.getCell(index);
        if (cell == null || cell.getCellType() != CellType.STRING) {
            throw new ExcelException(
                    "Formato de fecha inválido en " + fieldName + ", fila " + row.getRowNum());
        }
        return cell.getStringCellValue().trim();
    }
}
