package com.example.back_end.controller;

import com.example.back_end.service.twilio.whatsapp.WhatsAppMessageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/message")
@RequiredArgsConstructor
@CrossOrigin
public class WhatsAppMessageController {
    private final WhatsAppMessageService whatsAppMessageService;

    @PostMapping("/incoming")
    public ResponseEntity<String> handleIncomingMessage(
            @RequestParam("From") String from, @RequestParam("Body") String body) {
        whatsAppMessageService.handleIncomingMessage(from, body);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/status")
    public ResponseEntity<Void> handleMessageStatus(
            @RequestParam("MessageSid") String messageSid,
            @RequestParam("MessageStatus") String messageStatus,
            @RequestParam(value = "From", required = false) String from,
            @RequestParam(value = "To", required = false) String to,
            @RequestParam(value = "ErrorCode", required = false) String errorCode,
            @RequestParam(value = "ErrorMessage", required = false) String errorMessage) {

        whatsAppMessageService.handleMessageStatus(
                messageSid, messageStatus, from, to, errorCode, errorMessage);
        return ResponseEntity.ok().build();
    }
}
