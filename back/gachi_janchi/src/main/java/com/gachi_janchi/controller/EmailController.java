package com.gachi_janchi.controller;

import com.gachi_janchi.dto.CheckVerificationCodeRequest;
import com.gachi_janchi.dto.CheckVerificationCodeResponse;
import com.gachi_janchi.dto.SendVerificationCodeRequest;
import com.gachi_janchi.dto.SendVerificationCodeResponse;
import com.gachi_janchi.service.EmailService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class EmailController {

  @Autowired
  EmailService emailService;

  @PostMapping("/email/code")
  public ResponseEntity<SendVerificationCodeResponse> sendVerificationCode(@RequestBody SendVerificationCodeRequest sendVerificationCodeRequest, HttpServletRequest request) {
    SendVerificationCodeResponse sendVerificationCodeResponse = emailService.sendVerificationEmail(sendVerificationCodeRequest, request);
    // if(sendVerificationCodeResponse.getResponseMsg().equals("인증번호가 이메일로 전송되었습니다.")) {
    //   return ResponseEntity.ok(sendVerificationCodeResponse);
    // } else {
    //   return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(sendVerificationCodeResponse);
    // }
    return ResponseEntity.ok(sendVerificationCodeResponse);
  }

  @PostMapping("/email/verify")
  public ResponseEntity<CheckVerificationCodeResponse> checkVerificationCode(@RequestHeader("sessionId") String sessionId, @RequestBody CheckVerificationCodeRequest checkVerificationCodeRequest, HttpServletRequest request) {
    CheckVerificationCodeResponse checkVerificationCodeResponse = emailService.checkVerificationCode(checkVerificationCodeRequest, request, sessionId);
    // if(checkVerificationCodeResponse.getResponseMsg().equals("인증번호가 일치합니다.")) {
    //   return ResponseEntity.ok(checkVerificationCodeResponse);
    // } else {
    //   return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(checkVerificationCodeResponse);
    // }
    return ResponseEntity.ok(checkVerificationCodeResponse);
  }
}
