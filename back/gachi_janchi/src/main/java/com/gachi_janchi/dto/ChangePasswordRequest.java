package com.gachi_janchi.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ChangePasswordRequest {
  private String id;
  private String password;
}
