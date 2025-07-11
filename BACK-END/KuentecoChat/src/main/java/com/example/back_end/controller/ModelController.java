package com.example.back_end.controller;

import com.example.back_end.controller.resource.ModelResource;
import com.example.back_end.enums.Model;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("v1/model")
public class ModelController implements ModelResource {

    private static final Logger LOGGER = LoggerFactory.getLogger(ModelController.class);

    @GetMapping
    public ResponseEntity<List<String>> getAllModels() {
        LOGGER.info("Get available models");

        List<String> models =
                Arrays.stream(Model.values())
                        .map(Enum::name) // o model -> model.toString()
                        .collect(Collectors.toList());

        return ResponseEntity.ok(models);
    }
}
