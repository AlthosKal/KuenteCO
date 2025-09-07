package org.kuenteco.backend.service.logic.excel;

import static org.kuenteco.backend.service.auth.AuthServiceImpl.getCredentials;
import static org.kuenteco.backend.service.logic.excel.tool.ExcelValidator.*;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Objects;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.IntStream;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.kuenteco.backend.config.jwt.AuthCredentials;
import org.kuenteco.backend.entity.*;
import org.kuenteco.backend.entity.extra.DescriptionCategory;
import org.kuenteco.backend.entity.extra.DescriptionTransaction;
import org.kuenteco.backend.enums.State;
import org.kuenteco.backend.enums.StateDebt;
import org.kuenteco.backend.enums.TransactionType;
import org.kuenteco.backend.enums.UserType;
import org.kuenteco.backend.exception.exceptions.ExcelException;
import org.kuenteco.backend.repository.master.MasterBudgetRepository;
import org.kuenteco.backend.repository.master.MasterCategoryRepository;
import org.kuenteco.backend.repository.master.MasterDebtRepository;
import org.kuenteco.backend.repository.master.MasterTransactionRepository;
import org.kuenteco.backend.repository.slave.*;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

@Slf4j
@Service
@RequiredArgsConstructor
public class ExcelServiceImpl implements ExcelService {
    private final MasterBudgetRepository masterBudgetRepository;
    private final MasterCategoryRepository masterCategoryRepository;
    private final MasterDebtRepository masterDebtRepository;
    private final MasterTransactionRepository masterTransactionRepository;
    private final SlaveBudgetRepository slaveBudgetRepository;
    private final SlaveCategoryRepository slaveCategoryRepository;
    private final SlaveDebtRepository slaveDebtRepository;
    private final SlaveTransactionRepository slaveTransactionRepository;
    private final SlaveUserRepository slaveUserRepository;
    private final SlaveProfileRepository slaveProfileRepository;

    @Override
    public void exportData(HttpServletResponse response) {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();
        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(() -> new ExcelException("Usuario no encontrado"));
        try {
            Workbook workbook = new XSSFWorkbook();
            ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();

            exportTransactions(workbook, user);
            exportBudgets(workbook, user);
            exportCategories(workbook, user);
            exportDebts(workbook, user);
            workbook.write(byteArrayOutputStream);

            response.setContentType(
                    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition", "attachment; filename=finanzas.xlsx");
            response.getOutputStream().write(byteArrayOutputStream.toByteArray());
            response.getOutputStream().flush();
        } catch (Exception e) {
            log.error("Error al exportar archivo de Excel", e);
            throw new ExcelException("Error al exportar archivo de Excel");
        }
    }

    @Override
    public void importData(HttpServletRequest request) {
        AuthCredentials credentials = getCredentials();
        String email = credentials.email();

        User user =
                slaveUserRepository
                        .findByEmail(email)
                        .orElseThrow(() -> new ExcelException("Usuario no encontrado"));

        try {
            MultipartHttpServletRequest multiRequest = (MultipartHttpServletRequest) request;
            MultipartFile file = multiRequest.getFile("file");

            if (file == null || file.isEmpty()) {
                throw new ExcelException("Archivo no proporcionado o vacío");
            }

            try (Workbook workbook = new XSSFWorkbook(file.getInputStream())) {
                importTransactions(workbook.getSheet("Transacciones"), user);
                importBudgets(workbook.getSheet("Presupuestos"), user);
                importDebts(workbook.getSheet("Deudas"), user);
                importCategories(workbook.getSheet("Categorías"), user);
            }

        } catch (Exception e) {
            log.error("Error al importar archivo de Excel", e);
            throw new ExcelException("Error al importar archivo Excel: " + e.getMessage());
        }
    }

    private void exportTransactions(Workbook workbook, User user) {
        if (user.getType().equals(UserType.PERSONAL)) {
            List<Transaction> transactions = slaveTransactionRepository.findByUser(user);
            exportTransactionsByPersonalUser(workbook, transactions);
        } else if (user.getType().equals(UserType.BUSINESS)) {
            List<Profile> profiles = slaveProfileRepository.findByUser(user);
            List<Transaction> transactions =
                    profiles.stream()
                            .flatMap(p -> slaveTransactionRepository.findByProfile(p).stream())
                            .toList();
            exportTransactionsByBusinessUser(workbook, transactions);
        }
    }

    private void exportTransactionsByPersonalUser(
            Workbook workbook, List<Transaction> transactions) {
        Sheet sheet = workbook.createSheet("Transacciones");
        Row header = sheet.createRow(0);
        header.createCell(0).setCellValue("Nombre");
        header.createCell(1).setCellValue("Monto");
        header.createCell(2).setCellValue("Fecha");
        header.createCell(3).setCellValue("Descripción");
        header.createCell(4).setCellValue("Tipo");
        
        if (!transactions.isEmpty()) {
            AtomicInteger rowIdx = new AtomicInteger(1);
            DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy");
            transactions.forEach(
                    transaction -> {
                        Row row = sheet.createRow(rowIdx.getAndIncrement());
                        row.createCell(0).setCellValue(transaction.getName());
                        row.createCell(1).setCellValue(transaction.getAmount().doubleValue());
                        row.createCell(2).setCellValue(dtf.format(transaction.getTransactionDate()));
                        row.createCell(3).setCellValue(transaction.getDescription().getDescription());
                        row.createCell(4).setCellValue(transaction.getDescription().getType().name());
                    });
        }
    }

    private void exportTransactionsByBusinessUser(
            Workbook workbook, List<Transaction> transactions) {
        Sheet sheet = workbook.createSheet("Transacciones");
        Row header = sheet.createRow(0);
        header.createCell(0).setCellValue("Perfil Asociado");
        header.createCell(1).setCellValue("Nombre");
        header.createCell(2).setCellValue("Monto");
        header.createCell(3).setCellValue("Fecha");
        header.createCell(4).setCellValue("Descripción");
        header.createCell(5).setCellValue("Tipo");
        
        if (!transactions.isEmpty()) {
            AtomicInteger rowIdx = new AtomicInteger(1);
            DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy");
            transactions.forEach(
                    transaction -> {
                        Row row = sheet.createRow(rowIdx.getAndIncrement());
                        row.createCell(0).setCellValue(transaction.getProfile().getEmail());
                        row.createCell(1).setCellValue(transaction.getName());
                        row.createCell(2).setCellValue(transaction.getAmount().doubleValue());
                        row.createCell(3).setCellValue(dtf.format(transaction.getTransactionDate()));
                        row.createCell(4).setCellValue(transaction.getDescription().getDescription());
                        row.createCell(5).setCellValue(transaction.getDescription().getType().name());
                    });
        }
    }

    private void exportBudgets(Workbook workbook, User user) {
        Sheet sheet = workbook.createSheet("Presupuestos");
        Row header = sheet.createRow(0);
        header.createCell(0).setCellValue("Nombre");
        header.createCell(1).setCellValue("Total");
        header.createCell(2).setCellValue("Restante");

        List<Budget> budgets = slaveBudgetRepository.findByUser(user);
        
        if (!budgets.isEmpty()) {
            AtomicInteger rowIdx = new AtomicInteger(1);
            budgets.forEach(
                    budget -> {
                        Row row = sheet.createRow(rowIdx.getAndIncrement());
                        row.createCell(0).setCellValue(budget.getName());
                        row.createCell(1).setCellValue(budget.getTotalBudget().doubleValue());
                        row.createCell(2).setCellValue(budget.getRemainingBudget().doubleValue());
                    });
        }
    }

    private void exportCategories(Workbook workbook, User user) {
        Sheet sheet = workbook.createSheet("Categorías");
        Row header = sheet.createRow(0);
        header.createCell(0).setCellValue("Nombre");
        header.createCell(1).setCellValue("Presupuesto Asignado");
        header.createCell(2).setCellValue("Estado");
        header.createCell(3).setCellValue("Fecha de Registro");

        List<Category> categories = slaveCategoryRepository.findByUser(user);
        
        if (!categories.isEmpty()) {
            AtomicInteger rowIdx = new AtomicInteger(1);
            DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy");
            categories.forEach(
                    category -> {
                        Row row = sheet.createRow(rowIdx.getAndIncrement());
                        row.createCell(0).setCellValue(category.getName());
                        row.createCell(1)
                                .setCellValue(
                                        category.getDescription().getAssignedBudget().doubleValue());
                        row.createCell(2).setCellValue(category.getDescription().getState().name());
                        row.createCell(3).setCellValue(dtf.format(category.getRegisterDate()));
                    });
        }
    }

    private void exportDebts(Workbook workbook, User user) {
        Sheet sheet = workbook.createSheet("Deudas");
        Row header = sheet.createRow(0);
        header.createCell(0).setCellValue("Nombre");
        header.createCell(1).setCellValue("Total");
        header.createCell(2).setCellValue("Pendiente");
        header.createCell(3).setCellValue("Fecha de Inicio");
        header.createCell(4).setCellValue("Fecha de Expiración");
        header.createCell(5).setCellValue("Estado");

        List<Debt> debts = slaveDebtRepository.findByUser(user);
        
        if (!debts.isEmpty()) {
            AtomicInteger rowIdx = new AtomicInteger(1);
            DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd/MM/yyyy");
            debts.forEach(
                    debt -> {
                        Row row = sheet.createRow(rowIdx.getAndIncrement());
                        row.createCell(0).setCellValue(debt.getName());
                        row.createCell(1).setCellValue(debt.getTotalAmount().doubleValue());
                        row.createCell(2).setCellValue(debt.getPendingAmount().doubleValue());
                        row.createCell(3).setCellValue(dtf.format(debt.getStartDate()));
                        row.createCell(4).setCellValue(dtf.format(debt.getExpirationDate()));
                        row.createCell(5).setCellValue(debt.getState().name());
                    });
        }
    }

    private void importTransactions(Sheet sheet, User user) {
        if (sheet == null) throw new ExcelException("Hoja 'Transacciones' no encontrada");
        if (user.getType().equals(UserType.PERSONAL)) {
            List<Transaction> transactions = slaveTransactionRepository.findByUser(user);
            if (transactions.isEmpty()) {
                throw new ExcelException("No tienes Transacciones registradas");
            }
            importTransactionsByPersonalUser(sheet, user);
        } else if (user.getType().equals(UserType.BUSINESS)) {
            List<Profile> profiles = slaveProfileRepository.findByUser(user);
            List<Transaction> transactions =
                    profiles.stream()
                            .flatMap(p -> slaveTransactionRepository.findByProfile(p).stream())
                            .toList();
            if (transactions.isEmpty()) {
                throw new ExcelException("No tienes Transacciones registradas");
            }
            importTransactionsByBusinessUser(sheet, user);
        }
    }

    private void importTransactionsByPersonalUser(Sheet sheet, User user) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        AtomicInteger count = new AtomicInteger(0);

        IntStream.rangeClosed(1, sheet.getLastRowNum())
                .mapToObj(sheet::getRow)
                .filter(Objects::nonNull)
                .forEach(
                        row -> {
                            try {
                                String name = validateRequiredTextCell(row, 0, "Nombre");
                                BigDecimal amount =
                                        BigDecimal.valueOf(
                                                validateRequiredNumericCell(row, 1, "Monto"));
                                String dateStr = validateDateCellAsString(row, 2, "Fecha");
                                String desc = validateRequiredTextCell(row, 3, "Descripción");
                                String type = validateRequiredTextCell(row, 4, "Tipo");

                                Transaction tx =
                                        Transaction.builder()
                                                .user(user)
                                                .name(name)
                                                .amount(amount)
                                                .transactionDate(
                                                        LocalDate.parse(dateStr, formatter)
                                                                .atStartOfDay())
                                                .description(
                                                        new DescriptionTransaction(
                                                                desc,
                                                                TransactionType.valueOf(type)))
                                                .build();

                                masterTransactionRepository.save(tx);
                                count.incrementAndGet();

                            } catch (Exception e) {
                                log.warn(
                                        "Fila inválida en hoja 'Transacciones': {}",
                                        e.getMessage());
                            }
                        });

        log.info("Importadas {} transacciones correctamente", count.get());
    }

    private void importTransactionsByBusinessUser(Sheet sheet, User user) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        AtomicInteger count = new AtomicInteger(0);

        IntStream.rangeClosed(1, sheet.getLastRowNum())
                .mapToObj(sheet::getRow)
                .filter(Objects::nonNull)
                .forEach(
                        row -> {
                            try {
                                String profileEmail =
                                        validateRequiredTextCell(row, 0, "Perfil Asociado");
                                String name = validateRequiredTextCell(row, 1, "Nombre");
                                BigDecimal amount =
                                        BigDecimal.valueOf(
                                                validateRequiredNumericCell(row, 2, "Monto"));
                                String dateStr = validateDateCellAsString(row, 3, "Fecha");
                                String desc = validateRequiredTextCell(row, 4, "Descripción");
                                String type = validateRequiredTextCell(row, 5, "Tipo");

                                Profile profile =
                                        slaveProfileRepository
                                                .findByEmail(profileEmail)
                                                .orElseThrow(
                                                        () ->
                                                                new Exception(
                                                                        "Perfil no encontrado: "
                                                                                + profileEmail));
                                if (!profile.getUser().getId().equals(user.getId())) {
                                    throw new ExcelException(
                                            "El perfil '"
                                                    + profileEmail
                                                    + "' no pertenece a tu cuenta.");
                                }
                                Transaction tx =
                                        Transaction.builder()
                                                .profile(profile)
                                                .name(name)
                                                .amount(amount)
                                                .transactionDate(
                                                        LocalDate.parse(dateStr, formatter)
                                                                .atStartOfDay())
                                                .description(
                                                        new DescriptionTransaction(
                                                                desc,
                                                                TransactionType.valueOf(type)))
                                                .build();

                                masterTransactionRepository.save(tx);
                                count.incrementAndGet();

                            } catch (Exception e) {
                                log.warn(
                                        "Fila inválida en hoja 'Transacciones': {}",
                                        e.getMessage());
                            }
                        });

        log.info("Importadas {} transacciones correctamente", count.get());
    }

    private void importBudgets(Sheet sheet, User user) {
        if (sheet == null) throw new ExcelException("Hoja 'Presupuestos' no encontrada");

        AtomicInteger count = new AtomicInteger(0);

        IntStream.rangeClosed(1, sheet.getLastRowNum())
                .mapToObj(sheet::getRow)
                .filter(Objects::nonNull)
                .forEach(
                        row -> {
                            try {
                                String name = validateRequiredTextCell(row, 0, "Nombre");
                                BigDecimal total =
                                        BigDecimal.valueOf(
                                                validateRequiredNumericCell(row, 1, "Total"));
                                BigDecimal remaining =
                                        BigDecimal.valueOf(
                                                validateRequiredNumericCell(row, 2, "Restante"));

                                Budget budget =
                                        Budget.builder()
                                                .user(user)
                                                .name(name)
                                                .totalBudget(total)
                                                .remainingBudget(remaining)
                                                .build();

                                masterBudgetRepository.save(budget);
                                count.incrementAndGet();

                            } catch (Exception ex) {
                                log.warn(
                                        "Fila inválida en hoja 'Presupuestos': {}",
                                        ex.getMessage());
                            }
                        });

        log.info("Importados {} presupuestos correctamente", count.get());
    }

    private void importCategories(Sheet sheet, User user) {
        if (sheet == null) throw new ExcelException("Hoja 'Categorías' no encontrada");

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        AtomicInteger count = new AtomicInteger(0);

        IntStream.rangeClosed(1, sheet.getLastRowNum())
                .mapToObj(sheet::getRow)
                .filter(Objects::nonNull)
                .forEach(
                        row -> {
                            try {
                                String name = validateRequiredTextCell(row, 0, "Nombre");
                                BigDecimal assignedBudget =
                                        BigDecimal.valueOf(
                                                validateRequiredNumericCell(
                                                        row, 1, "Presupuesto Asignado"));
                                String stateStr = validateRequiredTextCell(row, 2, "Estado");
                                String startStr =
                                        validateDateCellAsString(row, 3, "Fecha de Registro");

                                DescriptionCategory description =
                                        new DescriptionCategory(
                                                assignedBudget, State.valueOf(stateStr));

                                Category category =
                                        Category.builder()
                                                .user(user)
                                                .name(name)
                                                .description(description)
                                                .registerDate(
                                                        LocalDate.parse(startStr, formatter)
                                                                .atStartOfDay())
                                                .build();

                                masterCategoryRepository.save(category);
                                count.incrementAndGet();

                            } catch (Exception ex) {
                                log.warn("Fila inválida en hoja 'Categorías': {}", ex.getMessage());
                            }
                        });

        log.info("Importadas {} categorías correctamente", count.get());
    }

    private void importDebts(Sheet sheet, User user) {
        if (sheet == null) throw new ExcelException("Hoja 'Deudas' no encontrada");

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        AtomicInteger count = new AtomicInteger(0);

        IntStream.rangeClosed(1, sheet.getLastRowNum())
                .mapToObj(sheet::getRow)
                .filter(Objects::nonNull)
                .forEach(
                        row -> {
                            try {
                                String name = validateRequiredTextCell(row, 0, "Nombre");
                                BigDecimal total =
                                        BigDecimal.valueOf(
                                                validateRequiredNumericCell(row, 1, "Total"));
                                BigDecimal pending =
                                        BigDecimal.valueOf(
                                                validateRequiredNumericCell(row, 2, "Pendiente"));
                                String startStr =
                                        validateDateCellAsString(row, 3, "Fecha de Inicio");
                                String endStr =
                                        validateDateCellAsString(row, 4, "Fecha de Expiración");
                                String stateStr = validateRequiredTextCell(row, 5, "Estado");

                                Debt debt =
                                        Debt.builder()
                                                .user(user)
                                                .name(name)
                                                .totalAmount(total)
                                                .pendingAmount(pending)
                                                .startDate(
                                                        LocalDate.parse(startStr, formatter)
                                                                .atStartOfDay())
                                                .expirationDate(
                                                        LocalDate.parse(endStr, formatter)
                                                                .atStartOfDay())
                                                .state(StateDebt.valueOf(stateStr))
                                                .build();

                                masterDebtRepository.save(debt);
                                count.incrementAndGet();

                            } catch (Exception ex) {
                                log.warn("Fila inválida en hoja 'Deudas': {}", ex.getMessage());
                            }
                        });

        log.info("Importadas {} deudas correctamente", count.get());
    }
}
