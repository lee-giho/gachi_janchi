package com.gachi_janchi.util;

import com.gachi_janchi.entity.User;
import com.gachi_janchi.exception.CustomException;
import com.gachi_janchi.exception.ErrorCode;
import com.gachi_janchi.service.UserDetailsService;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.SignatureException;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Component;

import java.util.Collections;
import java.util.Date;
import java.util.Set;

@Component
@RequiredArgsConstructor
public class JwtProvider {

  @Autowired
  UserDetailsService userDetailsService;

  @Value("${JWT_SECRET_KEY}")
  private String secretKey;

  @Value("${JWT_ISSUER}")
  private String issuer;

  @Value("${ACCESS_TOKEN_EXP}")
  private long accessTokenExp;

  @Value("${REFRESH_TOKEN_EXP}")
  private long refreshTokenExp;

  // access token 생성
  public String generateAccessToken(User user) {

    // 토큰 생성 시간
    Date now = new Date();

    // 토큰 만료 시간
    Date expireDate = new Date(now.getTime() + accessTokenExp);

    return Jwts.builder()
            .setHeaderParam(Header.TYPE, Header.JWT_TYPE) // 헤더 type : JWT
            .setIssuer(issuer) // 내용 iss : gachi_janchi
            .setIssuedAt(now) // 내용 iat : 현재 시간
            .setExpiration(expireDate) // 내용 exp : 만료 시간
            .setSubject(user.getId()) // 내용 sub : 유저 아이디
            .claim("id", user.getId()) // 클레임 id : 유저 아이디
            .signWith(SignatureAlgorithm.HS256, secretKey) // 서명 : 비밀값과 함께 해시값을 HS256 방식으로 암호화
            .compact();
  }

  // refresh token 생성
  public String generateRefreshToken(User user) {

    // 토큰 생성 시간
    Date now = new Date();

    // 토큰 만료 시간
    Date expireDate = new Date(now.getTime() + refreshTokenExp);

    return Jwts.builder()
            .setHeaderParam(Header.TYPE, Header.JWT_TYPE) // 헤더 type : JWT
            .setIssuer(issuer) // 내용 iss : gachi_janchi
            .setIssuedAt(now) // 내용 iat : 현재 시간
            .setExpiration(expireDate) // 내용 exp : 만료 시간
            .setSubject(user.getId()) // 내용 sub : 유저 아이디
            .claim("id", user.getId()) // 클레임 id : 유저 아이디
            .signWith(SignatureAlgorithm.HS256, secretKey) // 서명 : 비밀값과 함께 해시값을 HS256 방식으로 암호화
            .compact();
  }

  // 유효한 토큰인지 확인
  public boolean validateToken(String token) {
    System.out.println("validateToken: " + token);
    try {
      Jwts.parser()
              .setSigningKey(secretKey) // 비밀값으로 복호화
              .parseClaimsJws(token);
      System.out.println("true");
      return true;
    } catch (Exception e) { // 복호화 과정에서 에러가 나면 유효하지 않은 토큰
      System.out.println("false");
      return false;
    }
  }

  // 토큰 기반으로 Authentication 구현체 생성
  public Authentication getAuthentication(String token) {
    Claims claims = getClaims(token);
    System.out.println(claims);
    Set<SimpleGrantedAuthority> authorities = Collections.singleton(new SimpleGrantedAuthority("ROLE_USER"));
    System.out.println(authorities);
    return new UsernamePasswordAuthenticationToken(new org.springframework.security.core.userdetails.User(claims.getSubject(), "", authorities), token, authorities);
  }

  // 토큰에서 사용자 정보 추출
  public String getUserId(String token) {
    return getClaims(token).getSubject();
  }

  // 토큰에서 "Bearer " 추출
  public String getTokenWithoutBearer(String token) {
    return token.substring(7);
  }

  // 토큰에서 Claims 추출
  private Claims getClaims(String token) {
    Claims claims;
    try {
      claims = Jwts.parser().setSigningKey(secretKey).parseClaimsJws(token).getBody();
    } catch (SignatureException e) {
      // throw new BadCredentialsException("잘못된 비밀키", e);
      throw new CustomException(ErrorCode.INVALID_TOKEN_SIGNATURE);
    } catch (ExpiredJwtException e) {
      // throw new BadCredentialsException("만료된 토큰", e);
      throw new CustomException(ErrorCode.TOKEN_EXPIRED);
    } catch (MalformedJwtException e) {
      // throw new BadCredentialsException("유효하지 않은 구성의 토큰", e);
      throw new CustomException(ErrorCode.MALFORMED_JWT);
    } catch (UnsupportedJwtException e) {
      // throw new BadCredentialsException("지원되지 않은 형식이나 구성의 토큰", e);
      throw new CustomException(ErrorCode.UNSUPPORTED_JWT);
    } catch (IllegalArgumentException e) {
      // throw new BadCredentialsException("잘못된 입력값", e);
      throw new CustomException(ErrorCode.BAD_REQUEST);
    }
    return claims;
  }
}