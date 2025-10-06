package com.example.back_end.service;

import com.twilio.rest.api.v2010.account.Call;
import com.twilio.type.PhoneNumber;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import com.example.back_end.configuration.twilio.TwilioConfigProperties;

@Service
@RequiredArgsConstructor
@Slf4j
public class OutboundCallService {

    private final TwilioConfigProperties twilioConfig;

    public String makeCall(String toPhoneNumber, String webhookUrl) {
        try {
            Call call = Call.creator(
                            new PhoneNumber(toPhoneNumber),
                            new PhoneNumber(twilioConfig.getPhoneNumber()),
                            webhookUrl
                    )
                    .setMachineDetection("DetectMessageEnd")  // Detecta si es contestadora
                    .setMachineDetectionTimeout(30)           // Espera 30 segundos
                    .setMachineDetectionSpeechThreshold(2400) // Umbral de detección
                    .setMachineDetectionSpeechEndThreshold(1200)
                    .setMachineDetectionSilenceTimeout(5000)
                    .create();

            log.info("Call initiated: {}", call.getSid());
            return call.getSid();

        } catch (Exception e) {
            log.error("Error making call", e);
            throw new RuntimeException("Failed to initiate call", e);
        }
    }
}