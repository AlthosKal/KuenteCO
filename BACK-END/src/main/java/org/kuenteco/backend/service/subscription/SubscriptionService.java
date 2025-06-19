package org.kuenteco.backend.service.subscription;

import org.kuenteco.backend.dto.subscription.AddSubscriptionDTO;
import org.kuenteco.backend.dto.subscription.SubscriptionDetailDTO;
import org.kuenteco.backend.dto.subscription.UpdateSubscriptionDTO;
import org.kuenteco.backend.entity.Subscription;

public interface SubscriptionService {
    SubscriptionDetailDTO getSubscriptions();

    void addSubscription(AddSubscriptionDTO addSubscriptionDTO);

    void updateSubscription(UpdateSubscriptionDTO updateSubscriptionDTO);

    void cancelSubscription(Subscription subscription);
}
