package com.gachi_janchi.dto;


import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class RegisterRequest {
  private String name;
  private String email;
  private String password;
}
