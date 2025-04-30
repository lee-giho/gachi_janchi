import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  // FlutterSecureStorage 인스턴스 생성
  static final storage = FlutterSecureStorage();

// 공통적인 `write` 메서드 추가
  static Future<void> writeData(String key, String value) async {
    await storage.write(key: key, value: value);
  }

  // 공통적인 `read` 메서드 추가
  static Future<String?> readData(String key) async {
    return await storage.read(key: key);
  }

  // autoLogin 상태 저장
  static Future<void> saveIsAutoLogin(bool? isAutoLogin) async {
    print("save isAutoLogin: ${isAutoLogin.toString()}");
    await storage.write(
        key: 'autoLogin', value: isAutoLogin.toString() // bool -> String 변환
        );
  }

  static Future<bool?> getIsAutoLogin() async {
    final isAutoLogin = await storage.read(key: 'autoLogin');
    // 값이 없으면 null 반환
    if (isAutoLogin == null) {
      return null;
    }
    return isAutoLogin.toLowerCase() == 'true'; // String -> bool 변환
  }

  static Future<void> saveLoginType(String type) async {
    print("login type: ${type}");
    await storage.write(key: 'loginType', value: type);
  }

  static Future<String?> getLoginType() async {
    return await storage.read(key: 'loginType');
  }

  // accessToken 저장
  static Future<void> saveAccessToken(String accessToken) async {
    await storage.write(key: 'accessToken', value: accessToken);
  }

  // accessToken 읽기
  static Future<String?> getAccessToken() async {
    return await storage.read(key: 'accessToken');
  }

  // refreshToken 저장
  static Future<void> saveRefreshToken(String refreshToken) async {
    await storage.write(key: 'refreshToken', value: refreshToken);
  }

  // refreshToken 읽기
  static Future<String?> getRefreshToken() async {
    return await storage.read(key: 'refreshToken');
  }

  // 토큰 삭제 (로그아웃 시)
  static Future<void> deleteTokens() async {
    await storage.delete(key: 'accessToken');
    await storage.delete(key: 'refreshToken');
  }
}
