package org.kuenteco.backend.controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.AllArgsConstructor;
import org.kuenteco.backend.dto.ApiMessage;
import org.kuenteco.backend.dto.account.NewAccountDTO;
import org.kuenteco.backend.entity.master.MasterAccount;
import org.kuenteco.backend.entity.slave.SlaveAccount;
import org.kuenteco.backend.service.account.AccountService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/v1/account")
@AllArgsConstructor
public class AccountController {
    private final AccountService accountService;

    @GetMapping
    public Object getAllAccounts() {
        try {
            return new ResponseEntity<>(accountService.getAccounts(), HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(new ApiMessage(e.getMessage()),
                    HttpStatus.NO_CONTENT);
        }
    }

    @PostMapping("/register")
    public ResponseEntity<ApiMessage> registerAccount(@RequestBody NewAccountDTO newAccountDTO,
            HttpServletRequest request, HttpServletResponse response) {
        try {
            // Obtener el usuario autenticado
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            String username = authentication.getName(); // Obtener el nombre de usuario (email)

            accountService.registerAccount(newAccountDTO, username);
            return ResponseEntity.status(HttpStatus.CREATED).body(new ApiMessage("Account Register Successfully"));
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(new ApiMessage(e.getMessage()), HttpStatus.BAD_REQUEST);
        } catch (Exception e) {
            return new ResponseEntity<>(new ApiMessage("An error occurred" + e.getMessage()),
                    HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiMessage> deleteAccount(MasterAccount account) {
        try {
            accountService.deleteAccount(account);
            return ResponseEntity.status(HttpStatus.OK).body(new ApiMessage("Account deleted successfully"));
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(new ApiMessage(e.getMessage()), HttpStatus.BAD_REQUEST);
        } catch (Exception e) {
            return new ResponseEntity<>(new ApiMessage("An error occurred"), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
