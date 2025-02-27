package com.gachi_janchi.config;
import com.gachi_janchi.util.JwtProvider;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.util.ObjectUtils;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

  @Autowired
  private JwtProvider jwtProvider;

  // 헤더 내부에서 JWT 용으로 사용할 Key
  public static final String HEADER_KEY = "Authorization";

  // 인증 타입, Bearer
  public static final String PREFIX = "Bearer ";

  @Override
  protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {

    // 헤더에서 토큰 부분 분리
    String token = resolveTokenFromRequest(request);

    // 토큰 유효성 검증
    if(StringUtils.hasText(token) && jwtProvider.validateToken(token)) {
      // Authentication 객체 받아오기
      Authentication auth = jwtProvider.getAuthentication(token);
      // SecurityContextHolder에 저장
      SecurityContextHolder.getContext().setAuthentication(auth);
    }
    filterChain.doFilter(request, response);
  }

  private String resolveTokenFromRequest(HttpServletRequest request) {
    // 헤더에서 토큰 부분 분리
    String token = request.getHeader(HEADER_KEY);

    if (!ObjectUtils.isEmpty(token) && token.startsWith(PREFIX)) {
      // "Bearer " 이후의 토큰 추출
      return token.substring(PREFIX.length());
    }
    return null;
  }
}
