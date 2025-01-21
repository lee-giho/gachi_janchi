package com.gachi_janchi.controller;

import com.gachi_janchi.dto.NickNameAndPhoneNumberRequest;
import com.gachi_janchi.dto.NickNameAndPhoneNumberResponse;
import com.gachi_janchi.dto.TokenRefreshResponse;
import com.gachi_janchi.dto.TokenValidationResponse;
import com.gachi_janchi.service.TokenService;
import com.gachi_janchi.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/user")
public class UserController {

  @Autowired
  private TokenService tokenService;

  @Autowired
  private UserService userService;

  // 닉네임 및 전화번호 업데이트 엔드포인트
  @PostMapping("/update-info")
  public ResponseEntity<NickNameAndPhoneNumberResponse> updateAdditionalInfo(@RequestBody NickNameAndPhoneNumberRequest nickNameAndPhoneNumberRequest) {
    NickNameAndPhoneNumberResponse nickNameAndPhoneNumberResponse =  userService.updateAdditionalInfo(nickNameAndPhoneNumberRequest);
    return ResponseEntity.ok(nickNameAndPhoneNumberResponse);
  }

  // 로그아웃 엔드포인트
  @DeleteMapping("/logout")
  public ResponseEntity<String> logout(@RequestHeader("Authorization") String refreshToken) {
    try {
      // Bearer 접두사 제거
      if (refreshToken != null ||refreshToken.startsWith("Bearer ")) {
        refreshToken = refreshToken.substring(7 ); // "Bearer " 이후의 토큰만 추출
      }
      // refreshToken 삭제
      boolean isLoggedOut = tokenService.deleteRefreshToken(refreshToken);

      if (isLoggedOut) {
        return ResponseEntity.ok("로그아웃 성공");
      } else {
        return ResponseEntity.status(400).body("로그아웃 실패");
      }
    } catch (Exception e) {
      return ResponseEntity.status(400).body("로그아웃 처리 중 오류 발생");
    }

  }

  // accessToken 검증 엔드포인트
  @GetMapping("/token-validation")
  public ResponseEntity<TokenValidationResponse> validateAccessToken(@RequestHeader("Authorization") String accessToken) {
    TokenValidationResponse tokenValidationResponse = tokenService.validateAccessToken(accessToken);
    return ResponseEntity.ok(tokenValidationResponse);
  }

  // refreshToken을 사용하여 새로운 accessToken 발급 엔드포인트
  @PostMapping("/token-refresh")
  public ResponseEntity<TokenRefreshResponse> refreshAccessToken(@RequestHeader("Authorization") String refreshToken) {
    TokenRefreshResponse tokenRefreshResponse = tokenService.refreshAccessToken(refreshToken);
    return ResponseEntity.ok(tokenRefreshResponse);
  }
}
