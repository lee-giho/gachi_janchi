package com.gachi_janchi.util;

import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.Date;

@Component
public class JwtUtil {

  @Value("${JWT_SECRET_KEY}")
  private String secret;

  // access token 생성
  public String generateAccessToken(String email) {

    final long expiration = 1000 * 60 * 60 * 24; // 1일 (밀리초);

    return Jwts
            .builder()
            .setSubject(email)
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + expiration))
            .signWith(SignatureAlgorithm.HS256, secret)
            .compact();
  }

  // refresh token 생성
  public String generateRefreshToken(String email) {

    final long expiration = 1000 * 60 * 60 * 24 * 30; // 30일 (밀리초);

    return Jwts
            .builder()
            .setSubject(email)
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + expiration))
            .signWith(SignatureAlgorithm.HS256, secret)
            .compact();

  }

  // 유효한 토큰인지 확인
  public boolean validateToken(String token) {
    try {
      Jwts
              .parser()
              .setSigningKey(secret)
              .parseClaimsJws(token);
      return true;
    } catch (JwtException | IllegalArgumentException e) {
      return false;
    }
  }

  // 토큰에서 사용자 정보 추출
  public String extractUsername(String token) {
    return Jwts
            .parser()
            .setSigningKey(secret)
            .parseClaimsJws(token)
            .getBody()
            .getSubject();
  }
}
