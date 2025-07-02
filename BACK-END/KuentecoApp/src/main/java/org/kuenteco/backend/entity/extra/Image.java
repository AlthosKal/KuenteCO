package org.kuenteco.backend.entity.extra;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Builder
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Table(
        name = "image",
        indexes = {
            @Index(name = "idx_image_image_id", columnList = "id_image"), // Cloudinary ID
            @Index(name = "idx_image_url", columnList = "url_image") // Búsquedas por URL
        })
public class Image {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private String name;

    @Column(name = "url_image")
    private String imageUrl;

    @Column(name = "id_image")
    private String imageId;
}
