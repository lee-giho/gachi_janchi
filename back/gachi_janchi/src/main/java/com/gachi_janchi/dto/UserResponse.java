package com.gachi_janchi.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@AllArgsConstructor
@Data
public class UserResponse {
    private String nickname;
    private String title;
    private String name;
    private String email;
    private String type; // local 또는 social
    private String profileImagePath;
    private int exp;
}
