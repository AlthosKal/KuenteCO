package org.kuenteco.backend.entity.master.extra;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ContentNotification implements Serializable {
    private String title;
    private String body;
    private String date;
}
