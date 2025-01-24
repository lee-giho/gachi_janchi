package com.gachi_janchi.service;

import com.gachi_janchi.dto.*;
import com.gachi_janchi.entity.LocalAccount;
import com.gachi_janchi.entity.SocialAccount;
import com.gachi_janchi.entity.User;
import com.gachi_janchi.repository.LocalAccountRepository;
import com.gachi_janchi.repository.SocialAccountRepository;
import com.gachi_janchi.repository.UserRepository;
import com.gachi_janchi.util.GoogleTokenVerifier;
import com.gachi_janchi.util.JwtProvider;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class AuthService {

  @Autowired
  private UserRepository userRepository;

  @Autowired
  private LocalAccountRepository localAccountRepository;

  @Autowired
  private SocialAccountRepository socialAccountRepository;

  @Autowired
  private JwtProvider jwtProvider;

  @Autowired
  private TokenService tokenService;

  @Autowired
  private PasswordEncoder passwordEncoder;

  @Autowired
  private GoogleTokenVerifier googleTokenVerifier;

  // 회원가입 로직
  public RegisterResponse register(RegisterRequest registerRequest) {
    if (userRepository.existsByEmail(registerRequest.getEmail())) {
      throw new IllegalArgumentException("Email already in use"); // 중복된 이메일 예외 처리
    }

    // 새로운 사용자 생성 및 저장 - users
    User user = new User();
    user.setEmail(registerRequest.getEmail());
    user.setName(registerRequest.getName());
    userRepository.save(user);

    // 새로운 로컬 사용자 생성 및 저장 - local_account
    LocalAccount localAccount = new LocalAccount();
    localAccount.setEmail(registerRequest.getEmail());
    localAccount.setPassword(passwordEncoder.encode(registerRequest.getPassword())); // 비밀번호 암호화
    localAccountRepository.save(localAccount);

    return new RegisterResponse("User registered successfully");
  }

  public LoginResponse login(LoginRequest loginRequest) {
    User user = userRepository.findByEmail(loginRequest.getEmail()).orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다. - " + loginRequest.getEmail()));
    LocalAccount localAccount = localAccountRepository.findByEmail(loginRequest.getEmail()).orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다. - " + loginRequest.getEmail()));

    if (!passwordEncoder.matches(loginRequest.getPassword(), localAccount.getPassword())) {
      throw new IllegalArgumentException("비밀번호가 일치하지 않습니다. - " + loginRequest.getPassword());
    }

    String jwt = jwtProvider.generateAccessToken(user);
    String refreshToken = jwtProvider.generateRefreshToken(user);

    // refreshToken 데이터베이스에 저장
    tokenService.saveRefreshToken(localAccount.getEmail(), refreshToken);

//    return jwtUtil.generateToken(loginRequest.getEmail());
    return new LoginResponse(jwt, refreshToken);
  }

  public GoogleLoginResponse googleLogin(GoogleLoginRequest googleLoginRequest) {
    try {
      // Google ID Token 검증
      Map<String, Object> tokenInfo =  googleTokenVerifier.verifyToken(googleLoginRequest.getIdToken());

      // 사용자 정보 가져오기
      String email = (String) tokenInfo.get("email");
      String name = (String) tokenInfo.get("name");

      if (email == null || name == null) {
        throw new IllegalArgumentException("유효하지 않은 사용자 정보");
      }

      // 사용자 저장 또는 업데이트 - social_account
      if (!userRepository.existsByEmail(email) && !socialAccountRepository.existsByEmail(email)) {
        User user = new User();
        user.setEmail(email);
        user.setName(name);
        userRepository.save(user);

        SocialAccount socialAccount = new SocialAccount();
        socialAccount.setEmail(email);
        socialAccount.setProvider("google");
        socialAccountRepository.save(socialAccount);

//      userRepository.save(user);
        String jwt = jwtProvider.generateAccessToken(user);
        String refreshToken = jwtProvider.generateRefreshToken(user);

        // refreshToken 데이터베이스에 저장
        tokenService.saveRefreshToken(socialAccount.getEmail(), refreshToken);

        return new GoogleLoginResponse(jwt, refreshToken);
      } else {
        System.out.println("이미 존재하는 사용자입니다.");

        User user = new User();
        user.setEmail(email);
        user.setName(name);

        String jwt = jwtProvider.generateAccessToken(user);
        String refreshToken = jwtProvider.generateRefreshToken(user);

        // refreshToken 데이터베이스에 저장
        tokenService.saveRefreshToken(user.getEmail(), refreshToken);

        return new GoogleLoginResponse(jwt, refreshToken);
      }
    } catch (Exception e) {
      System.out.println("구글 idToken 검증 실패");
      return new GoogleLoginResponse(null, null);
    }
  }
}
