package org.kuenteco.backend.dto.auth;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.RoleList;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class RoleDetailDTO {
    private RoleList name;
}
