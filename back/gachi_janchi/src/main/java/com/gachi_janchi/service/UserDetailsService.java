package com.gachi_janchi.service;

import com.gachi_janchi.entity.User;
import com.gachi_janchi.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class UserDetailsService implements org.springframework.security.core.userdetails.UserDetailsService {

  @Autowired
  private UserRepository userRepository;

  @Override
  public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
    // 사용자의 아이디(이메일)로 데이터를 조회하여 엔티티 생성
    User user = userRepository.findByEmail(email).orElseThrow(() -> new UsernameNotFoundException("회원 정보가 일치하지 않습니다."));

    // User 엔티티를 스프링 시큐리티의 UserDetails로 변환하여 반환
    return org.springframework.security.core.userdetails.User.builder()
            .username(user.getEmail()) // 이메일
//            .password(user.getPassword()) // 암호화된 비밀번호
            .roles("USER") // 기본적인 역할 설정
            .build();

  }
}
