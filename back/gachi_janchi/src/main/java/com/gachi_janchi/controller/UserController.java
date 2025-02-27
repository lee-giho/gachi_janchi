package com.gachi_janchi.controller;

import com.gachi_janchi.dto.*;
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
  @RequestMapping(value = "/nick-name", method = RequestMethod.PATCH)
  public ResponseEntity<NickNameAddResponse> updateNickName(@RequestHeader("Authorization") String accessToken, @RequestBody NickNameAddRequest nickNameAddRequest) {
    NickNameAddResponse nickNameAddResponse =  userService.updateNickName(nickNameAddRequest, accessToken);
    return ResponseEntity.ok(nickNameAddResponse);
  }

  // 닉네임 중복확인 엔드포인트
  @GetMapping("duplication/nick-name")
  public ResponseEntity<CheckNickNameDuplicationResponse> checkNickNameDuplication(@RequestParam("nickName") String nickName) {
    CheckNickNameDuplicationResponse checkNickNameDuplicationResponse = userService.checkNickNameDuplication(nickName);
    return ResponseEntity.ok(checkNickNameDuplicationResponse);
  }

  // 로그아웃 엔드포인트
//  @DeleteMapping("/logout")
//  public ResponseEntity<String> logout(@RequestHeader("Authorization") String refreshToken) {
//    boolean isLoggedOut = userService.logout(refreshToken);
//    if (isLoggedOut) {
//      return ResponseEntity.ok("로그아웃 성공");
//    } else {
//      return ResponseEntity.status(400).body("로그아웃 실패");
//    }
//  }
  @PutMapping("/update-nickname")
  public UpdateNickNameResponse updateNickName(
          @RequestHeader("Authorization") String token,
          @RequestBody UpdateNickNameRequest request) {
    return userService.updateNickName(request, token);
  }

  // 이름 변경 엔드포인트
  @PutMapping("/update-name")
  public UpdateNameResponse updateName(
          @RequestHeader("Authorization") String token,
          @RequestBody UpdateNameRequest request) {
    return userService.updateName(request, token);
  }

  // 이메일 변경 엔드포인트 (선택사항)
  @PutMapping("/update-email")
  public UpdateEmailResponse updateEmail(
          @RequestHeader("Authorization") String token,
          @RequestBody UpdateEmailRequest request) {
    return userService.updateEmail(request, token);
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
