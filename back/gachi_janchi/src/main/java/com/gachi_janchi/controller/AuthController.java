package com.gachi_janchi.controller;

import com.gachi_janchi.dto.*;
import com.gachi_janchi.service.AuthService;
import com.gachi_janchi.service.TokenService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

  @Autowired
  private AuthService authService;

  @Autowired
  private TokenService tokenService;


  // 회원가입 엔드포인트
  @PostMapping("/register")
  public ResponseEntity<RegisterResponse> register(@RequestBody RegisterRequest registerRequest) {
    RegisterResponse registerResponse = authService.register(registerRequest);
    return ResponseEntity.ok(registerResponse);
  }

  // 닉네임 및 전화번호 업데이트 엔드포인트
  @PostMapping("/update-info")
  public ResponseEntity<NickNameAndPhoneNumberResponse> updateAdditionalInfo(@RequestBody NickNameAndPhoneNumberRequest nickNameAndPhoneNumberRequest) {
    NickNameAndPhoneNumberResponse nickNameAndPhoneNumberResponse =  authService.updateAdditionalInfo(nickNameAndPhoneNumberRequest);
    return ResponseEntity.ok(nickNameAndPhoneNumberResponse);
  }

  // 로그인 엔드포인트
  @PostMapping("/login")
  public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest loginRequest) {
    LoginResponse loginResponse = authService.login(loginRequest);
    return ResponseEntity.ok(loginResponse);
  }

  // accessToken 검증 엔드포인트
  @GetMapping("/token-validation")
  public ResponseEntity<TokenValidationResponse> validateAccessToken(@RequestHeader("Authorization") String accessToken) {
    TokenValidationResponse tokenValidationResponse = tokenService.validateAccessToken(accessToken);
    return ResponseEntity.ok(tokenValidationResponse);
  }

  // refreshToken을 사용하여 새로운 accessToken 발급
  @PostMapping("/token-refresh")
  public ResponseEntity<TokenRefreshResponse> refreshAccessToken(@RequestHeader("Authorization") String refreshToken) {
    TokenRefreshResponse tokenRefreshResponse = tokenService.refreshAccessToken(refreshToken);
    return ResponseEntity.ok(tokenRefreshResponse);
  }
}
