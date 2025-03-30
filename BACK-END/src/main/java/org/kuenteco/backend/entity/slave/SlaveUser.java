package org.kuenteco.backend.entity.slave;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.kuenteco.backend.enums.State;

@Data
@Entity
@NoArgsConstructor
@Table(name = "kuentecouser")
public class SlaveUser {
    @Id
    private String id;

    @NotBlank
    @Column(unique = true, nullable = false)
    private String email;

    @NotBlank
    @Column(nullable = false)
    private String password;

    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "id_role", nullable = false)
    private SlaveRole slaveRole;

    @Enumerated(EnumType.STRING)
    @Column(name = "account_state")
    private State accountState;

    @Version
    private Integer version;
    public SlaveUser(String email, String password, SlaveRole slaveRole) {
        this.email = email;
        this.password = password;
        this.slaveRole = slaveRole;
        this.accountState = State.PENDING;
        this.version = 0;
    }

}
