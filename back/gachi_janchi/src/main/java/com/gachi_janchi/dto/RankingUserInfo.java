package com.gachi_janchi.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class RankingUserInfo {
    private String nickname;
    private String profileImage;
    private String title;
    private int exp;

}
