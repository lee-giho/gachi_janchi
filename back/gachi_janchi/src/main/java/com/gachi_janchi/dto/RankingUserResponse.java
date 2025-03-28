package com.gachi_janchi.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class RankingUserResponse {
    private String nickname;
    private String profileImagePath;
    private String title; // 추가 필요!
    private int exp;

}
