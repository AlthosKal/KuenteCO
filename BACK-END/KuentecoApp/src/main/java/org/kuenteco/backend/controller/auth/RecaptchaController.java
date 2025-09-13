package org.kuenteco.backend.controller.auth;

import lombok.RequiredArgsConstructor;
import org.kuenteco.backend.dto.auth.RecaptchaRequestDTO;
import org.kuenteco.backend.dto.auth.RecaptchaResponseDTO;
import org.kuenteco.backend.service.auth.RecaptchaService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/v1/recaptcha")
@RequiredArgsConstructor
public class RecaptchaController {
    private final RecaptchaService recaptchaService;

    @PostMapping("/verify")
    public ResponseEntity<?> verify(@RequestBody RecaptchaRequestDTO dto) {
        RecaptchaResponseDTO response = recaptchaService.verify(dto.getToken());
        if (response.isSuccess()) {
            return new ResponseEntity<>("Captcha válido ✅", HttpStatus.OK);
        } else {
            return new ResponseEntity<>("Captcha inválido ❌", HttpStatus.UNAUTHORIZED);
        }
    }
}
