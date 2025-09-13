package org.kuenteco.backend.service.auth;

import java.util.HashMap;
import java.util.Map;
import org.kuenteco.backend.dto.auth.RecaptchaResponseDTO;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class RecaptchaServiceImpl implements RecaptchaService {
    @Value("${recaptcha.secret-key}")
    private String secretKey;

    @Value("${recaptcha.google-url}")
    private String url;

    private final RestTemplate restTemplate = new RestTemplate();

    @Override
    public RecaptchaResponseDTO verify(String token) {
        Map<String, String> params = new HashMap<>();
        params.put("secret", secretKey);
        params.put("response", token);

        ResponseEntity<RecaptchaResponseDTO> response =
                restTemplate.postForEntity(
                        url + "?secret={secret}&response={response}",
                        null,
                        RecaptchaResponseDTO.class,
                        params);
        RecaptchaResponseDTO responseDTO = response.getBody();
        return responseDTO != null
                ? responseDTO
                : new RecaptchaResponseDTO(false, null, null, null);
    }
}
