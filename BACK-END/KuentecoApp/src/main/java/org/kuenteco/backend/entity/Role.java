package org.kuenteco.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import org.kuenteco.backend.enums.RoleList;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "role")
public class Role {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private RoleList name;
}
