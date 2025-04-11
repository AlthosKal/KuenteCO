package org.kuenteco.backend.controller;

import lombok.RequiredArgsConstructor;
import org.kuenteco.backend.dto.businesslogic.BalanceDTO;
import org.kuenteco.backend.dto.businesslogic.BudgetRequestDTO;
import org.kuenteco.backend.dto.businesslogic.BudgetResponseDTO;
import org.kuenteco.backend.entity.Budget;
import org.kuenteco.backend.mapper.BudgetMapper;
import org.kuenteco.backend.service.businesslogic.budget.BudgetService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.Map;

@RestController
@RequestMapping("/v1/budgets")
@RequiredArgsConstructor
public class BudgetController {

    private final BudgetService budgetService;
    private final BudgetMapper budgetMapper;

    @PostMapping
    public ResponseEntity<BudgetResponseDTO> createBudget(@RequestBody BudgetRequestDTO requestDTO) {
        Budget createdBudget = budgetService.createBudget(requestDTO.getAccountId(), requestDTO.getTotalBudget());
        return new ResponseEntity<>(budgetMapper.toResponseDTO(createdBudget), HttpStatus.CREATED);
    }

    @PutMapping("/total/{accountId}")
    public ResponseEntity<BudgetResponseDTO> updateTotalBudget(@PathVariable Integer accountId,
            @RequestBody Map<String, Object> request) {
        BigDecimal totalBudget = new BigDecimal(request.get("totalBudget").toString());

        Budget updatedBudget = budgetService.updateTotalBudget(accountId, totalBudget);
        return ResponseEntity.ok(budgetMapper.toResponseDTO(updatedBudget));
    }

    @PutMapping("/remaining/{accountId}")
    public ResponseEntity<BudgetResponseDTO> updateRemainingBudget(@PathVariable Integer accountId,
            @RequestBody Map<String, Object> request) {
        BigDecimal remainingBudget = new BigDecimal(request.get("remainingBudget").toString());

        Budget updatedBudget = budgetService.updateRemainingBudget(accountId, remainingBudget);
        return ResponseEntity.ok(budgetMapper.toResponseDTO(updatedBudget));
    }

    @GetMapping("/{accountId}")
    public ResponseEntity<BudgetResponseDTO> getBudgetByAccountId(@PathVariable Integer accountId) {
        return budgetService.getBudgetByAccountId(accountId)
                .map(budget -> ResponseEntity.ok(budgetMapper.toResponseDTO(budget)))
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/recalculate/{accountId}")
    public ResponseEntity<BudgetResponseDTO> recalculateRemainingBudget(@PathVariable Integer accountId) {
        Budget recalculatedBudget = budgetService.recalculateRemainingBudget(accountId);
        return ResponseEntity.ok(budgetMapper.toResponseDTO(recalculatedBudget));
    }

    @GetMapping("/balance/{accountId}")
    public ResponseEntity<BalanceDTO> getFinancialBalance(@PathVariable Integer accountId) {
        BalanceDTO balance = budgetService.getFinancialBalance(accountId);
        return ResponseEntity.ok(balance);
    }
}