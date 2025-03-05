package com.gachi_janchi.dto;

import lombok.Data;

@Data
public class DeleteUserRequest {
    private String reason;  // 탈퇴 사유 (선택적)
}
