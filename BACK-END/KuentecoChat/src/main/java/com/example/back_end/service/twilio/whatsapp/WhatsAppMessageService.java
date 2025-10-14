package com.example.back_end.service.twilio.whatsapp;

public interface WhatsAppMessageService {
    void handleIncomingMessage(String from, String body);

    void handleMessageStatus(
            String messageSid,
            String messageStatus,
            String from,
            String to,
            String errorCode,
            String errorMessage);
}
