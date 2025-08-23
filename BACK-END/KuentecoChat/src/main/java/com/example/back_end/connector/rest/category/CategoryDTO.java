package com.example.back_end.connector.rest.category;

import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CategoryDTO {
    private Integer id;
    private Integer budgetId;
    private String name;
    private DescriptionCategory description;
    private LocalDateTime registerDate;
}
