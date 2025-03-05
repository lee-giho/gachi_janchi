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
}
