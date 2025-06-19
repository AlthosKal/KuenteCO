package org.kuenteco.backend.dto.auth;

import jakarta.persistence.Version;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.dto.image.ImageDTO;
import org.kuenteco.backend.enums.State;
import org.kuenteco.backend.enums.UserType;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class UserDetailDTO {
    @Version private Integer version;
    private ImageDTO image;
    private String username;
    private String email;
    private UserType type;
    private RoleDetailDTO role;
    private State state;
}
