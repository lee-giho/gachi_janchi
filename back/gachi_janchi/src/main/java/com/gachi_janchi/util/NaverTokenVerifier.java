package com.gachi_janchi.util;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import com.gachi_janchi.exception.CustomException;
import com.gachi_janchi.exception.ErrorCode;

import java.util.Map;

@Component
public class NaverTokenVerifier {

  @Value("${NAVER_USER_INFO_URL}")
  private String naverUserInfoURL;

  public Map<String, Object> getNaverUserInfo(String accessToken) {
    RestTemplate restTemplate = new RestTemplate();
    try {
      // 네이버 사용자 정보 API 호출
      HttpHeaders headers = new HttpHeaders();
      headers.set("Authorization", "Bearer " + accessToken);

      // HttpEntity에 헤더 설정
      HttpEntity<?> entity = new HttpEntity<>(headers);

      ResponseEntity<Map> response = restTemplate.exchange(
              naverUserInfoURL,
              HttpMethod.GET,
              entity,
              Map.class
      );
      System.out.println("response: " + response);
      System.out.println("response.getBody(): " + response.getBody());
      return (Map<String, Object>) response.getBody().get("response");
    } catch (Exception e) {
      // throw new IllegalArgumentException("유효하지 않은 AccessToken: " + e.getMessage());
      throw new CustomException(ErrorCode.INVALID_NAVER_ACCESS_TOKEN);
    }
  }
}
