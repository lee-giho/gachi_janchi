package com.gachi_janchi.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
public class UserTitleResponse {
    private String userId;
    private Long titleId;             // ✅ 이거 추가
    private String titleName;
    private LocalDateTime acquiredAt;
}
