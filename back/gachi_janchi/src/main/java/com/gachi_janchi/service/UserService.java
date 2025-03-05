package com.gachi_janchi.service;
import com.gachi_janchi.dto.DeleteUserRequest;
import com.gachi_janchi.dto.DeleteUserResponse;
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
import com.gachi_janchi.dto.UserResponse;

@Service
@Transactional
public class UserService {

  @Autowired
  private LocalAccountRepository localAccountRepository;  // ✅ LocalAccountRepository 주입

  @Autowired
  UserRepository userRepository;

  @Autowired
  JwtProvider jwtProvider;

  @Autowired
  TokenService tokenService;

  @Autowired
  private PasswordEncoder passwordEncoder;


   // 사용자 정보 조회 (DTO를 여기서 반환)

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
  public UpdateNameResponse updateName(UpdateNameRequest request, String token) {
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

    // 이름 업데이트
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

  public UpdatePasswordResponse updatePassword(UpdatePasswordRequest request, String token) {
    try {
      // Bearer 제거
      String accessToken = jwtProvider.getTokenWithoutBearer(token);

      // 토큰 유효성 검사
      if (!jwtProvider.validateToken(accessToken)) {
        return new UpdatePasswordResponse(false, "유효하지 않은 토큰입니다.");
      }

      // 토큰에서 사용자 ID 추출
      String userId = jwtProvider.getUserId(accessToken);

      // LocalAccount에서 사용자 조회
      LocalAccount localAccount = localAccountRepository.findById(userId)
              .orElseThrow(() -> new IllegalArgumentException("해당 사용자 계정을 찾을 수 없습니다."));

      // 새 비밀번호 저장 (BCrypt 암호화 적용)
      localAccount.setPassword(passwordEncoder.encode(request.getPassword()));
      localAccountRepository.save(localAccount);

      return new UpdatePasswordResponse(true, "비밀번호가 성공적으로 변경되었습니다.");
    } catch (IllegalArgumentException e) {
      return new UpdatePasswordResponse(false, e.getMessage());
    } catch (Exception e) {
      return new UpdatePasswordResponse(false, "비밀번호 변경 중 오류가 발생했습니다.");
    }
  }


  /**
   * ✅ 회원 탈퇴 처리 (탈퇴 사유 포함)
   */
  public DeleteUserResponse deleteUser(DeleteUserRequest request, String token) {
    // Bearer 제거
    String accessToken = jwtProvider.getTokenWithoutBearer(token);

    // 토큰 유효성 검사
    if (!jwtProvider.validateToken(accessToken)) {
      return new DeleteUserResponse(false, "유효하지 않은 토큰입니다.");
    }

    // 토큰에서 사용자 ID 추출
    String userId = jwtProvider.getUserId(accessToken);

    // 사용자 조회
    User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("해당 사용자를 찾을 수 없습니다."));

    // LocalAccount 삭제 (소셜 로그인 사용자는 LocalAccount가 없을 수도 있음)
    localAccountRepository.findById(userId).ifPresent(localAccountRepository::delete);

    // User 삭제
    userRepository.delete(user);

    // 탈퇴 사유 로그 출력 (DB 저장이 필요하면 따로 테이블 만들어 저장 가능)
    System.out.println("회원 탈퇴 사유: " + request.getReason());

    return new DeleteUserResponse(true, "회원 탈퇴가 완료되었습니다.");
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
