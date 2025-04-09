package com.gachi_janchi.controller;

import com.gachi_janchi.dto.*;
import com.gachi_janchi.repository.UserRepository;
import com.gachi_janchi.service.FavoriteRestaurantService;
import com.gachi_janchi.service.TokenService;
import com.gachi_janchi.service.UserService;
import com.gachi_janchi.service.VisitedRestaurantService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.util.List;

@RestController
@RequestMapping("/api/user")
public class UserController {

  @Autowired
  private TokenService tokenService;

  @Autowired
  private UserService userService;

  @Autowired
  private FavoriteRestaurantService favoriteRestaurantService;

  @Autowired
  private VisitedRestaurantService visitedRestaurantService;

  @Autowired
  private UserRepository userRepository;
  @GetMapping("/info")
  public ResponseEntity<UserResponse> getUserInfo(@RequestHeader("Authorization") String accessToken) {
    return ResponseEntity.ok(userService.getUserInfo(accessToken));
  }

  // 이름 업데이트 엔드포인트
  @PatchMapping("/name")
  public ResponseEntity<UpdateNameResponse> updateName(
          @RequestHeader("Authorization") String accessToken,
          @RequestBody UpdateNameRequest updateNameRequest) {  // ✅ UpdateNameRequest 사용
    UpdateNameResponse updateNameResponse = userService.updateName(updateNameRequest, accessToken);
    return ResponseEntity.ok(updateNameResponse);
  }

  /* 이메일 업데이트 엔드포인트
  @PatchMapping("/email")
  public ResponseEntity<UpdateEmailResponse> updateEmail(
          @RequestHeader("Authorization") String accessToken,
          @RequestBody UpdateEmailRequest updateEmailRequest) {

    UpdateEmailResponse updateEmailResponse = userService.updateEmail(updateEmailRequest, accessToken);
    return ResponseEntity.ok(updateEmailResponse);
  } */

  // 닉네임 업데이트 엔드포인트
  @RequestMapping(value = "/nick-name", method = RequestMethod.PATCH)
  public ResponseEntity<NickNameAddResponse> updateNickName(@RequestHeader("Authorization") String accessToken, @RequestBody NickNameAddRequest nickNameAddRequest) {
    NickNameAddResponse nickNameAddResponse =  userService.updateNickName(nickNameAddRequest, accessToken);
    return ResponseEntity.ok(nickNameAddResponse);
  }

  @PatchMapping("/password")
  public ResponseEntity<UpdatePasswordResponse> updatePassword(
          @RequestHeader("Authorization") String token,
          @RequestBody UpdatePasswordRequest request) {
    return ResponseEntity.ok(userService.updatePassword(request, token));
  }


  // 닉네임 중복확인 엔드포인트
  @GetMapping("duplication/nick-name")
  public ResponseEntity<CheckNickNameDuplicationResponse> checkNickNameDuplication(@RequestParam("nickName") String nickName) {

    CheckNickNameDuplicationResponse checkNickNameDuplicationResponse = userService.checkNickNameDuplication(nickName);
    return ResponseEntity.ok(checkNickNameDuplicationResponse);
  }

  // ✅ 현재 비밀번호 검증 API
  @PostMapping("/verify-password")
  public ResponseEntity<Boolean> verifyPassword(
          @RequestHeader("Authorization") String token,
          @RequestBody UpdatePasswordRequest request) {

    boolean isValid = userService.verifyPassword(token, request.getPassword());
    return ResponseEntity.ok(isValid);
  }


   //✅ 회원 탈퇴 API (탈퇴 사유 포함)
  @DeleteMapping
  public ResponseEntity<DeleteUserResponse> deleteUser(
          @RequestHeader("Authorization") String token,
          @RequestBody DeleteUserRequest request) {
    DeleteUserResponse response = userService.deleteUser(request, token);
    return ResponseEntity.ok(response);
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

  // 음식점 즐겨찾기 추가 엔드포인트
  @PostMapping("/favorite-restaurant")
  public ResponseEntity<AddFavoriteRestaurantResponse> addFavoriteRestaurant(@RequestHeader("Authorization") String accessToken, @RequestBody AddFavoriteRestaurantRequest addFavoriteRestaurantRequest) {
    System.out.println("favorite-restaurant 엔드포인트");
    AddFavoriteRestaurantResponse addFavoriteRestaurantResponse = favoriteRestaurantService.addFavoriteRestaurant(addFavoriteRestaurantRequest, accessToken);
    return ResponseEntity.ok(addFavoriteRestaurantResponse);
  }

  // 음식점 즐겨찾기 삭제 엔드포인트
  @DeleteMapping("/favorite-restaurant")
  public ResponseEntity<DeleteFavoriteRestaurantResponse> deleteFavoriteRestaurant(@RequestHeader("Authorization") String accessToken, @RequestBody DeleteFavoriteRestaurantRequest deleteFavoriteRestaurantRequest) {
    System.out.println("favorite-restaurant 엔드포인트");
    DeleteFavoriteRestaurantResponse deleteFavoriteRestaurantResponse = favoriteRestaurantService.deleteFavoriteRestaurant(deleteFavoriteRestaurantRequest, accessToken);
    return ResponseEntity.ok(deleteFavoriteRestaurantResponse);
  }

  // 음식점 즐겨찾기 리스트 반환 엔드포인트
  @GetMapping("/favorite-restaurants")
  public ResponseEntity<GetFavoriteRestaurantsResponse> getFavoriteRestaurants(@RequestHeader("Authorization") String accessToken) {
    System.out.println("favorite-restaurants 엔드포인트");
    GetFavoriteRestaurantsResponse getFavoriteRestaurantsResponse = favoriteRestaurantService.getUserFavorites(accessToken);
    return ResponseEntity.ok(getFavoriteRestaurantsResponse);
  }
  // ✅ 프로필 이미지 업로드 API
  @PostMapping("/profile-image")
  public ResponseEntity<String> uploadProfileImage(
          @RequestHeader("Authorization") String accessToken,
          @RequestParam("image") MultipartFile imageFile) {
    String imagePath = userService.saveProfileImage(imageFile, accessToken);
    return ResponseEntity.ok(imagePath);
  }

  @DeleteMapping("/profile-image")
  public ResponseEntity<Void> deleteProfileImage(@RequestHeader("Authorization") String accessToken) {
    System.out.println("🧹 프로필 이미지 삭제 요청 받음");
    userService.deleteProfileImage(accessToken);
    return ResponseEntity.ok().build();
  }

  // UserController.java
  @GetMapping("/ranking")
  public ResponseEntity<List<RankingUserResponse>> getRanking(
          @RequestParam(defaultValue = "0") int page,
          @RequestParam(defaultValue = "10") int size) {
    System.out.println("📥 /api/user/ranking 호출됨 - page: " + page + ", size: " + size);
    Pageable pageable = PageRequest.of(page, size);
    return ResponseEntity.ok(userService.getRanking(pageable));
  }

  // 방문한 음식점 저장 엔드포인트
  @PostMapping("/visited-restaurant")
  public ResponseEntity<AddVisitedRestaurantResponse> addvisitedRestaurant(@RequestHeader("Authorization") String accessToken, @RequestBody AddVisitedRestaurantRequest addVisitedRestaurantRequest) {
    System.out.println("visited-restaurant 엔드포인트");
    AddVisitedRestaurantResponse addVisitedRestaurantResponse = visitedRestaurantService.addVisitedRestaurantResponse(addVisitedRestaurantRequest, accessToken);
    return ResponseEntity.ok(addVisitedRestaurantResponse);
  }
    
  // 방문한 음식점 리스트 반환 엔드포인트
  @GetMapping("/visited-restaurants")
  public ResponseEntity<VisitedRestaurantList> getVisitedRestaurants(@RequestHeader("Authorization") String accessToken, @RequestParam("sortType") String sortType) {
    System.out.println("visited-restaurants 엔드포인트");
    VisitedRestaurantList visitedRestaurantList = visitedRestaurantService.getVisitedRestaurants(accessToken, sortType);
    return ResponseEntity.ok(visitedRestaurantList);
  }
  
}