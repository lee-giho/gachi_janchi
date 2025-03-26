package com.gachi_janchi.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class TitleConditionResponse {
    private Long titleId;
    private String titleName;
    private String conditionType;
    private String conditionValue;
}
