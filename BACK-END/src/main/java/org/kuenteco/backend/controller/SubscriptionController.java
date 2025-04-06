package org.kuenteco.backend.controller;

import lombok.AllArgsConstructor;
import org.kuenteco.backend.dto.ApiMessage;
import org.kuenteco.backend.dto.subscription.AddSubscriptionDTO;
import org.kuenteco.backend.dto.subscription.UpdateSubscriptionDTO;
import org.kuenteco.backend.entity.Subscription;
import org.kuenteco.backend.service.subscription.SubscriptionService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@AllArgsConstructor
@RequestMapping("/v1/subcription")
public class SubscriptionController {
    private final SubscriptionService subscriptionService;

    @GetMapping("/{subscriptionId}")
    public Object getAllSubscriptions(@PathVariable Integer subscriptionId) {
        try {
            return new ResponseEntity<>(subscriptionService.getSubscriptions(subscriptionId), HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(new ApiMessage(e.getMessage()), HttpStatus.NO_CONTENT);
        }
    }

    @PostMapping("/add")
    public ResponseEntity<ApiMessage> addSubscription(@RequestBody AddSubscriptionDTO addSubscriptionDTO, Integer accountId) {
        try {
            subscriptionService.addSubscription(addSubscriptionDTO, accountId);
            return ResponseEntity.status(HttpStatus.CREATED).body(new ApiMessage("Subscripción agregada correctamente"));
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(new ApiMessage(e.getMessage()), HttpStatus.BAD_REQUEST);
        } catch (Exception e) {
            return new ResponseEntity<>(new ApiMessage("Se produjo un error" + e.getMessage()), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PutMapping("/{subscriptionId}/update")
    public ResponseEntity<String> updateSubscription(
            @PathVariable Integer subscriptionId,
            @RequestParam Integer masterAccountId,
            @RequestBody UpdateSubscriptionDTO updateSubscriptionDTO) {
        try {
            subscriptionService.updateSubscription(updateSubscriptionDTO, subscriptionId, masterAccountId);
            return ResponseEntity.ok("Subscripción actualizada correctamente");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (IllegalStateException e) {
            return ResponseEntity.status(403).body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("ha ocurrido un error inesperado: " + e.getMessage());
        }
    }

    @DeleteMapping("/{id}/delete")
    public ResponseEntity<ApiMessage> cancelSubscription(Subscription subscription) {
        try {
            subscriptionService.cancelSubscription(subscription);
            return ResponseEntity.status(HttpStatus.OK).body(new ApiMessage("Subscripción cancelada correctamente"));
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(new ApiMessage(e.getMessage()), HttpStatus.BAD_REQUEST);
        } catch (Exception e) {
            return new ResponseEntity<>(new ApiMessage("Se produjo un error"), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    }



