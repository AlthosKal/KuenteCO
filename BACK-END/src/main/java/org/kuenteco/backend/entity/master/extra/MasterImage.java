package org.kuenteco.backend.entity.master.extra;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@Entity
@Table(name = "image")
public class MasterImage {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @NotBlank
    private String name;

    @NotBlank
    private String imageUrl;

    @NotBlank
    private String id_image;

    public MasterImage(String name, String imageUrl, String id_image) {
        this.name = name;
        this.imageUrl = imageUrl;
        this.id_image = id_image;
    }
}
