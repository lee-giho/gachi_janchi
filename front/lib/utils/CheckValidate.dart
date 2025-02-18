import 'package:flutter/material.dart';

class CheckValidate {
  String? validateName(FocusNode focusNode, String? name) {
    String pattern = r'^[^\s](\S*(\s\S+)*)?$';
    RegExp regExp = RegExp(pattern);
    if (name == null || name.isEmpty) {
      focusNode.requestFocus();
      return "이름을 입력해주세요.";
    } else if (!regExp.hasMatch(name)) {
      focusNode.requestFocus();
      return "앞/뒤 공백 없이 한 글자 이상 입력해주세요.";
    } else {
      return null;
    }
  }
  

  String? validateEmail(FocusNode focusNode, String? email) {
    String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(pattern);
    if (email == null || email.isEmpty) {
      return "이메일을 입력해주세요.";
    } else if (!regExp.hasMatch(email)) {
      return "잘못된 이메일 형식입니다.";
    } else {
      return null;
    }
  }

  String? validateId(FocusNode focusNode, String? id, bool? idValid) {
    String pattern = r'^[a-zA-Z0-9]{6,12}$';
    RegExp regExp = RegExp(pattern);
    if (id == null || id.isEmpty) {
      focusNode.requestFocus();
      return "아이디를 입력해주세요.";
    } else if (id.length < 6) {
      return "6자리 이상 입력해주세요.";
    } else if (id.length > 12) {
      return "12자리 이하로 입력해주세요.";
    } else if (!regExp.hasMatch(id)) {
      focusNode.requestFocus();
      return "영문 6글자 이상 12자 이하로 입력해주세요.";
    } else {
      if (idValid == false) {
        return "중복확인을 해주세요.";
      } else {
        return null;
      }
    }
  }

  String? validatePassword(FocusNode focusNode, String? password) {
    String pattern = r'^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[$`~!@$!%*#^?&\\(\\)\-_=+]).{8,15}$';
    RegExp regExp = RegExp(pattern);
    if (password == null || password.isEmpty) {
      return "비밀번호를 입력해주세요.";
    } else if (password.length < 8) {
      return "8자리 이상 입력해주세요.";
    } else if (password.length > 15) {
      return "15자리 이하로 입력해주세요.";
    } else if (!regExp.hasMatch(password)) {
      return "특수문자, 문자, 숫자 포함 8자 이상 15자 이하로 입력해주세요.";
    } else {
      return null;
    }
  }

  String? validateRePassword(FocusNode focusNode, String password, String? rePassword) {
    if (rePassword == null || rePassword.isEmpty) {
      return "비밀번호 확인을 입력해주세요.";
    } else if (password != rePassword) {
      return "입력한 비밀번호가 다릅니다.";
    } else {
      return null;
    }
  }
  
  String? validateCode(FocusNode focusNode, String? code) {
    String pattern = r'^\d{6}$'; // 숫자 6자리 정규식
    RegExp regExp = RegExp(pattern);

    if (code == null || code.isEmpty) {
      return "인증번호를 입력해주세요.";
    } else if (!regExp.hasMatch(code)) {
      return "6자리 숫자를 입력해주세요.";
    } else {
      return null; // 유효한 인증번호
    }
  }

  String? validateNickName(FocusNode focusNode, String? nickName, bool? nickNameValid) {
    String pattern = r'^[^\s](\S*(\s\S+)*)?$';
    RegExp regExp = RegExp(pattern);
    if (nickName == null || nickName.isEmpty) {
      focusNode.requestFocus();
      return "닉네임을 입력해주세요.";
    } else if (!regExp.hasMatch(nickName)) {
      focusNode.requestFocus();
      return "앞/뒤 공백 없이 한 글자 이상 입력해주세요.";
    } else {
      if (nickNameValid == false) {
        return "중복확인을 해주세요.";
      } else {
        return null;
      }
    }
  }
}