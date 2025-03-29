package org.kuenteco.backend.entity.slave;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.RoleList;

@Data
@Entity
@NoArgsConstructor
@Table(name = "role")
public class SlaveRole {
    @Id
    private Integer id;

    @Column(nullable = false)
    private RoleList name;
}
