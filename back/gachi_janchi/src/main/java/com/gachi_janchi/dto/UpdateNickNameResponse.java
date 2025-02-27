package com.gachi_janchi.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class UpdateNickNameResponse {
    private boolean success;
    private String message;
}
