package org.kuenteco.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import org.kuenteco.backend.entity.extra.Image;
import org.kuenteco.backend.enums.State;
import org.kuenteco.backend.enums.UserType;

@Entity
@Builder
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Table(
        name = "kuentecouser",
        indexes = {
            @Index(name = "idx_user_username", columnList = "username"), // Ya implícito
            // por
            // unique=true
            @Index(name = "idx_user_email", columnList = "email"), // Ya implícito por unique=true
            @Index(
                    name = "idx_user_name_email",
                    columnList = "username,email"), // Búsquedas combinadas
            @Index(name = "idx_user_password", columnList = "password") // Para autenticación
        })
public class User {

    @Id
    @JsonIgnore
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Version private Integer version;

    @OneToOne(cascade = CascadeType.ALL)
    @JoinColumn(name = "id_image", referencedColumnName = "id")
    private Image image;

    @Column(unique = true)
    private String username;

    @Column(unique = true)
    private String email;

    @JsonIgnore private String password;

    @Enumerated(EnumType.STRING)
    private UserType type;

    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "id_role", nullable = false)
    private Role role;

    @Enumerated(EnumType.STRING)
    @Column(name = "account_state")
    private State state;
}
