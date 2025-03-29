package org.kuenteco.backend.entity.master;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.State;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "kuentecouser")
public class MasterUser {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Version
    private Long version;

    @NotBlank
    @Column(unique = true, nullable = false)
    private String email;

    @NotBlank
    @Column(nullable = false)
    private String password;

    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "id_role", nullable = false)
    private MasterRole role;

    @Enumerated(EnumType.STRING)
    @Column(name = "account_state")
    private State accountState;

    public MasterUser(String email, String password, MasterRole role) {
        this.email = email;
        this.password = password;
        this.role = role;
        this.accountState = State.PENDING;
        this.version = 0L;
    }
}
