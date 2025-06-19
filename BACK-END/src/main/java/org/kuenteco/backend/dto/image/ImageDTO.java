package org.kuenteco.backend.dto.image;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ImageDTO {
    @NotBlank private String name;
    @NotBlank private String imageUrl;
    private String imageId;
}
