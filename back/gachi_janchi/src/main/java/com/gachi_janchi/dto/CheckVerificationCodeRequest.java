package com.gachi_janchi.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CheckVerificationCodeRequest {
  private String verificationCode;
}
