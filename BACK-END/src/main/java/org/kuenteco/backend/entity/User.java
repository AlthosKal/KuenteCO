package org.kuenteco.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.entity.extra.Image;
import org.kuenteco.backend.enums.State;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "kuentecouser")
public class User {

    @Id
    @JsonIgnore
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @NotBlank
    @Column(unique = true, nullable = false)
    private String name;

    @NotBlank
    @Column(unique = true, nullable = false)
    private String email;

    @NotBlank
    @JsonIgnore
    @Column(nullable = false)
    private String password;

    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "id_role", nullable = false)
    private Role role;

    @Enumerated(EnumType.STRING)
    @Column(name = "account_state")
    private State accountState;

    @Version
    private Integer version;

    @OneToOne(cascade = CascadeType.ALL)
    @JoinColumn(name = "id_image", referencedColumnName = "id")
    private Image masterImage;

    public User(String name , String email, String password, Role role) {
        this.name = name;
        this.email = email;
        this.password = password;
        this.role = role;
        this.accountState = State.PENDING;
        this.version = 0;
    }
}
