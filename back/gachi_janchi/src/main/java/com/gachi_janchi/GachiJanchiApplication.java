package com.gachi_janchi;

import io.github.cdimascio.dotenv.Dotenv;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class GachiJanchiApplication {

  public static void main(String[] args) {

    // .env 파일 로드
    Dotenv dotenv = Dotenv.configure().load();

    // MYSQL_PASSWORD를 환경 변수로 설정
    System.setProperty("MYSQL_PASSWORD", dotenv.get("MYSQL_PASSWORD"));
    System.setProperty("MONGODB_PASSWORD", dotenv.get("MONGODB_PASSWORD"));
    System.setProperty("JWT_SECRET_KEY", dotenv.get("JWT_SECRET_KEY"));
    System.setProperty("ACCESS_TOKEN_EXP", dotenv.get("ACCESS_TOKEN_EXP"));
    System.setProperty("REFRESH_TOKEN_EXP", dotenv.get("REFRESH_TOKEN_EXP"));
    System.setProperty("JWT_ISSUER", dotenv.get("JWT_ISSUER"));
    System.setProperty("GOOGLE_WEB_CLIENT_ID", dotenv.get("GOOGLE_WEB_CLIENT_ID"));
    System.setProperty("NAVER_USER_INFO_URL", dotenv.get("NAVER_USER_INFO_URL"));
    System.setProperty("GOOGLE_MAIL_PASSWORD", dotenv.get("GOOGLE_MAIL_PASSWORD"));
    System.setProperty("profile.image.path", dotenv.get("PROFILE_IMAGE_PATH")); // 💡 키를 맞춰줘야 함

    SpringApplication.run(GachiJanchiApplication.class, args);
  }

}
