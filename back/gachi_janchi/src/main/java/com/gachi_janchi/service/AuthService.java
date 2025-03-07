package com.gachi_janchi.service;

import com.gachi_janchi.dto.*;
import com.gachi_janchi.entity.LocalAccount;
import com.gachi_janchi.entity.Role;
import com.gachi_janchi.entity.SocialAccount;
import com.gachi_janchi.entity.User;
import com.gachi_janchi.repository.LocalAccountRepository;
import com.gachi_janchi.repository.RoleRepository;
import com.gachi_janchi.repository.SocialAccountRepository;
import com.gachi_janchi.repository.UserRepository;
import com.gachi_janchi.util.GoogleTokenVerifier;
import com.gachi_janchi.util.JwtProvider;
import com.gachi_janchi.util.NaverTokenVerifier;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.Map;
import java.util.Set;

@Service
@Transactional
public class AuthService {

  @Autowired
  private UserRepository userRepository;

  @Autowired
  private LocalAccountRepository localAccountRepository;

  @Autowired
  private RoleRepository roleRepository;

  @Autowired
  private SocialAccountRepository socialAccountRepository;

  @Autowired
  private JwtProvider jwtProvider;

  @Autowired
  private PasswordEncoder passwordEncoder;

  @Autowired
  private GoogleTokenVerifier googleTokenVerifier;

  @Autowired
  private NaverTokenVerifier naverTokenVerifier;

  // 아이디 중복 확인 로직
  public CheckIdDuplicationResponse checkIdDuplication(String id) {
    boolean isDuplication = localAccountRepository.existsById(id);
    System.out.println("id 중복확인: " + isDuplication);
    return new CheckIdDuplicationResponse(isDuplication);
  }

  // 회원가입 로직 (ROLE_USER 기본 부여)
  public RegisterResponse register(RegisterRequest registerRequest) {
    if (userRepository.existsById(registerRequest.getId())) {
      throw new IllegalArgumentException("id already in use");
    }

    // 새로운 사용자 생성 및 저장 - users
    User user = new User();
    user.setId(registerRequest.getId());
    user.setName(registerRequest.getName());
    user.setEmail(registerRequest.getEmail());
    user.setType("local");

    // 기본 Role 설정 (ROLE_USER)
    Role roleUser = roleRepository.findById("ROLE_USER")
            .orElseThrow(() -> new IllegalArgumentException("기본 권한인 ROLE_USER가 설정되어 있지 않습니다."));
    Set<Role> roles = new HashSet<>();
    roles.add(roleUser);
    user.setRoles(roles);

    userRepository.save(user);

    // 새로운 로컬 사용자 생성 및 저장 - local_account
    LocalAccount localAccount = new LocalAccount();
    localAccount.setId(registerRequest.getId());
    localAccount.setPassword(passwordEncoder.encode(registerRequest.getPassword()));
    localAccountRepository.save(localAccount);

    return new RegisterResponse("User registered successfully");
  }

  public LoginResponse login(LoginRequest loginRequest) {
    User user = userRepository.findById(loginRequest.getId()).orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다. - " + loginRequest.getId()));
    LocalAccount localAccount = localAccountRepository.findById(loginRequest.getId()).orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다. - " + loginRequest.getId()));

    if (!passwordEncoder.matches(loginRequest.getPassword(), localAccount.getPassword())) {
      throw new IllegalArgumentException("비밀번호가 일치하지 않습니다. - " + loginRequest.getPassword());
    }

    // 닉네임을 입력한 사용자인지 확인
    boolean existNickName = user.getNickName() != null && !user.getNickName().isEmpty();

    String jwt = jwtProvider.generateAccessToken(user);
    String refreshToken = jwtProvider.generateRefreshToken(user);

    // refreshToken 데이터베이스에 저장
//    tokenService.saveRefreshToken(localAccount.getEmail(), refreshToken);

//    return jwtUtil.generateToken(loginRequest.getEmail());
    return new LoginResponse(jwt, refreshToken, existNickName);
  }

  public GoogleLoginResponse googleLogin(GoogleLoginRequest googleLoginRequest) {
    try {
      // Google ID Token 검증
      Map<String, Object> tokenInfo =  googleTokenVerifier.getGoogleUserInfo(googleLoginRequest.getIdToken());

      // 사용자 정보 가져오기
      String id = (String) tokenInfo.get("email"); // 소셜 로그인을 하는 사용자는 users 테이블의 id는 email로 들어간다.
      String name = (String) tokenInfo.get("name");

      if (id == null || name == null) {
        throw new IllegalArgumentException("유효하지 않은 사용자 정보");
      }

      // 사용자 저장 또는 업데이트 - social_account
      if (!userRepository.existsById(id) && !socialAccountRepository.existsByEmail(id)) {
        User user = new User();
        user.setId(id);
        user.setName(name);
        user.setType("social");

        // 📌 ROLE_USER 설정 추가
        Role roleUser = roleRepository.findById("ROLE_USER")
                .orElseThrow(() -> new IllegalArgumentException("기본 권한인 ROLE_USER가 설정되어 있지 않습니다."));
        Set<Role> roles = new HashSet<>();
        roles.add(roleUser);
        user.setRoles(roles);

        userRepository.save(user);

        SocialAccount socialAccount = new SocialAccount();
        socialAccount.setEmail(id);
        socialAccount.setProvider("google");
        // 기본 Role 설정 (ROLE_USER)
       /* Role roleUser = roleRepository.findById("ROLE_USER")
                .orElseThrow(() -> new IllegalArgumentException("기본 권한인 ROLE_USER가 설정되어 있지 않습니다."));
        Set<Role> roles = new HashSet<>();
        roles.add(roleUser);
        user.setRoles(roles);
        */
        socialAccountRepository.save(socialAccount);

//      userRepository.save(user);
        String jwt = jwtProvider.generateAccessToken(user);
        String refreshToken = jwtProvider.generateRefreshToken(user);

        // refreshToken 데이터베이스에 저장
//        tokenService.saveRefreshToken(socialAccount.getEmail(), refreshToken);

        return new GoogleLoginResponse(jwt, refreshToken, false);
      } else {
        System.out.println("이미 존재하는 사용자입니다.");

        User user = new User();
        user.setId(id);
        user.setName(name);

        String jwt = jwtProvider.generateAccessToken(user);
        String refreshToken = jwtProvider.generateRefreshToken(user);

        // refreshToken 데이터베이스에 저장
//        tokenService.saveRefreshToken(user.getEmail(), refreshToken);

        // 이메일로 사용자 찾기
        User existUser = userRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다. - " + id));

        // 닉네임을 입력한 사용자인지 확인
        boolean existNickName = existUser.getNickName() != null && !existUser.getNickName().isEmpty();

        return new GoogleLoginResponse(jwt, refreshToken, existNickName);
      }
    } catch (Exception e) {
      System.out.println("구글 idToken 검증 실패");
      return new GoogleLoginResponse(null, null, false);
    }
  }

  public NaverLoginResponse naverLogin(NaverLoginRequest naverLoginRequest) {
    try {
      System.out.println("naverLoginRequest.getAccessToken(): " + naverLoginRequest.getAccessToken());
      // Naver accessToken 검증
      Map<String, Object> tokenInfo = naverTokenVerifier.getNaverUserInfo(naverLoginRequest.getAccessToken());

      // 네이버 사용자 정보 가져오기
      String id = (String) tokenInfo.get("email"); // 소셜 로그인을 하는 사용자는 users 테이블의 id는 email로 들어간다.
      String name = (String) tokenInfo.get("name");

      if (id == null || name == null) {
        throw new IllegalArgumentException("유효하지 않은 사용자 정보");
      }

      // 사용자 저장 또는 업데이트
      if (!userRepository.existsById(id) && !socialAccountRepository.existsByEmail(id)) {
        User user = new User();
        user.setId(id);
        user.setName(name);
        user.setType("social");

        // 📌 ROLE_USER 설정 추가
        Role roleUser = roleRepository.findById("ROLE_USER")
                .orElseThrow(() -> new IllegalArgumentException("기본 권한인 ROLE_USER가 설정되어 있지 않습니다."));
        Set<Role> roles = new HashSet<>();
        roles.add(roleUser);
        user.setRoles(roles);

        userRepository.save(user);

        SocialAccount socialAccount = new SocialAccount();
        socialAccount.setEmail(id);
        socialAccount.setProvider("naver");
        socialAccountRepository.save(socialAccount);

        String jwt = jwtProvider.generateAccessToken(user);
        String refreshToken = jwtProvider.generateRefreshToken(user);

        // refreshToken 데이터베이스에 저장
//        tokenService.saveRefreshToken(socialAccount.getEmail(), refreshToken);

        return new NaverLoginResponse(jwt, refreshToken, false);
      } else {
        System.out.println("이미 존재하는 사용자입니다.");

        User user = new User();
        user.setId(id);
        user.setName(name);

        String jwt = jwtProvider.generateAccessToken(user);
        String refreshToken = jwtProvider.generateRefreshToken(user);

        // refreshToken 데이터베이스에 저장
//        tokenService.saveRefreshToken(user.getEmail(), refreshToken);

        // 이메일로 사용자 찾기
        User existUser = userRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다. - " + id));

        // 닉네임을 입력한 사용자인지 확인
        boolean existNickName = existUser.getNickName() != null && !existUser.getNickName().isEmpty();

        return new NaverLoginResponse(jwt, refreshToken, existNickName);
      }
    } catch (Exception e) {
      System.out.println("네이버 accessToken 검증 실패");
    }
    return new NaverLoginResponse(null, null, false);
  }

  // 사용자가 입력한 이름과 이메일로 아이디 찾기 메서드
  public FindIdResponse findId(String name, String email) {
    User user = userRepository.findByNameAndEmail(name, email).orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다. - " + name));
    System.out.println("user" + user);
    System.out.println("userId: " + user.getId());
    return new FindIdResponse(user.getId());
  }

  // 사용자가 입력한 이름과 아이디, 이메일과 일치하는 사용자 찾기 메서드
  public FindPasswordResponse findUserForFindPassword(String name, String id, String email) {
    boolean isExistUser = userRepository.existsByNameAndIdAndEmail(name, id, email);
    System.out.println("isExistUser: " + isExistUser);
    return new FindPasswordResponse(isExistUser);
  }

  // 비밀번호 변경 메서드
  public ChangePasswordResponse changePassword(ChangePasswordRequest changePasswordRequest) {
    try {
      LocalAccount localAccount = localAccountRepository.findById(changePasswordRequest.getId()).orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다. - " + changePasswordRequest.getId()));

      localAccount.setPassword(passwordEncoder.encode(changePasswordRequest.getPassword())); // 비밀번호 암호화
      localAccountRepository.save(localAccount);

      return new ChangePasswordResponse("Success");
    } catch (IllegalArgumentException e) {
      // 사용자를 찾을 수 없는 경우
      System.out.println("비밀번호 변경 실패 - 사용자 없음: " + e);
      return new ChangePasswordResponse("User not found");
    } catch (DataIntegrityViolationException e) {
      // 데이터 무결성 문제 발생 시
      System.out.println("비밀번호 변경 실패 - 데이터 무결성 위반: " + e);
      return new ChangePasswordResponse("Invalid data");
    } catch (Exception e) {
      // 기타 문제가 발생 시
      System.out.println("비밀번호 변경 실패 - 서버 오류: " + e);
      return new ChangePasswordResponse("Server error");
    }
  }
}