package com.gachi_janchi.service;

import com.gachi_janchi.dto.CheckNickNameDuplicationResponse;
import com.gachi_janchi.dto.NickNameAddRequest;
import com.gachi_janchi.dto.NickNameAddResponse;
import com.gachi_janchi.dto.UpdateEmailResponse;
import com.gachi_janchi.dto.UpdateEmailRequest;
import com.gachi_janchi.dto.UpdateNameRequest;
import com.gachi_janchi.dto.UpdateNameResponse;
import com.gachi_janchi.dto.UpdateNickNameResponse;
import com.gachi_janchi.dto.UpdateNickNameRequest;
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
  public NickNameAddResponse updateNickName(NickNameAddRequest nickNameAddRequest, String token) {
    String accessToken = jwtProvider.getTokenWithoutBearer(token);

    String id = jwtProvider.getUserId(accessToken);

    User user = userRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("User not found"));

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

  // 닉네임 변경 로직
  public UpdateNickNameResponse updateNickName(UpdateNickNameRequest request, String token) {
    String accessToken = jwtProvider.getTokenWithoutBearer(token);
    String userId = jwtProvider.getUserId(accessToken);

    User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

    // 닉네임 중복 확인
    if (userRepository.existsByNickName(request.getNickname())) {
      return new UpdateNickNameResponse(false, "이미 사용 중인 닉네임입니다.");
    }

    // 닉네임 업데이트
    user.setNickName(request.getNickname());
    userRepository.save(user);

    return new UpdateNickNameResponse(true, "닉네임이 성공적으로 변경되었습니다.");
  }

  // 이름 변경 로직
  public UpdateNameResponse updateName(UpdateNameRequest request, String token) {
    String accessToken = jwtProvider.getTokenWithoutBearer(token);
    String userId = jwtProvider.getUserId(accessToken);

    User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

    // 이름 업데이트
    user.setName(request.getName());
    userRepository.save(user);

    return new UpdateNameResponse(true, "이름이 성공적으로 변경되었습니다.");
  }

  // 이메일 변경 로직
  public UpdateEmailResponse updateEmail(UpdateEmailRequest request, String token) {
    String accessToken = jwtProvider.getTokenWithoutBearer(token);
    String userId = jwtProvider.getUserId(accessToken);

    User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

    // 이메일 중복 확인
    if (userRepository.existsByEmail(request.getEmail())) {
      return new UpdateEmailResponse(false, "이미 사용 중인 이메일입니다.");
    }

    // 이메일 업데이트
    user.setEmail(request.getEmail());
    userRepository.save(user);

    return new UpdateEmailResponse(true, "이메일이 성공적으로 변경되었습니다.");
  }

}
