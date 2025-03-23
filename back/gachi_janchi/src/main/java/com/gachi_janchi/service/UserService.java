package com.gachi_janchi.service;

import com.gachi_janchi.dto.*;
import com.gachi_janchi.entity.LocalAccount;
import com.gachi_janchi.entity.User;
import com.gachi_janchi.repository.UserRepository;
import com.gachi_janchi.repository.LocalAccountRepository;
import com.gachi_janchi.util.JwtProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class UserService {

  @Autowired
  private LocalAccountRepository localAccountRepository;

  @Autowired
  UserRepository userRepository;

  @Autowired
  JwtProvider jwtProvider;

  @Autowired
  TokenService tokenService;

  @Autowired
  private PasswordEncoder passwordEncoder;

  // ✅ 사용자 정보 조회 (DTO 반환)
  public UserResponse getUserInfo(String token) {
    String accessToken = jwtProvider.getTokenWithoutBearer(token);

    if (!jwtProvider.validateToken(accessToken)) {
      throw new IllegalArgumentException("유효하지 않은 토큰입니다.");
    }

    String userId = jwtProvider.getUserId(accessToken);

    User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

    String titleName = (user.getTitle() != null) ? user.getTitle().getName() : null;

    return new UserResponse(
            user.getNickName(),
            titleName, // ✅ 대표 칭호 포함
            user.getName(),
            user.getEmail(),
            user.getType()
    );
  }

  public NickNameAddResponse updateNickName(NickNameAddRequest nickNameAddRequest, String token) {
    String accessToken = jwtProvider.getTokenWithoutBearer(token);
    if (!jwtProvider.validateToken(accessToken)) {
      throw new IllegalArgumentException("유효하지 않은 토큰입니다.");
    }
    String id = jwtProvider.getUserId(accessToken);
    User user = userRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));
    user.setNickName(nickNameAddRequest.getNickName());
    userRepository.save(user);
    return new NickNameAddResponse("User additional info updated successfully");
  }

  public CheckNickNameDuplicationResponse checkNickNameDuplication(String nickName) {
    boolean isDuplication = userRepository.existsByNickName(nickName);
    return new CheckNickNameDuplicationResponse(isDuplication);
  }

  public UpdateNameResponse updateName(UpdateNameRequest request, String token) {
    String accessToken = jwtProvider.getTokenWithoutBearer(token);
    if (!jwtProvider.validateToken(accessToken)) {
      return new UpdateNameResponse(false, "유효하지 않은 토큰입니다.");
    }
    String userId = jwtProvider.getUserId(accessToken);
    User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));
    user.setName(request.getName());
    userRepository.save(user);
    return new UpdateNameResponse(true, "이름이 성공적으로 변경되었습니다.");
  }

  public UpdatePasswordResponse updatePassword(UpdatePasswordRequest request, String token) {
    try {
      String accessToken = jwtProvider.getTokenWithoutBearer(token);
      if (!jwtProvider.validateToken(accessToken)) {
        return new UpdatePasswordResponse(false, "유효하지 않은 토큰입니다.");
      }
      String userId = jwtProvider.getUserId(accessToken);
      LocalAccount localAccount = localAccountRepository.findById(userId)
              .orElseThrow(() -> new IllegalArgumentException("해당 사용자 계정을 찾을 수 없습니다."));
      localAccount.setPassword(passwordEncoder.encode(request.getPassword()));
      localAccountRepository.save(localAccount);
      return new UpdatePasswordResponse(true, "비밀번호가 성공적으로 변경되었습니다.");
    } catch (IllegalArgumentException e) {
      return new UpdatePasswordResponse(false, e.getMessage());
    } catch (Exception e) {
      return new UpdatePasswordResponse(false, "비밀번호 변경 중 오류가 발생했습니다.");
    }
  }

  public boolean verifyPassword(String token, String inputPassword) {
    String accessToken = jwtProvider.getTokenWithoutBearer(token);
    if (!jwtProvider.validateToken(accessToken)) {
      throw new IllegalArgumentException("유효하지 않은 토큰입니다.");
    }
    String userId = jwtProvider.getUserId(accessToken);
    LocalAccount localAccount = localAccountRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));
    return passwordEncoder.matches(inputPassword, localAccount.getPassword());
  }

  public DeleteUserResponse deleteUser(DeleteUserRequest request, String token) {
    String accessToken = jwtProvider.getTokenWithoutBearer(token);
    if (!jwtProvider.validateToken(accessToken)) {
      return new DeleteUserResponse(false, "유효하지 않은 토큰입니다.");
    }
    String userId = jwtProvider.getUserId(accessToken);
    User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("해당 사용자를 찾을 수 없습니다."));
    localAccountRepository.findById(userId).ifPresent(localAccountRepository::delete);
    userRepository.delete(user);
    System.out.println("회원 탈퇴 사유: " + request.getReason());
    return new DeleteUserResponse(true, "회원 탈퇴가 완료되었습니다.");
  }

  public boolean validateToken(String token) {
    return jwtProvider.validateToken(token);
  }

  public String getTokenWithoutBearer(String token) {
    return jwtProvider.getTokenWithoutBearer(token);
  }
}
