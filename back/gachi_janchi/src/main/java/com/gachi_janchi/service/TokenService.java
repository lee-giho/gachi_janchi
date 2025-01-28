package com.gachi_janchi.service;

import com.gachi_janchi.dto.TokenRefreshResponse;
import com.gachi_janchi.dto.TokenValidationResponse;
import com.gachi_janchi.entity.RefreshToken;
import com.gachi_janchi.entity.User;
import com.gachi_janchi.repository.RefreshTokenRepository;
import com.gachi_janchi.repository.UserRepository;
import com.gachi_janchi.util.JwtProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class TokenService {

  @Autowired
  private JwtProvider jwtProvider;

  @Autowired
  private RefreshTokenRepository refreshTokenRepository;

  @Autowired
  private UserRepository userRepository;

  @Value("${REFRESH_TOKEN_EXP}")
  private long refreshTokenExp;

  // accessToken 유효성 검사
  public TokenValidationResponse validateAccessToken(String token) {
    String accessToken = jwtProvider.getTokenWithoutBearer(token);
    System.out.println("validateAccessToken: " + accessToken);
    return new TokenValidationResponse(jwtProvider.validateToken(accessToken));
  }

  // refreshToken으로 새로운 accessToken 발급
  public TokenRefreshResponse refreshAccessToken(String token) {
    String refreshToken = jwtProvider.getTokenWithoutBearer(token);
    System.out.println("refreshAccessToken: " + refreshToken);
    if (!jwtProvider.validateToken(refreshToken)) {
      throw new IllegalArgumentException("Invalid refresh token");
    }

    // refreshToken이 유효한 경우, 새로운 accessToken을 발급
    String email = jwtProvider.getUserEmail(refreshToken);
    User user = userRepository.findByEmail(email).orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다. - " + email));
    return new TokenRefreshResponse(jwtProvider.generateAccessToken(user));
  }

  // 로그인 시 refreshToken 저장
//  public void saveRefreshToken(String email, String refreshToken) {
//    RefreshToken refreshTokenEntity = new RefreshToken();
//    refreshTokenEntity.setEmail(email);
//    refreshTokenEntity.setToken(refreshToken);
//    refreshTokenEntity.setExpiration(System.currentTimeMillis() + refreshTokenExp); // 30일
//    refreshTokenRepository.save(refreshTokenEntity);
//  }

  // 로그아웃 시 refreshToken 삭제
//  @Transactional
//  public boolean deleteRefreshToken(String refreshToken) {
//    try {
//      System.out.println("refreshToken: " + refreshToken);
//      // refreshToken이 유효한지 확인하고 삭제
//      refreshTokenRepository.deleteByToken(refreshToken);
//      return true;
//    } catch (Exception e) {
//      System.out.println("refreshToken 삭제 실패: " + e.getMessage());
//      return false;
//    }
//  }
}
