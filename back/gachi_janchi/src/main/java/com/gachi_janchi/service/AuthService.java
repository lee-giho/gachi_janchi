package com.gachi_janchi.service;

import com.gachi_janchi.dto.*;
import com.gachi_janchi.entity.*;
import com.gachi_janchi.repository.*;
import com.gachi_janchi.util.GoogleTokenVerifier;
import com.gachi_janchi.util.JwtProvider;
import com.gachi_janchi.util.NaverTokenVerifier;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
@Transactional
public class AuthService {

  @Autowired private UserRepository userRepository;
  @Autowired private LocalAccountRepository localAccountRepository;
  @Autowired private RoleRepository roleRepository;
  @Autowired private SocialAccountRepository socialAccountRepository;
  @Autowired private JwtProvider jwtProvider;
  @Autowired private PasswordEncoder passwordEncoder;
  @Autowired private GoogleTokenVerifier googleTokenVerifier;
  @Autowired private NaverTokenVerifier naverTokenVerifier;
  @Autowired private TitleRepository titleRepository;
  @Autowired private UserTitleRepository userTitleRepository;

  public CheckIdDuplicationResponse checkIdDuplication(String id) {
    boolean isDuplication = localAccountRepository.existsById(id);
    return new CheckIdDuplicationResponse(isDuplication);
  }

  /**
   * ✅ 로컬 회원가입
   */
  public RegisterResponse register(RegisterRequest registerRequest) {
    if (userRepository.existsById(registerRequest.getId())) {
      throw new IllegalArgumentException("이미 사용 중인 ID입니다.");
    }

    Role roleUser = roleRepository.findById("ROLE_USER")
            .orElseThrow(() -> new IllegalArgumentException("기본 권한 ROLE_USER가 설정되어 있지 않습니다."));

    Title defaultTitle = titleRepository.findByName("요리 입문자")
            .orElseThrow(() -> new IllegalArgumentException("기본 칭호 '요리 입문자'가 존재하지 않습니다."));

    // User 생성 (대표 칭호는 설정하지 않음)
    User user = new User();
    user.setId(registerRequest.getId());
    user.setName(registerRequest.getName());
    user.setEmail(registerRequest.getEmail());
    user.setType("local");
    user.setRoles(Set.of(roleUser));
    userRepository.save(user);

    LocalAccount localAccount = new LocalAccount();
    localAccount.setId(registerRequest.getId());
    localAccount.setPassword(passwordEncoder.encode(registerRequest.getPassword()));
    localAccountRepository.save(localAccount);

    // 요리 입문자 칭호 보유만 등록
    userTitleRepository.save(new UserTitle(user.getId(), defaultTitle));

    return new RegisterResponse("회원가입 완료");
  }

  public LoginResponse login(LoginRequest loginRequest) {
    User user = userRepository.findById(loginRequest.getId())
            .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));
    LocalAccount localAccount = localAccountRepository.findById(loginRequest.getId())
            .orElseThrow(() -> new IllegalArgumentException("비밀번호 정보를 찾을 수 없습니다."));

    if (!passwordEncoder.matches(loginRequest.getPassword(), localAccount.getPassword())) {
      throw new IllegalArgumentException("비밀번호가 일치하지 않습니다.");
    }

    boolean existNickName = user.getNickName() != null && !user.getNickName().isEmpty();

    return new LoginResponse(
            jwtProvider.generateAccessToken(user),
            jwtProvider.generateRefreshToken(user),
            existNickName
    );
  }

  public GoogleLoginResponse googleLogin(GoogleLoginRequest request) {
    try {
      Map<String, Object> tokenInfo = googleTokenVerifier.getGoogleUserInfo(request.getIdToken());
      String id = (String) tokenInfo.get("email");
      String name = (String) tokenInfo.get("name");

      if (id == null || name == null) throw new IllegalArgumentException("잘못된 사용자 정보");

      User user = userRepository.findById(id).orElse(null);
      if (user == null) {
        Role roleUser = roleRepository.findById("ROLE_USER")
                .orElseThrow(() -> new IllegalArgumentException("ROLE_USER가 존재하지 않습니다."));

        Title defaultTitle = titleRepository.findByName("요리 입문자")
                .orElseThrow(() -> new IllegalArgumentException("칭호 '요리 입문자' 없음"));

        user = new User();
        user.setId(id);
        user.setName(name);
        user.setType("social");
        user.setRoles(Set.of(roleUser));
        userRepository.save(user);

        SocialAccount account = new SocialAccount();
        account.setEmail(id);
        account.setProvider("google");
        socialAccountRepository.save(account);

        userTitleRepository.save(new UserTitle(id, defaultTitle));
      }

      boolean hasNickname = user.getNickName() != null && !user.getNickName().isEmpty();

      return new GoogleLoginResponse(
              jwtProvider.generateAccessToken(user),
              jwtProvider.generateRefreshToken(user),
              hasNickname
      );
    } catch (Exception e) {
      System.out.println("구글 로그인 오류: " + e.getMessage());
      return new GoogleLoginResponse(null, null, false);
    }
  }

  public NaverLoginResponse naverLogin(NaverLoginRequest request) {
    try {
      Map<String, Object> tokenInfo = naverTokenVerifier.getNaverUserInfo(request.getAccessToken());
      String id = (String) tokenInfo.get("email");
      String name = (String) tokenInfo.get("name");

      if (id == null || name == null) throw new IllegalArgumentException("잘못된 사용자 정보");

      User user = userRepository.findById(id).orElse(null);
      if (user == null) {
        Role roleUser = roleRepository.findById("ROLE_USER")
                .orElseThrow(() -> new IllegalArgumentException("ROLE_USER가 존재하지 않습니다."));

        Title defaultTitle = titleRepository.findByName("요리 입문자")
                .orElseThrow(() -> new IllegalArgumentException("칭호 '요리 입문자' 없음"));

        user = new User();
        user.setId(id);
        user.setName(name);
        user.setType("social");
        user.setRoles(Set.of(roleUser));
        userRepository.save(user);

        SocialAccount account = new SocialAccount();
        account.setEmail(id);
        account.setProvider("naver");
        socialAccountRepository.save(account);

        userTitleRepository.save(new UserTitle(id, defaultTitle));
      }

      boolean hasNickname = user.getNickName() != null && !user.getNickName().isEmpty();

      return new NaverLoginResponse(
              jwtProvider.generateAccessToken(user),
              jwtProvider.generateRefreshToken(user),
              hasNickname
      );
    } catch (Exception e) {
      System.out.println("네이버 로그인 오류: " + e.getMessage());
      return new NaverLoginResponse(null, null, false);
    }
  }

  public FindIdResponse findId(String name, String email) {
    User user = userRepository.findByNameAndEmail(name, email)
            .orElseThrow(() -> new IllegalArgumentException("해당 정보를 가진 유저가 없습니다."));
    return new FindIdResponse(user.getId());
  }

  public FindPasswordResponse findUserForFindPassword(String name, String id, String email) {
    boolean found = userRepository.existsByNameAndIdAndEmail(name, id, email);
    return new FindPasswordResponse(found);
  }

  public ChangePasswordResponse changePassword(ChangePasswordRequest req) {
    try {
      LocalAccount account = localAccountRepository.findById(req.getId())
              .orElseThrow(() -> new IllegalArgumentException("사용자 없음"));
      account.setPassword(passwordEncoder.encode(req.getPassword()));
      localAccountRepository.save(account);
      return new ChangePasswordResponse("Success");
    } catch (Exception e) {
      return new ChangePasswordResponse("Error: " + e.getMessage());
    }
  }
}
