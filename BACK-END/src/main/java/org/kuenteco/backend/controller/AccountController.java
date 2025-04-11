package org.kuenteco.backend.controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.AllArgsConstructor;
import org.kuenteco.backend.dto.ApiMessage;
import org.kuenteco.backend.dto.account.NewAccountDTO;
import org.kuenteco.backend.dto.image.ImageDTO;
import org.kuenteco.backend.entity.Account;
import org.kuenteco.backend.jwt.JwtUtil;
import org.kuenteco.backend.repository.master.MasterAccountRepository;
import org.kuenteco.backend.repository.slave.SlaveAccountRepository;
import org.kuenteco.backend.service.account.AccountService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Optional;

@RestController
@RequestMapping("/v1/account")
@AllArgsConstructor
public class AccountController {

    private final AccountService accountService;
    private final MasterAccountRepository masterAccountRepository;
    private final SlaveAccountRepository slaveAccountRepository;
    private final JwtUtil jwtUtil;

    @GetMapping
    public Object getAllAccounts() {
        try {
            return new ResponseEntity<>(accountService.getAccounts(), HttpStatus.OK);
        } catch (Exception e) {
            return ResponseEntity.ok(new ApiMessage(e.getMessage()));
        } catch (Throwable e) {
            return ResponseEntity.badRequest().body(new ApiMessage(e.getMessage()));
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
            return ResponseEntity.status(HttpStatus.CREATED).body(new ApiMessage("Cuenta registrada correctamente"));
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(new ApiMessage(e.getMessage()), HttpStatus.BAD_REQUEST);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(new ApiMessage(e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiMessage> deleteAccount(Account account) throws IOException {
        try {
            accountService.deleteAccount(account);

            return ResponseEntity.status(HttpStatus.OK).body(new ApiMessage("Cuenta eliminada correctamente"));
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(new ApiMessage(e.getMessage()), HttpStatus.BAD_REQUEST);
        } catch (Exception e) {
            return new ResponseEntity<>(new ApiMessage("Se produjo un error"), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("image/add")
    public ResponseEntity<ImageDTO> uploadAccountImage(@PathVariable("accountId") Integer accountId,
            @RequestParam("image") MultipartFile image, @RequestHeader("Authorization") String token,
            HttpServletResponse response) {
        try {
            // Extraer el token Bearer
            String jwtToken = token.startsWith("Bearer ") ? token.substring(7) : token;
            String username = jwtUtil.extractEmail(jwtToken);

            // Buscar la cuenta y verificar que pertenezca al usuario
            Account account = masterAccountRepository.findById(accountId)
                    .orElseThrow(() -> new RuntimeException("Cuenta no encontrada"));

            // Verificar que la cuenta pertenece al usuario autenticado
            if (!account.getUser().getName().equals(username)) {
                return new ResponseEntity<>(HttpStatus.FORBIDDEN);
            }

            ImageDTO imageDTO = accountService.saveImage(image, account, response);
            return new ResponseEntity<>(imageDTO, HttpStatus.CREATED);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PutMapping("/image/update")
    public ResponseEntity<ImageDTO> updateAccountImage(@PathVariable("accountId") Integer accountId,
            @RequestParam("image") MultipartFile image, @RequestHeader("Authorization") String token,
            HttpServletResponse response) {
        try {
            // Extraer el token Bearer
            String jwtToken = token.startsWith("Bearer ") ? token.substring(7) : token;
            String username = jwtUtil.extractEmail(jwtToken);

            // Buscar la cuenta y verificar que pertenezca al usuario
            Account account = masterAccountRepository.findById(accountId)
                    .orElseThrow(() -> new RuntimeException("Cuenta no encontrada"));

            // Verificar que la cuenta pertenece al usuario autenticado
            if (!account.getUser().getName().equals(username)) {
                return new ResponseEntity<>(HttpStatus.FORBIDDEN);
            }

            ImageDTO imageDTO = accountService.updateImage(image, account, response);
            return new ResponseEntity<>(imageDTO, HttpStatus.OK);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @DeleteMapping("/delete")
    public ResponseEntity<Void> deleteAccountImage(@PathVariable("accountId") Integer accountId,
            @RequestHeader("Authorization") String token, HttpServletResponse response) {
        try {
            // Extraer el token Bearer
            String jwtToken = token.startsWith("Bearer ") ? token.substring(7) : token;
            String username = jwtUtil.extractEmail(jwtToken);

            // Buscar la cuenta y verificar que pertenezca al usuario
            Account account = masterAccountRepository.findById(accountId)
                    .orElseThrow(() -> new RuntimeException("Cuenta no encontrada"));

            // Verificar que la cuenta pertenece al usuario autenticado
            if (!account.getUser().getName().equals(username)) {
                return new ResponseEntity<>(HttpStatus.FORBIDDEN);
            }

            accountService.deleteImage(account, response);
            return new ResponseEntity<>(HttpStatus.NO_CONTENT);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
