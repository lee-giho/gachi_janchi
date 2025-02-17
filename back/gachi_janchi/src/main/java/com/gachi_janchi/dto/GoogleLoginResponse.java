package com.gachi_janchi.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class GoogleLoginResponse {
  private String accessToken;
  private String refreshToken;
  private boolean ExistNickName;
}
