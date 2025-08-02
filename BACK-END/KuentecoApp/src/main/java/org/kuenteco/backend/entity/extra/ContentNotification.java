package org.kuenteco.backend.entity.extra;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ContentNotification {
    private String title;
    private String body;
    private String date;
}
