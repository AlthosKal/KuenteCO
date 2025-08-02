package com.example.back_end.controller.resource;

import com.example.back_end.dto.request.ChatDTO;
import com.example.back_end.dto.request.ChatFilesDTO;
import com.example.back_end.dto.request.ChatMultipartDTO;
import com.example.back_end.dto.request.ErrorDTO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@Tag(name = "Chat", description = "Operations to use AI to process files")
public interface ChatResource {
    @Operation(
            description = "Process the information from different files",
            responses = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Return the output of the process the files",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = String.class))),
                @ApiResponse(
                        responseCode = "400",
                        description = "Something bad happens to process the files",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ErrorDTO.class))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Files or user not exist",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ErrorDTO.class)))
            })
    ResponseEntity<?> askAiWithUrl(
            @RequestBody @Valid ChatFilesDTO dto, HttpServletRequest request);

    @Operation(
            description = "Process the information from one file",
            responses = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Return the output of the process the file",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = String.class))),
                @ApiResponse(
                        responseCode = "400",
                        description = "Something bad happens to process the file",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ErrorDTO.class))),
                @ApiResponse(
                        responseCode = "404",
                        description = "Files or user not exist",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ErrorDTO.class)))
            })
    @PostMapping(value = "/chat-with-file")
    ResponseEntity<?> askAiWithFile(
            @ModelAttribute @Valid ChatMultipartDTO dto, HttpServletRequest request);

    @Operation(
            description = "Process the information from the prompt",
            responses = {
                @ApiResponse(
                        responseCode = "200",
                        description = "Return the output of the process the prompt",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = String.class))),
                @ApiResponse(
                        responseCode = "400",
                        description = "Something bad happens to process the prompt",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ErrorDTO.class))),
                @ApiResponse(
                        responseCode = "404",
                        description = "User not exist",
                        content =
                                @Content(
                                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                                        schema = @Schema(implementation = ErrorDTO.class)))
            })
    ResponseEntity<?> askAi(@RequestBody @Valid ChatDTO dto, HttpServletRequest request);
}
