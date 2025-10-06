package com.example.back_end.service;

public interface IvrCallService {
    String handleIncomingCall(String callSid, String from);

    String initiateCall(String toPhoneNumber);

    String processSpeech(String speechResult, String callSid);

    void cleanupCall(String callSid);
}
