package org.kuenteco.backend.dto.auth;

import jakarta.validation.constraints.Email;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class NewUserDTO {
    @Email
    public String email;
    public String password;
}
