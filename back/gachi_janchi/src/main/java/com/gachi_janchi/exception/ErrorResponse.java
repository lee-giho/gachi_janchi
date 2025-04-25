package com.gachi_janchi.exception;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Getter;

// API 예외 응답을 위한 DTO

@AllArgsConstructor
@Getter
public class ErrorResponse {

  private final String code;
  private final String message;
  private final LocalDateTime timestamp;
  private final String path;

}
