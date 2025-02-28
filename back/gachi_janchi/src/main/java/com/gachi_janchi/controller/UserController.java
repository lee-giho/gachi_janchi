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
  // 닉네임 업데이트 엔드포인트
  @PatchMapping("/update-nickname")
  public ResponseEntity<UpdateNickNameResponse> updateNickName(
          @RequestHeader("Authorization") String accessToken,
          @RequestBody UpdateNickNameRequest updateNickNameRequest) {
    System.out.print("안녕하세요.");
    UpdateNickNameResponse updateNickNameResponse = userService.updateNickName(updateNickNameRequest, accessToken);
    return ResponseEntity.ok(updateNickNameResponse);
  }

  // 이름 업데이트 엔드포인트
  @PatchMapping("/update-name")
  public ResponseEntity<UpdateNameResponse> updateName(
          @RequestHeader("Authorization") String accessToken,
          @RequestBody UpdateNameRequest updateNameRequest) {


    UpdateNameResponse updateNameResponse = userService.updateName(updateNameRequest, accessToken);
    return ResponseEntity.ok(updateNameResponse);
  }

  // 이메일 업데이트 엔드포인트
  @PatchMapping("/update-email")
  public ResponseEntity<UpdateEmailResponse> updateEmail(
          @RequestHeader("Authorization") String accessToken,
          @RequestBody UpdateEmailRequest updateEmailRequest) {

    UpdateEmailResponse updateEmailResponse = userService.updateEmail(updateEmailRequest, accessToken);
    return ResponseEntity.ok(updateEmailResponse);
  }

  // 닉네임 업데이트 엔드포인트
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