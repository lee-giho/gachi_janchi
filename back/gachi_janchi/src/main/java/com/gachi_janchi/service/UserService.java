package com.gachi_janchi.service;

import com.gachi_janchi.dto.NickNameAndPhoneNumberRequest;
import com.gachi_janchi.dto.NickNameAndPhoneNumberResponse;
import com.gachi_janchi.entity.User;
import com.gachi_janchi.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class UserService {

  @Autowired
  UserRepository userRepository;

  // 닉네임 및 전화번호 추가 로직
  public NickNameAndPhoneNumberResponse updateAdditionalInfo(NickNameAndPhoneNumberRequest nickNameAndPhoneNumberRequest) {
    User user = userRepository.findByEmail(nickNameAndPhoneNumberRequest.getEmail()).orElseThrow(() -> new IllegalArgumentException("User not found"));

    // 닉네임과 전화번호 업데이트
    user.setNickName(nickNameAndPhoneNumberRequest.getNickName());
    user.setPhoneNumber(nickNameAndPhoneNumberRequest.getPhoneNumber());
    userRepository.save(user);

    return new NickNameAndPhoneNumberResponse("User additional info updated successfully");
  }
}
