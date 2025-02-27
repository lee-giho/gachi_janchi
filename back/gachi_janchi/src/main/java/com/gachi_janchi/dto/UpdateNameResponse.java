package com.gachi_janchi.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class UpdateNameResponse {
    private boolean success;
    private String message;
}
