package org.kuenteco.backend.service.wompi;

import com.fasterxml.jackson.core.JsonProcessingException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;

public interface WompiWebhookService {
    void processWebhook(String payload, String signature)
            throws NoSuchAlgorithmException, InvalidKeyException, JsonProcessingException;
}
