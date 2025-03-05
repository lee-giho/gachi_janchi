package com.gachi_janchi.dto;
import lombok.Data;

@Data
public class UpdatePasswordResponse {
    private boolean success;  // 성공 여부
    private String message;   // 응답 메시지
}
