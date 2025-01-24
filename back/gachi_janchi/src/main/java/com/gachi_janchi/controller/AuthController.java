package com.gachi_janchi.controller;

import com.gachi_janchi.dto.*;
import com.gachi_janchi.service.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

  @Autowired
  private AuthService authService;



  // 회원가입 엔드포인트
  @PostMapping("/register")
  public ResponseEntity<RegisterResponse> register(@RequestBody RegisterRequest registerRequest) {
    RegisterResponse registerResponse = authService.register(registerRequest);
    return ResponseEntity.ok(registerResponse);
  }

  // 로그인 엔드포인트
  @PostMapping("/login")
  public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest loginRequest) {
    LoginResponse loginResponse = authService.login(loginRequest);
    return ResponseEntity.ok(loginResponse);
  }

  // 구글 로그인 엔드포인트
  @PostMapping("/login/google")
  public ResponseEntity<GoogleLoginResponse> googleLogin(@RequestBody GoogleLoginRequest googleLoginRequest) {
    GoogleLoginResponse googleLoginResponse = authService.googleLogin(googleLoginRequest);
    return ResponseEntity.ok(googleLoginResponse);
  }
}
