package com.gachi_janchi.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor  // 모든 필드를 포함하는 생성자 자동 생성
@NoArgsConstructor   // 기본 생성자 자동 생성
public class UpdatePasswordResponse {
    private boolean success;  // 성공 여부
    private String message;   // 응답 메시지
}
