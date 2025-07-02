package org.kuenteco.backend.dto.profile;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.dto.image.ImageDTO;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ProfileDetailDTO {
    private Integer id;
    private String username;
    private String email;
    private ImageDTO image;
}
