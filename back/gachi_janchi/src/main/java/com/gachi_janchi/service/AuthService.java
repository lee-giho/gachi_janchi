package com.gachi_janchi.service;

import com.gachi_janchi.dto.*;
import com.gachi_janchi.entity.User;
import com.gachi_janchi.repository.RefreshTokenRepository;
import com.gachi_janchi.repository.UserRepository;
import com.gachi_janchi.util.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

  @Autowired
  private UserRepository userRepository;

  @Autowired
  private RefreshTokenRepository refreshTokenRepository;

  @Autowired
  private JwtUtil jwtUtil;

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

  // 닉네임 및 전화번호 추가 로직
  public NickNameAndPhoneNumberResponse updateAdditionalInfo(NickNameAndPhoneNumberRequest nickNameAndPhoneNumberRequest) {
    User user = userRepository.findByEmail(nickNameAndPhoneNumberRequest.getEmail()).orElseThrow(() -> new IllegalArgumentException("User not found"));

    // 닉네임과 전화번호 업데이트
    user.setNickName(nickNameAndPhoneNumberRequest.getNickName());
    user.setPhoneNumber(nickNameAndPhoneNumberRequest.getPhoneNumber());
    userRepository.save(user);

    return new NickNameAndPhoneNumberResponse("User additional info updated successfully");
  }

  public LoginResponse login(LoginRequest loginRequest) {
    User user = userRepository.findByEmail(loginRequest.getEmail()).orElseThrow(() -> new IllegalArgumentException("Invalid credentials"));

    if (!passwordEncoder.matches(loginRequest.getPassword(), user.getPassword())) {
      throw new IllegalArgumentException("Invalid credentials");
    }

    String jwt = jwtUtil.generateAccessToken(loginRequest.getEmail());
    String refreshToken = jwtUtil.generateRefreshToken(loginRequest.getEmail());

//    return jwtUtil.generateToken(loginRequest.getEmail());
    return new LoginResponse(jwt, refreshToken);
  }
}
