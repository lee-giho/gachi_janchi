package com.gachi_janchi.service;

import com.gachi_janchi.dto.*;
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

  // 닉네임 변경 로직
  public UpdateNickNameResponse updateNickName(UpdateNickNameRequest request, String token) {
    // 1. Access Token에서 User ID 추출
    String userId = jwtProvider.getUserId(token);

    // 2. DB에서 User 엔티티 조회
    User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

    // 3. 닉네임 중복 확인 (현재 사용 중인 닉네임은 제외)
    if (userRepository.existsByNickName(request.getNickname())) {
      return new UpdateNickNameResponse(false, "이미 사용 중인 닉네임입니다.");
    }

    // 4. User 엔티티의 nickName 필드 수정
    user.setNickName(request.getNickname());
    userRepository.save(user);

    return new UpdateNickNameResponse(true, "닉네임이 성공적으로 변경되었습니다.");
  }

  // 이름 변경 로직
  public UpdateNameResponse updateName(UpdateNameRequest request, String token) {
    // 1. Access Token에서 User ID 추출
    String userId = jwtProvider.getTokenWithoutBearer(token);

    // 2. DB에서 User 엔티티 조회
    User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

    // 3. 이름 업데이트 (중복 확인 없음)
    user.setName(request.getName());
    userRepository.save(user);

    return new UpdateNameResponse(true, "이름이 성공적으로 변경되었습니다.");
  }

  // 이메일 변경 로직
  public UpdateEmailResponse updateEmail(UpdateEmailRequest request, String token) {
    // 1. Access Token에서 User ID 추출
    String userId = jwtProvider.getTokenWithoutBearer(token);

    // 2. DB에서 User 엔티티 조회
    User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

    // 3. 이메일 중복 확인 (현재 사용 중인 이메일은 제외)
    if (userRepository.existsByEmail(request.getEmail())) {
      return new UpdateEmailResponse(false, "이미 사용 중인 이메일입니다.");
    }

    // 4. User 엔티티의 email 필드 수정
    user.setEmail(request.getEmail());
    userRepository.save(user);

    return new UpdateEmailResponse(true, "이메일이 성공적으로 변경되었습니다.");
  }
}
