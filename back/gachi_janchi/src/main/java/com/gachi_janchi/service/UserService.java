package com.gachi_janchi.service;

import com.gachi_janchi.dto.NickNameAndPhoneNumberRequest;
import com.gachi_janchi.dto.NickNameAndPhoneNumberResponse;
import com.gachi_janchi.entity.User;
import com.gachi_janchi.repository.UserRepository;
import com.gachi_janchi.util.JwtProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class UserService {

  @Autowired
  UserRepository userRepository;

  @Autowired
  JwtProvider jwtProvider;

  @Autowired
  TokenService tokenService;

  // 닉네임 및 전화번호 추가 로직
  public NickNameAndPhoneNumberResponse updateAdditionalInfo(NickNameAndPhoneNumberRequest nickNameAndPhoneNumberRequest) {
    User user = userRepository.findByEmail(nickNameAndPhoneNumberRequest.getEmail()).orElseThrow(() -> new IllegalArgumentException("User not found"));

    // 닉네임과 전화번호 업데이트
    user.setNickName(nickNameAndPhoneNumberRequest.getNickName());
    user.setPhoneNumber(nickNameAndPhoneNumberRequest.getPhoneNumber());
    userRepository.save(user);

    return new NickNameAndPhoneNumberResponse("User additional info updated successfully");
  }

  // 로그아웃 처리 로직
  public boolean logout(String token) {
    String refreshToken = "";
    try {
      // Bearer 접두사 제거
      if (token != null && token.startsWith("Bearer ")) {
        refreshToken = jwtProvider.getTokenWithoutBearer(token);
      }
      // refreshToken 삭제
      return tokenService.deleteRefreshToken(refreshToken);
    } catch (Exception e) {
      System.out.println("로그아웃 처리 중 오류 발생: " + e.getMessage());
      return false;
    }
  }
}
