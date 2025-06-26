package org.kuenteco.backend.dto.profile;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.dto.image.ImageDTO;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class UpdateProfileDTO {
    @NotBlank private Integer id;
    @NotBlank private String username;
    @NotBlank private String email;
    @NotBlank private String password;
    private ImageDTO image;
}
