package com.gachi_janchi.service;

import com.gachi_janchi.dto.*;
import com.gachi_janchi.entity.User;
import com.gachi_janchi.repository.UserRepository;
import com.gachi_janchi.util.JwtProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

  @Autowired
  private UserRepository userRepository;

  @Autowired
  private JwtProvider jwtProvider;

  @Autowired
  private TokenService tokenService;

  @Autowired
  private PasswordEncoder passwordEncoder;

  // 회원가입 로직
  public RegisterResponse register(RegisterRequest registerRequest) {
    if (userRepository.existsByEmail(registerRequest.getEmail())) {
      throw new IllegalArgumentException("Email already in use"); // 중복된 이메일 예외 처리
    }

    // 새로운 사용자 생성 및 저장
    User user = new User();
    user.setName(registerRequest.getName());
    user.setEmail(registerRequest.getEmail());
    user.setPassword(passwordEncoder.encode(registerRequest.getPassword())); // 비밀번호 암호화
    userRepository.save(user);

    return new RegisterResponse("User registered successfully");
  }

  public LoginResponse login(LoginRequest loginRequest) {
    User user = userRepository.findByEmail(loginRequest.getEmail()).orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다. - " + loginRequest.getEmail()));

    if (!passwordEncoder.matches(loginRequest.getPassword(), user.getPassword())) {
      throw new IllegalArgumentException("비밀번호가 일치하지 않습니다. - " + loginRequest.getPassword());
    }

    String jwt = jwtProvider.generateAccessToken(user);
    String refreshToken = jwtProvider.generateRefreshToken(user);

    // refreshToken 데이터베이스에 저장
    tokenService.saveRefreshToken(user.getEmail(), refreshToken);

//    return jwtUtil.generateToken(loginRequest.getEmail());
    return new LoginResponse(jwt, refreshToken);
  }
}
