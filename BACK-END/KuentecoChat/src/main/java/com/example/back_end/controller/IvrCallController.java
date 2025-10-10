package com.example.back_end.controller;

import com.example.back_end.dto.request.InitiateCallDTO;
import com.example.back_end.dto.response.InitiateCallResponseDTO;
import com.example.back_end.exception.ApiResponse;
import com.example.back_end.service.IvrCallService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
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

    @PostMapping("/initiate-call")
    public ResponseEntity<ApiResponse<InitiateCallResponseDTO>> initiateCall(
            @RequestBody InitiateCallDTO dto, HttpServletRequest request) {
        String result = ivrCallService.initiateCall(dto.phoneNumber());
        InitiateCallResponseDTO response =
                InitiateCallResponseDTO.builder()
                        .callSId(result)
                        .message("Llamada iniciada con " + dto.phoneNumber())
                        .build();
        return new ResponseEntity<>(
                ApiResponse.ok("Llamada iniciada correctamente", response, request.getRequestURI()),
                HttpStatus.OK);
    }

    @PostMapping("/process-speech")
    public ResponseEntity<String> processSpeech(
            @RequestParam("SpeechResult") String speechResult,
            @RequestParam("CallSid") String callSid) {
        String result = ivrCallService.processSpeech(speechResult, callSid);
        return ResponseEntity.ok().contentType(MediaType.APPLICATION_XML).body(result);
    }

    @PostMapping("/call-ended")
    public ResponseEntity<Void> handleCallEnded(
            @RequestParam("CallSid") String callSid, @RequestParam("CallStatus") String status) {
        ivrCallService.cleanupCall(callSid);
        return ResponseEntity.ok().build();
    }
}
