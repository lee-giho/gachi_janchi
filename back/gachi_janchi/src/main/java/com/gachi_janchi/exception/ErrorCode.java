package com.gachi_janchi.exception;

import org.springframework.http.HttpStatus;

import lombok.AllArgsConstructor;
import lombok.Getter;

// 각종 에러 상황에 대한 코드와 메시지를 정의하는 열거형

@AllArgsConstructor
@Getter
public enum ErrorCode {

  // 인증/인가 관련
  INVALID_ACCESS_TOKEN(HttpStatus.UNAUTHORIZED, "유효하지 않은 Access Token입니다."),
  INVALID_REFRESH_TOKEN(HttpStatus.UNAUTHORIZED, "유효하지 않은 Refresh Token입니다."),
  TOKEN_EXPIRED(HttpStatus.UNAUTHORIZED, "토큰이 만료되었습니다."),
  INVALID_TOKEN_SIGNATURE(HttpStatus.UNAUTHORIZED, "잘못된 비밀키입니다."),
  UNSUPPORTED_JWT(HttpStatus.BAD_REQUEST, "지원되지 않는 JWT 형식입니다."),
  MALFORMED_JWT(HttpStatus.BAD_REQUEST, "유효하지 않은 JWT입니다."),

  // 사용자
  USER_NOT_FOUND(HttpStatus.NOT_FOUND, "해당 사용자를 찾을 수 없습니다."),
  LOCAL_ACCOUNT_NOT_FOUND(HttpStatus.NOT_FOUND, "로컬 계정을 찾을 수 없습니다."),
  SOCIAL_ACCOUNT_NOT_FOUND(HttpStatus.NOT_FOUND, "소셜 계정을 찾을 수 없습니다."),
  ROLE_NOT_FOUND(HttpStatus.NOT_FOUND, "ROLE_USER로 설정되어 있지 않습니다."),
  DUPLICATE_USER_ID(HttpStatus.CONFLICT, "이미 사용 중인 아이디입니다."),
  DUPLICATE_NICKNAME(HttpStatus.CONFLICT, "이미 사용 중인 닉네임입니다."),
  INVALID_PASSWORD(HttpStatus.UNAUTHORIZED, "비밀번호가 일치하지 않습니다."),

  // 음식점 / 재료
  RESTAURANT_NOT_FOUND(HttpStatus.NOT_FOUND, "음식점을 찾을 수 없습니다."),
  INGREDIENT_NOT_FOUND(HttpStatus.NOT_FOUND, "재료를 찾을 수 없습니다."),

  // 방문기록
  VISITED_RESTAURANT_NOT_FOUND(HttpStatus.NOT_FOUND, "방문한 음식점을 찾을 수 없습니다."),

  // 리뷰
  REVIEW_NOT_FOUND(HttpStatus.NOT_FOUND, "리뷰를 찾을 수 없습니다."),
  REVIEW_STORAGE_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "리뷰 저장 중 오류가 발생했습니다."),
  REVIEW_DELETE_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "리뷰 삭제 중 오류가 발생했습니다."),
  REVIEW_UPDATE_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "리뷰 수정 중 오류가 발생했습니다."),
  INVALID_SORT_TYPE(HttpStatus.BAD_REQUEST, "유효하지 않은 정렬 방식입니다."),

  // 즐겨찾기
  FAVORITE_RESTAURANT_NOT_FOUND(HttpStatus.NOT_FOUND, "즐겨찾기한 음식점을 찾을 수 없습니다."),
  FAVORITE_RESTAURANT_ALREADY_EXIST(HttpStatus.CONFLICT, "이미 즐겨찾기한 음식점입니다."),

  // 컬렉션
  COLLECTION_NOT_FOUND(HttpStatus.NOT_FOUND, "존재하지 않는 컬렉션입니다."),
  COLLECTION_ALREADY_COMPLETED(HttpStatus.CONFLICT, "이미 완성한 컬렉션입니다."),
  INSUFFICIENT_INGREDIENTS(HttpStatus.BAD_REQUEST, "재료가 부족합니다."),

  // 칭호
  TITLE_NOT_FOUND(HttpStatus.NOT_FOUND, "칭호가 존재하지 않습니다."),
  USER_DOES_NOT_OWN_TITLE(HttpStatus.FORBIDDEN, "해당 칭호를 보유하고 있지 않습니다."),
  TITLE_ALREADY_CLAIMED(HttpStatus.CONFLICT, "이미 획득한 칭호입니다."),

  // 인증번호 / 이메일
  VERIFICATION_CODE_MISMATCH(HttpStatus.BAD_REQUEST, "인증번호가 일치하지 않습니다."),
  INVALID_SESSION(HttpStatus.BAD_REQUEST, "세션이 유효하지 않습니다."),
  EMAIL_SEND_FAILED(HttpStatus.INTERNAL_SERVER_ERROR, "인증번호 전송 중 오류가 발생했습니다."),

  // 소셜 로그인
  INVALID_SOCIAL_TOKEN(HttpStatus.BAD_REQUEST, "잘못된 소셜 로그인 정보입니다."),
  INVALID_GOOGLE_CLIENT_ID(HttpStatus.BAD_REQUEST, "클라이언트 ID가 일치하지 않습니다."),
  INVALID_NAVER_ACCESS_TOKEN(HttpStatus.BAD_REQUEST, "유효하지 않은 Naver AccessToken입니다."),

  // 파일 처리
  FILE_STORAGE_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "파일 저장 중 오류가 발생했습니다."),
  FILE_DELETE_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "파일 삭제 중 오류가 발생했습니다."),

  // 일반
  BAD_REQUEST(HttpStatus.BAD_REQUEST, "잘못된 요청입니다."),
  INTERNAL_SERVER_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "서버 내부 오류가 발생했습니다.");

  private final HttpStatus status;
  private final String message;
  
}
