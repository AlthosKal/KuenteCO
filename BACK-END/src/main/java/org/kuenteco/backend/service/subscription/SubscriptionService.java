package org.kuenteco.backend.service.subscription;

import org.kuenteco.backend.dto.subscription.AddSubscriptionDTO;
import org.kuenteco.backend.dto.subscription.SubscriptionDetailDTO;
import org.kuenteco.backend.dto.subscription.UpdateSubscriptionDTO;
import org.kuenteco.backend.entity.master.MasterSubscription;

import java.io.IOException;

public interface SubscriptionService {
    SubscriptionDetailDTO getSubscriptions(Integer subscriptionId);

    void addSubscription(AddSubscriptionDTO addSubscriptionDTO, Integer accountId) throws IOException;

    void updateSubscription(UpdateSubscriptionDTO updateSubscriptionDTO, Integer subscriptionId, Integer accountId) throws IOException;

    void cancelSubscription(MasterSubscription subscription) throws IOException;

}
