package com.gachi_janchi.exception;

// Service에서 발생하는 예외를 처리하기 위한 커스텀 런타임 예외 클래스

public class CustomException extends RuntimeException{

  private final ErrorCode errorCode;

  public CustomException(ErrorCode errorCode) {
    super(errorCode.getMessage());
    this.errorCode = errorCode;
  }

  public CustomException(ErrorCode errorCode, String message) {
    super(message);
    this.errorCode = errorCode;
  }

  public ErrorCode getErrorCode() {
    return errorCode;
  }
}
