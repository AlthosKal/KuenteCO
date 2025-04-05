package org.kuenteco.backend.entity.slave.extra;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SlaveContentNotification implements Serializable {
    private String title;
    private String body;
    private String date;
}
