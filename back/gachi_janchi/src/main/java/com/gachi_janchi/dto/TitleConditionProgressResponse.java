package com.gachi_janchi.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import com.fasterxml.jackson.annotation.JsonProperty;

@Data
@AllArgsConstructor
public class TitleConditionProgressResponse {
    private Long titleId;
    private String titleName;
    private String conditionType;
    private String conditionValue;
    private int progress;

    @JsonProperty("achievable")
    private boolean isCompleted;
}

