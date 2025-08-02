package com.example.back_end.connector.rest.category;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CategoryEnrollmentDTO {
    private String userEmail;
    private String profileEmail;
    private String categoryName;
}
