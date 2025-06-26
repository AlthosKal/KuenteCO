package org.kuenteco.backend.dto.logic.transaction;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserProfilesWithTransactionsDTO {
    private String username;
    private String email;
    private List<ProfileWithTransactionsDTO> profiles;
    private Integer totalProfiles;
    private Integer totalTransactions;
}
