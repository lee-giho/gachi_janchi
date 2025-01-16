import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  // FlutterSecureStorage 인스턴스 생성
  static final storage = FlutterSecureStorage();

  // accessToken 저장
  static Future<void> saveAccessToken(String accessToken) async {
    await storage.write(
      key: 'accessToken',
      value: accessToken
    );
  }

  // refreshToken 저장
  static Future<void> saveRefreshToken(String refreshToken) async {
    await storage.write(
      key: 'refreshToken',
      value: refreshToken
    );
  }

  // accessToken 읽기
  static Future<String?> getAccessToken() async {
    return await storage.read(key: 'accessToken');
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