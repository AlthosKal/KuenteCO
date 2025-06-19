package org.kuenteco.backend.dto.profile;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class NewProfileDTO {
    private String username;
    private String email;
    private String password;
}
