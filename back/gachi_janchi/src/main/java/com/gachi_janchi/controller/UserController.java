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
    boolean isLoggedOut = userService.logout(refreshToken);
    if (isLoggedOut) {
      return ResponseEntity.ok("로그아웃 성공");
    } else {
      return ResponseEntity.status(400).body("로그아웃 실패");
    }
  }

  // accessToken 검증 엔드포인트
  @GetMapping("/token-validation")
  public ResponseEntity<TokenValidationResponse> validateAccessToken(@RequestHeader("Authorization") String accessToken) {
    System.out.println("token-validation 엔드포인트");
    TokenValidationResponse tokenValidationResponse = tokenService.validateAccessToken(accessToken);
    return ResponseEntity.ok(tokenValidationResponse);
  }

  // refreshToken을 사용하여 새로운 accessToken 발급 엔드포인트
  @PostMapping("/token-refresh")
  public ResponseEntity<TokenRefreshResponse> refreshAccessToken(@RequestHeader("Authorization") String refreshToken) {
    System.out.println("token-refresh 엔드포인트");
    TokenRefreshResponse tokenRefreshResponse = tokenService.refreshAccessToken(refreshToken);
    return ResponseEntity.ok(tokenRefreshResponse);
  }
}
