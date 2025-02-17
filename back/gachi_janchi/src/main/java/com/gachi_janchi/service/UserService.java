package com.gachi_janchi.service;

import com.gachi_janchi.dto.CheckNickNameDuplicationResponse;
import com.gachi_janchi.dto.NickNameAddRequest;
import com.gachi_janchi.dto.NickNameAddResponse;
import com.gachi_janchi.entity.User;
import com.gachi_janchi.repository.UserRepository;
import com.gachi_janchi.util.JwtProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class UserService {

  @Autowired
  UserRepository userRepository;

  @Autowired
  JwtProvider jwtProvider;

  @Autowired
  TokenService tokenService;

  // 닉네임 추가 로직
  public NickNameAddResponse updateNickName(NickNameAddRequest nickNameAddRequest, String accessToken) {
    String email = jwtProvider.getUserEmail(accessToken);

    User user = userRepository.findByEmail(email).orElseThrow(() -> new IllegalArgumentException("User not found"));

    // 닉네임 업데이트
    user.setNickName(nickNameAddRequest.getNickName());
    userRepository.save(user);

    return new NickNameAddResponse("User additional info updated successfully");
  }

  // 닉네임 중복 확인 로직
  public CheckNickNameDuplicationResponse checkNickNameDuplication(String nickName) {
    boolean isDuplication = userRepository.existsByNickName(nickName);

    return new CheckNickNameDuplicationResponse(isDuplication);
  }

  // 로그아웃 처리 로직
//  public boolean logout(String token) {
//    String refreshToken = "";
//    try {
//      // Bearer 접두사 제거
//      if (token != null && token.startsWith("Bearer ")) {
//        refreshToken = jwtProvider.getTokenWithoutBearer(token);
//      }
//      // refreshToken 삭제
//      return tokenService.deleteRefreshToken(refreshToken);
//    } catch (Exception e) {
//      System.out.println("로그아웃 처리 중 오류 발생: " + e.getMessage());
//      return false;
//    }
//  }
}
