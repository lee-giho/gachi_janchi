package com.gachi_janchi.service;

import com.gachi_janchi.entity.User;
import com.gachi_janchi.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class CustomUserDetailsService implements UserDetailsService {

  @Autowired
  private UserRepository userRepository;

  @Override
  public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
    // 데이터베이스에서 사용자 검색
    User user = userRepository.findByEmail(email).orElseThrow(() -> new UsernameNotFoundException("User not found with email: " + email));

    // Spring Security의 UserDetails 객체로 반환
    return org.springframework.security.core.userdetails.User
            .withUsername(user.getEmail()) // 사용자 이름 설정
            .password(user.getPassword()) // 암호화된 비밀번호 설정
            .authorities("USER") // 사용자 권한 설정
            .build();
  }
}
