package com.gachi_janchi.util;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.json.JsonFactory;
import com.google.api.client.json.jackson2.JacksonFactory;
import org.springframework.web.client.RestTemplate;

import java.util.Collections;
import java.util.Map;

@Component
public class GoogleTokenVerifier {

  @Value("${GOOGLE_WEB_CLIENT_ID}")
  private String googleWebClientId;

  private final String GOOGLE_TOKEN_INFO_URL = "https://oauth2.googleapis.com/tokeninfo";

  public Map<String, Object> getGoogleUserInfo(String idToken) {
    String url = GOOGLE_TOKEN_INFO_URL + "?id_token=" + idToken;

    // RestTemplate을 사용하여 Google 엔드포인트 호출
    RestTemplate restTemplate = new RestTemplate();
    try {
      System.out.println("여기?");
      Map<String, Object> tokenInfo = restTemplate.getForObject(url, Map.class);
      System.out.println("tokenInfo: " + tokenInfo);
//      // 클라이언트 ID 검증
//      String audience = (String) tokenInfo.get("aud");
//      if (!googleWebClientId.equals(audience)) {
//        throw new IllegalArgumentException("클라이언트 ID가 일치하지 않습니다.");
//      }

      return tokenInfo;
    } catch (Exception e) {
      throw new IllegalArgumentException("유효하지 않은 idToken: " + e.getMessage());
    }
  }
}
