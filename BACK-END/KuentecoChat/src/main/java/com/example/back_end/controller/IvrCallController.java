package com.example.back_end.controller;

import com.example.back_end.service.IvrCallService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/voice")
@RequiredArgsConstructor
@CrossOrigin
public class IvrCallController {
    private final IvrCallService ivrCallService;

    @PostMapping("/incoming")
    public ResponseEntity<String> handleIncomingCall(
            @RequestParam("CallSid") String callSid, @RequestParam("From") String from) {
        String result = ivrCallService.handleIncomingCall(callSid, from);
        return ResponseEntity.ok().contentType(MediaType.APPLICATION_XML).body(result);
    }

    @PostMapping("/process-speech")
    public ResponseEntity<String> processSpeech(
            @RequestParam("SpeechResult") String speechResult,
            @RequestParam("CallSid") String callSid) {
        String result = ivrCallService.processSpeech(speechResult, callSid);
        return ResponseEntity.ok().contentType(MediaType.APPLICATION_XML).body(result);
    }
}
