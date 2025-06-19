package org.kuenteco.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import java.sql.Timestamp;
import lombok.*;
import org.kuenteco.backend.entity.extra.Image;

@Entity
@Builder
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "profile")
public class Profile {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "id_user", nullable = false)
    private User user;

    private String username;

    @Column(unique = true)
    private String email;

    @JsonIgnore private String password;

    @Column(name = "start_date")
    private Timestamp startDate;

    @OneToOne(cascade = CascadeType.ALL)
    @JoinColumn(name = "id_image", referencedColumnName = "id")
    private Image image;
}
