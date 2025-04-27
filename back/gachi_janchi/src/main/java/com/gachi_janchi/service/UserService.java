package com.gachi_janchi.service;

import com.gachi_janchi.dto.*;
import com.gachi_janchi.entity.LocalAccount;
import com.gachi_janchi.entity.User;
import com.gachi_janchi.exception.CustomException;
import com.gachi_janchi.exception.ErrorCode;
import com.gachi_janchi.repository.UserRepository;
import com.gachi_janchi.repository.LocalAccountRepository;
import com.gachi_janchi.util.JwtProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.data.domain.Pageable;
import org.springframework.beans.factory.annotation.Value;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

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

  @Value("${PROFILE_IMAGE_PATH}")
  private String profileImagePath;

  // 사용자 정보 조회 (DTO 반환)
  public UserResponse getUserInfo(String token) {
    String accessToken = jwtProvider.getTokenWithoutBearer(token);

    if (!jwtProvider.validateToken(accessToken)) {
      // throw new IllegalArgumentException("유효하지 않은 토큰입니다.");
      throw new CustomException(ErrorCode.INVALID_ACCESS_TOKEN);
    }

    String userId = jwtProvider.getUserId(accessToken);

    User user = userRepository.findById(userId)
            // .orElseThrow(() -> new IllegalArgumentException("User not found"));
            .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

    String titleName = (user.getTitle() != null) ? user.getTitle().getName() : null;

    return new UserResponse(
            user.getNickName(),
            titleName, // 대표 칭호 포함
            user.getName(),
            user.getEmail(),
            user.getType(),
            user.getProfileImage(),
            user.getExp() // exp로 레벨 및 진행도 계산
    );
  }

  public NickNameAddResponse updateNickName(NickNameAddRequest nickNameAddRequest, String token) {
    String accessToken = jwtProvider.getTokenWithoutBearer(token);
    if (!jwtProvider.validateToken(accessToken)) {
      // throw new IllegalArgumentException("유효하지 않은 토큰입니다.");
      throw new CustomException(ErrorCode.INVALID_ACCESS_TOKEN);
    }
    String id = jwtProvider.getUserId(accessToken);
    User user = userRepository.findById(id)
            // .orElseThrow(() -> new IllegalArgumentException("User not found"));
            .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
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
            // .orElseThrow(() -> new IllegalArgumentException("User not found"));
            .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
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
              // .orElseThrow(() -> new IllegalArgumentException("해당 사용자 계정을 찾을 수 없습니다."));
              .orElseThrow(() -> new CustomException(ErrorCode.LOCAL_ACCOUNT_NOT_FOUND));
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
      // throw new IllegalArgumentException("유효하지 않은 토큰입니다.");
      throw new CustomException(ErrorCode.INVALID_ACCESS_TOKEN);
    }
    String userId = jwtProvider.getUserId(accessToken);
    LocalAccount localAccount = localAccountRepository.findById(userId)
            // .orElseThrow(() -> new IllegalArgumentException("User not found"));
            .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
    return passwordEncoder.matches(inputPassword, localAccount.getPassword());
  }

  public DeleteUserResponse deleteUser(DeleteUserRequest request, String token) {
    String accessToken = jwtProvider.getTokenWithoutBearer(token);
    if (!jwtProvider.validateToken(accessToken)) {
      return new DeleteUserResponse(false, "유효하지 않은 토큰입니다.");
    }
    String userId = jwtProvider.getUserId(accessToken);
    User user = userRepository.findById(userId)
            // .orElseThrow(() -> new IllegalArgumentException("해당 사용자를 찾을 수 없습니다."));
            .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
    localAccountRepository.findById(userId).ifPresent(localAccountRepository::delete);
    userRepository.delete(user);
    System.out.println("회원 탈퇴 사유: " + request.getReason());
    return new DeleteUserResponse(true, "회원 탈퇴가 완료되었습니다.");
  }

  public String saveProfileImage(MultipartFile file, String token) {
    String accessToken = jwtProvider.getTokenWithoutBearer(token);
    if (!jwtProvider.validateToken(accessToken)) {
      // throw new IllegalArgumentException("유효하지 않은 토큰입니다.");
      throw new CustomException(ErrorCode.INVALID_ACCESS_TOKEN);
    }
    String userId = jwtProvider.getUserId(accessToken);
    User user = userRepository.findById(userId)
            // .orElseThrow(() -> new IllegalArgumentException("User not found"));
            .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

    // 기존 이미지 삭제
    String oldImageName = user.getProfileImage();
    if (oldImageName != null) {
      File oldFile = new File(profileImagePath, oldImageName);
      if (oldFile.exists()) {
        oldFile.delete();
      }
    }

    String fileName = UUID.randomUUID() + "_" + file.getOriginalFilename();
    File dir = new File(profileImagePath);
    if (!dir.exists()) dir.mkdirs();
    File dest = new File(dir, fileName);
    System.out.println("저장 경로: " + dest.getAbsolutePath());
    System.out.println("파일 이름: " + fileName);

    try {
      file.transferTo(dest);
      user.setProfileImage(fileName); // 파일 이름만 저장
      userRepository.save(user);
      return fileName;
    } catch (IOException e) {
      // throw new RuntimeException("파일 저장 중 오류가 발생했습니다.", e);
      throw new CustomException(ErrorCode.FILE_STORAGE_ERROR);
    }
  }
  public void deleteProfileImage(String token) {
    String accessToken = jwtProvider.getTokenWithoutBearer(token);
    if (!jwtProvider.validateToken(accessToken)) {
      // throw new IllegalArgumentException("유효하지 않은 토큰입니다.");
      throw new CustomException(ErrorCode.INVALID_ACCESS_TOKEN);
    }
    String userId = jwtProvider.getUserId(accessToken);
    User user = userRepository.findById(userId)
            // .orElseThrow(() -> new IllegalArgumentException("User not found"));
            .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
    String oldImageName = user.getProfileImage();
    if (oldImageName != null) {
      File oldFile = new File(profileImagePath, oldImageName);
      if (oldFile.exists()) {
        oldFile.delete();
      }
    }
    user.setProfileImage(null);
    userRepository.save(user);
  }

  public void gainExp(String userId, int amount) {
    User user = userRepository.findById(userId)
            // .orElseThrow(() -> new IllegalArgumentException("User not found"));
            .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
    user.setExp(user.getExp() + amount);
    userRepository.save(user);
  }

  public List<RankingUserResponse> getRanking(Pageable pageable) {
    System.out.println("랭킹 조회 시작");
    List<User> topUsers = userRepository.findTopUsers(pageable).getContent();
    System.out.println("사용자 수: " + topUsers.size());
    return topUsers.stream()
            .map(u -> new RankingUserResponse(u.getNickName(), u.getProfileImage(),    u.getTitle() != null ? u.getTitle().getName() : null,u.getExp()))
            .toList();
  }

}
