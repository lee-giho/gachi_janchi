package com.gachi_janchi.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class UserInfoWithProfileImageAndTitle {
  private String id;
  private String nickName;
  private String title;
  private String profileImage;
}
