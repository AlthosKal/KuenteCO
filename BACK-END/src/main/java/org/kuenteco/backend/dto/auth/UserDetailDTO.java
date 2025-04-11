package org.kuenteco.backend.dto.auth;

import jakarta.persistence.Version;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.extra.Image;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class UserDetailDTO {
    private String name;
    private String email;
    private RoleDetailDTO role;
    @Version
    private Integer version;
    private Image masterImage;
}
