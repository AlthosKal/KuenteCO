package org.kuenteco.backend.service.wompi;

public interface WompiWebhookService {
    void processWebhook(String payload, String signature);
}
