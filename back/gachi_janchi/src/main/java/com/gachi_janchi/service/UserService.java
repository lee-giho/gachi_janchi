package com.gachi_janchi.service;

import com.gachi_janchi.dto.*;
import com.gachi_janchi.entity.User;
import com.gachi_janchi.repository.UserRepository;
import com.gachi_janchi.util.JwtProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.gachi_janchi.dto.UserResponse;

@Service
@Transactional
public class UserService {

  @Autowired
  UserRepository userRepository;

  @Autowired
  JwtProvider jwtProvider;

  @Autowired
  TokenService tokenService;


  /**
   * ✅ 사용자 정보 조회 (DTO를 여기서 반환)
   */
  public UserResponse getUserInfo(String token) {
    // Bearer 제거
    String accessToken = jwtProvider.getTokenWithoutBearer(token);

    // 토큰 유효성 검사
    if (!jwtProvider.validateToken(accessToken)) {
      throw new IllegalArgumentException("유효하지 않은 토큰입니다.");
    }

    // 토큰에서 사용자 ID 추출
    String userId = jwtProvider.getUserId(accessToken);

    // DB에서 User 엔티티 조회
    User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

    // ✅ 여기서 DTO를 생성하여 반환 (한 번만 생성)
    return new UserResponse(user.getNickName(), user.getName(), user.getEmail());
  }
  /**
   * 닉네임 추가 로직
   */
  public NickNameAddResponse updateNickName(NickNameAddRequest nickNameAddRequest, String token) {
    // Bearer 제거
    String accessToken = jwtProvider.getTokenWithoutBearer(token);

    // 토큰 유효성 검사
    if (!jwtProvider.validateToken(accessToken)) {
      throw new IllegalArgumentException("유효하지 않은 토큰입니다.");
    }

    // 토큰에서 사용자 ID 추출
    String id = jwtProvider.getUserId(accessToken);

    // DB에서 User 엔티티 조회
    User user = userRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

    // 닉네임 업데이트
    user.setNickName(nickNameAddRequest.getNickName());
    userRepository.save(user);

    return new NickNameAddResponse("User additional info updated successfully");
  }

  /**
   * 닉네임 중복 확인 로직
   */
  public CheckNickNameDuplicationResponse checkNickNameDuplication(String nickName) {
    boolean isDuplication = userRepository.existsByNickName(nickName);
    return new CheckNickNameDuplicationResponse(isDuplication);
  }

  /**
   * 이름 변경 로직
   */
  public UpdateNameResponse updateName(UserResponse request, String token) {
    // Bearer 제거
    String accessToken = jwtProvider.getTokenWithoutBearer(token);

    // 토큰 유효성 검사
    if (!jwtProvider.validateToken(accessToken)) {
      return new UpdateNameResponse(false, "유효하지 않은 토큰입니다.");
    }

    // 토큰에서 User ID 추출
    String userId = jwtProvider.getUserId(accessToken);

    // DB에서 User 엔티티 조회
    User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

    // 이름 업데이트 (중복 확인 없음)
    user.setName(request.getName());
    userRepository.save(user);

    return new UpdateNameResponse(true, "이름이 성공적으로 변경되었습니다.");
  }

  /**
   * 이메일 변경 로직
   */
  public UpdateEmailResponse updateEmail(UpdateEmailRequest request, String token) {
    // Bearer 제거
    String accessToken = jwtProvider.getTokenWithoutBearer(token);

    // 토큰 유효성 검사
    if (!jwtProvider.validateToken(accessToken)) {
      return new UpdateEmailResponse(false, "유효하지 않은 토큰입니다.");
    }

    // 토큰에서 User ID 추출
    String userId = jwtProvider.getUserId(accessToken);

    // DB에서 User 엔티티 조회
    User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

    // 이메일 중복 확인 (현재 사용 중인 이메일은 제외)
    if (userRepository.existsByEmail(request.getEmail())) {
      return new UpdateEmailResponse(false, "이미 사용 중인 이메일입니다.");
    }

    // User 엔티티의 email 필드 수정
    user.setEmail(request.getEmail());
    userRepository.save(user);

    return new UpdateEmailResponse(true, "이메일이 성공적으로 변경되었습니다.");
  }

  /**
   * 토큰 유효성 검사
   */
  public boolean validateToken(String token) {
    return jwtProvider.validateToken(token);
  }

  /**
   * Bearer 제거
   */
  public String getTokenWithoutBearer(String token) {
    return jwtProvider.getTokenWithoutBearer(token);
  }

}
