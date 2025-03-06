package com.gachi_janchi.dto;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class UserResponse {
    private String nickname;
    //private String title;
    private String name;
    private String email;
    private String type; // ✅ 로그인 유형 (local 또는 social)

}
