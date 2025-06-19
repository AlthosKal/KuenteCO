package org.kuenteco.backend.controller;

import jakarta.servlet.http.HttpServletRequest;
import lombok.AllArgsConstructor;
import org.kuenteco.backend.dto.subscription.AddSubscriptionDTO;
import org.kuenteco.backend.dto.subscription.SubscriptionDetailDTO;
import org.kuenteco.backend.dto.subscription.UpdateSubscriptionDTO;
import org.kuenteco.backend.entity.Subscription;
import org.kuenteco.backend.exception.ApiResponse;
import org.kuenteco.backend.service.subscription.SubscriptionService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@AllArgsConstructor
@RequestMapping("/v1/subscription")
public class SubscriptionController {
    private final SubscriptionService subscriptionService;

    @GetMapping("/{subscriptionId}")
    public ResponseEntity<?> getAllSubscriptions(HttpServletRequest request) {
        SubscriptionDetailDTO dto = subscriptionService.getSubscriptions();
        return ResponseEntity.ok(
                ApiResponse.ok(
                        "Subscripciones obtenidas correctamente", dto, request.getRequestURI()));
    }

    @PostMapping("/add")
    public ResponseEntity<?> addSubscription(
            @RequestBody AddSubscriptionDTO addSubscriptionDTO, HttpServletRequest request) {
        subscriptionService.addSubscription(addSubscriptionDTO);
        return ResponseEntity.ok(
                ApiResponse.ok(
                        "Subscripción agregada correctamente", null, request.getRequestURI()));
    }

    @PutMapping("/{subscriptionId}/update")
    public ResponseEntity<?> updateSubscription(
            @PathVariable Integer subscriptionId,
            HttpServletRequest request,
            @RequestBody UpdateSubscriptionDTO updateSubscriptionDTO) {
        subscriptionService.updateSubscription(updateSubscriptionDTO);
        return ResponseEntity.ok(
                ApiResponse.ok(
                        "Subscripción actualizada correctamente", null, request.getRequestURI()));
    }

    @DeleteMapping("/{id}/delete")
    public ResponseEntity<?> cancelSubscription(
            Subscription subscription, HttpServletRequest request) {
        subscriptionService.cancelSubscription(subscription);
        return ResponseEntity.ok(
                ApiResponse.ok(
                        "Subscripción cancelada correctamente", null, request.getRequestURI()));
    }
}
