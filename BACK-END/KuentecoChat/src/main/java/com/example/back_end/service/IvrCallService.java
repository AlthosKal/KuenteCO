package com.example.back_end.service;

public interface IvrCallService {
    String handleIncomingCall(String callSid, String from);

    String processSpeech(String speechResult, String callSid);
}
