package com.gachi_janchi.service;

import com.gachi_janchi.dto.CheckVerificationCodeRequest;
import com.gachi_janchi.dto.CheckVerificationCodeResponse;
import com.gachi_janchi.dto.SendVerificationCodeRequest;
import com.gachi_janchi.dto.SendVerificationCodeResponse;
import com.gachi_janchi.exception.CustomException;
import com.gachi_janchi.exception.ErrorCode;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.thymeleaf.context.Context;
import org.thymeleaf.spring6.SpringTemplateEngine;

@Service
public class EmailService {

  @Autowired
  private JavaMailSender javaMailSender;

  @Autowired
  private SpringTemplateEngine templateEngine;

  @Value("${GOOGLE_MAIL_PASSWORD}")
  private String googleMailPassword;

  // 이메일 전송 메서드
  public SendVerificationCodeResponse sendVerificationEmail(SendVerificationCodeRequest sendVerificationCodeRequest, HttpServletRequest request) {
    try {
      // HttpSession session = null;
      // try {
      //   session = request.getSession(true);
      // } catch (Exception e) {
      //   System.out.println("세션 생성 중 오류가 발생했습니다.");
      // }
      HttpSession session = request.getSession(true);
      MimeMessage mimeMessage = javaMailSender.createMimeMessage();
      MimeMessageHelper mimeMessageHelper = new MimeMessageHelper(mimeMessage, false, "UTF-8");

      String recipient = sendVerificationCodeRequest.getEmail();
      String type = sendVerificationCodeRequest.getType();
      String verificationCode = generateVerificationCode();

      mimeMessageHelper.setTo(recipient); // 수신자 설정
      mimeMessageHelper.setSubject(getSubjectByType(type)); // 이메일 제목 생성
      mimeMessageHelper.setText(buildEmailContent(verificationCode, type), true); // 이메일 내용, HTML 형식으로 설정

      // 이메일 발송
      javaMailSender.send(mimeMessage);

      // 세션에 인증번호 저장
      boolean isSaveCode = saveCodeToSession(verificationCode, 3, session);

      // if (isSaveCode) {
      //   return new SendVerificationCodeResponse("인증번호가 이메일로 전송되었습니다.", session.getId());
      // } else {
      //   return new SendVerificationCodeResponse("인증번호 전송에 실패했습니다.", null);
      // }
      if (!isSaveCode) {
        throw new CustomException(ErrorCode.EMAIL_SEND_FAILED);
      }

      return new SendVerificationCodeResponse("인증번호가 이메일로 전송되었습니다.", session.getId());
    } catch (MessagingException messagingException) {
      System.out.println("인증번호 전송 중 오류가 발생했습니다.");
      // return new SendVerificationCodeResponse("인증번호 전송 중 오류가 발생했습니다.", null);
      throw new CustomException(ErrorCode.EMAIL_SEND_FAILED, "이메일 전송 실패: " + messagingException.getMessage());
    } catch (Exception e) {
      throw new CustomException(ErrorCode.INTERNAL_SERVER_ERROR, "예기치 않은 오류: " + e.getMessage());
    }
  }

  // 인증번호 확인 메서드
  public CheckVerificationCodeResponse checkVerificationCode(CheckVerificationCodeRequest checkVerificationCodeRequest, HttpServletRequest request, String sessionId) {
    // try {
    //   HttpSession session = null;
    //   try {
    //     session = request.getSession(false);
    //   } catch (Exception e) {
    //     System.out.println("세션 생성 중 오류가 발생했습니다.");
    //   }

    //   if(session != null && sessionId.equals(session.getId())) {
    //     String sessionCode = (String) session.getAttribute("verificationCode");
    //     String userCode = checkVerificationCodeRequest.getVerificationCode();

    //     if (sessionCode != null && sessionCode.equals(userCode)) {
    //       session.removeAttribute("verificationCode");
    //       return new CheckVerificationCodeResponse("인증번호가 일치합니다.");
    //     } else {
    //       return new CheckVerificationCodeResponse("인증번호가 일치하지 않습니다.");
    //     }
    //   } else {
    //     return new CheckVerificationCodeResponse("세션이 유효하지 않습니다.");
    //   }

    // } catch (Exception e) {
    //   System.out.println("세션의 인증번호를 확인하는 중 오류가 발생했습니다.");
    //   return new CheckVerificationCodeResponse("세션의 인증번호를 확인하는 중 오류가 발생했습니다.");
    // }
    HttpSession session = request.getSession(false);
    if (session == null || !sessionId.equals(session.getId())) {
      throw new CustomException(ErrorCode.INVALID_SESSION);
    }

    String sessionCode = (String) session.getAttribute("verificationCode");
    String userCode = checkVerificationCodeRequest.getVerificationCode();

    if (sessionCode == null) {
      throw new CustomException(ErrorCode.VERIFICATION_CODE_MISMATCH, "저장된 인증번호가 없습니다.");
    }

    if (!sessionCode.equals(userCode)) {
      System.out.println("다름");
      throw new CustomException(ErrorCode.VERIFICATION_CODE_MISMATCH);
    }

    session.removeAttribute("verificationCode");
    return new CheckVerificationCodeResponse("인증번호가 일치합니다.");
  }

  // 인증 코드에 맞는 제목 반환
  private String getSubjectByType(String type) {
    switch (type) {
      case "password":
        return "[가치, 잔치] 비밀번호 찾기 인증번호";
      case "id":
        return "[가치, 잔치] 아이디 찾기 인증번호";
      default:
        return "인증번호";
    }
  }

  // 이메일 내용 구성 (HTML)
  private String buildEmailContent(String code, String type) {
    Context context = new Context();
    context.setVariable("code", code); // 인증번호 저장
    return templateEngine.process(getTemplateName(type), context); // 적합한 템플릿을 반환
  }

  // 이메일 인증에 맞는 템플릿 이름 반환
  private String getTemplateName(String type) {
    switch (type) {
      case "password":
        return "sendCode_findPassword"; // 비밀번호 찾기 템플릿
      case "id":
        return "sendCode_findId"; // 아이디 찾기 템플릿
      default:
        return "sendCode_default"; // 기본 템플릿
    }
  }

  // 6자리 인증번호를 생성하는 메서드
  private String generateVerificationCode() {
    return String.format("%06d", (int)(Math.random() * 900000) + 100000); // 1000 ~ 9999 사이의 6자리 인증번호 생성
  }

  // 인증번호를 세션에 저장하는 메서드
  private boolean saveCodeToSession(String verificationCode, int expirationTime, HttpSession session) {
    try {
      session.setAttribute("verificationCode", verificationCode);
      session.setMaxInactiveInterval(expirationTime * 60); // 3분

      return true;
    } catch (Exception e) {
      System.out.println("세션에 인증번호를 저장하는 중 오류가 발생했습니다.");
      return false;
    }
  }
}
