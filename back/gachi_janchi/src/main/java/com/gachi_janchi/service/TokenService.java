package com.gachi_janchi.service;

import com.gachi_janchi.dto.TokenRefreshResponse;
import com.gachi_janchi.dto.TokenValidationResponse;
import com.gachi_janchi.util.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class TokenService {

  @Autowired
  private JwtUtil jwtUtil;

  // accessToken 유효성 검사
  public TokenValidationResponse validateAccessToken(String accessToken) {
    return new TokenValidationResponse(jwtUtil.validateToken(accessToken));
  }

  // refreshToken으로 새로운 accessToken 발급
  public TokenRefreshResponse refreshAccessToken(String refreshToken) {
    if (!jwtUtil.validateToken(refreshToken)) {
      throw new IllegalArgumentException("Invalid refresh token");
    }

    // refreshToken이 유효한 경우, 새로운 accessToken을 발급
    String email = jwtUtil.extractUsername(refreshToken);
    return new TokenRefreshResponse(jwtUtil.generateAccessToken(email));
  }
}
