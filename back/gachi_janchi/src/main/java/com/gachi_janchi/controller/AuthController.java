package com.gachi_janchi.controller;

import com.gachi_janchi.dto.*;
import com.gachi_janchi.service.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

  @Autowired
  private AuthService authService;

  // 아이디 중복확인 엔드포인트
  @GetMapping("duplication/id")
  public ResponseEntity<CheckIdDuplicationResponse> checkIdDuplication(@RequestParam("id") String id) {
    System.out.print("아이디 중복 확인");
    CheckIdDuplicationResponse checkIdDuplicationResponse = authService.checkIdDuplication(id);
    return ResponseEntity.ok(checkIdDuplicationResponse);
  }

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

  // 아이디 찾기 엔드포인트
  @GetMapping("/id")
  public ResponseEntity<FindIdResponse> findId(@RequestParam("name") String name, @RequestParam("email") String email) {
    FindIdResponse findIdResponse = authService.findId(name, email);
    return ResponseEntity.ok(findIdResponse);
  }

  // 비밀번호 찾기 엔드포인트
  @GetMapping("/password")
  public ResponseEntity<FindPasswordResponse> findPassword(@RequestParam("name") String name, @RequestParam("id") String id, @RequestParam("email") String email ) {
    FindPasswordResponse findPasswordResponse = authService.findUserForFindPassword(name, id, email);
    return ResponseEntity.ok(findPasswordResponse);
  }

  // 비밀번호 변경 엔드포인트
  @PatchMapping("/password")
  public ResponseEntity<ChangePasswordResponse> changePassword(@RequestBody ChangePasswordRequest changePasswordRequest) {
    ChangePasswordResponse changePasswordResponse = authService.changePassword(changePasswordRequest);
    return switch (changePasswordResponse.getResponseMsg()) {
      case "Success" -> ResponseEntity.ok(changePasswordResponse);
      case "User not found" -> ResponseEntity.status(HttpStatus.NOT_FOUND).body(changePasswordResponse);
      case "Invalid data" -> ResponseEntity.status(HttpStatus.BAD_REQUEST).body(changePasswordResponse);
      default -> ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(changePasswordResponse);
    };
  }

  // 구글 로그인 엔드포인트
  @PostMapping("/login/google")
  public ResponseEntity<GoogleLoginResponse> googleLogin(@RequestBody GoogleLoginRequest googleLoginRequest) {
    GoogleLoginResponse googleLoginResponse = authService.googleLogin(googleLoginRequest);
    return ResponseEntity.ok(googleLoginResponse);
  }

  // 네이버 로그인 엔드포인트
  @PostMapping("/login/naver")
  public ResponseEntity<NaverLoginResponse> naverLogin(@RequestBody NaverLoginRequest naverLoginRequest) {
    NaverLoginResponse naverLoginResponse = authService.naverLogin(naverLoginRequest);
    return ResponseEntity.ok(naverLoginResponse);
  }
}
