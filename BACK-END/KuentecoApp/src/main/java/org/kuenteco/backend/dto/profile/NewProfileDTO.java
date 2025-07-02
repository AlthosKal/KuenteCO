package org.kuenteco.backend.dto.profile;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class NewProfileDTO {
    @NotBlank private String username;
    @Email @NotBlank private String email;
    @NotBlank private String password;
}
