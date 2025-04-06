package org.kuenteco.backend.dto.auth;

import jakarta.validation.constraints.Email;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.dto.image.ImageDTO;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class NewUserDTO {
    private String name;
    @Email
    public String email;
    public String password;
}
