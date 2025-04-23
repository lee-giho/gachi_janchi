import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gachi_janchi/utils/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Provider 정의 (StateNotifierProvider 사용)
final favoriteProvider = StateNotifierProvider<FavoriteNotifier, List<Map<String, dynamic>>>((ref) {
  return FavoriteNotifier();
});

class FavoriteNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  FavoriteNotifier() : super([]) {
    fetchFavoriteRestaurants();
  }

  // 서버에서 즐겨찾기 음식점 가져오기
  Future<bool> fetchFavoriteRestaurants({bool isFinalRequest = false}) async {
    print("음식점 리스트 가져오기 요청");
    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/user/favorite-restaurants");
    final headers = {'Authorization': 'Bearer $accessToken'};

    try {
      print("즐겨찾기 리스트 불러오기 요청 시작");
      print(accessToken);
      final response = await http.get(
        apiAddress,
        headers: headers
      );

      print(response.body);

      if (response.statusCode == 200) {
        print("즐겨찾기 리스트 불러오기 성공");
        
        // JSON을 Map<String, dynamic>으로 변환
        final Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));

        final List<dynamic> restaurantList = jsonResponse["restaurants"];

        // 상태를 <Map<String, dynamic>>으로 저장
        state = List<Map<String, dynamic>>.from(restaurantList);

        return true;
      } else {
        print("즐겨찾기 리스트 불러오기 실패");
        return false;
      }
    } catch (e) {
      if (isFinalRequest) {
        print("네트워크 오류: $e");
      }
      return false;
    }
  }

  // 즐겨찾기 추가/삭제
  Future<bool> toggleFavoriteRestaurant(Map<String, dynamic> restaurant, {bool isFinalRequest = false}) async {
    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/user/favorite-restaurant");
    final postHeaders = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json'
    };
    final deleteHeaders = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json'
    };

    try {
      print("음식점 즐겨찾기 추가/삭제 요청 보내기 시작");
      final response = await (state.any((r) => r["id"] == restaurant["id"])
        ? http.delete(
            apiAddress,
            headers: deleteHeaders,
            body: json.encode({
              "restaurantId": restaurant["id"]
            })
          )
        : http.post(
            apiAddress,
            headers: postHeaders,
            body: json.encode({
            "restaurantId": restaurant["id"]
          })
        )
      );

      if(response.statusCode == 200) {
        print("음식점 즐겨찾기 추가/삭제 요청 성공");
        state = state.any((r) => r["id"] == restaurant["id"])
          ? state.where((r) => r["id"] != restaurant["id"]).toList() // 특정 요소 제거
          : [...state, restaurant]; // 새로운 요소 추가

        return true;
      } else {
        print("음식점 즐겨찾기 추가/삭제 요청 실패");
        return false;
      }
    } catch (e) {
      if (isFinalRequest) {
        print("네트워크 오류: $e");
      }
      return false;
    }
  }

  // 음식점 즐겨찾기 리스트 state 초기화 -> 로그아웃 시 실행
  void resetFavoriteRestaurants() {
    print("음식점 즐겨찾기 리스트 초기화");
    state = [];
  }

  // 즐겨찾기 수 요청하는 함수
  Future<String> getFavoriteCount(String restaurantId, {bool isFinalRequest = false}) async {
    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/restaurant/count?restaurantId=$restaurantId");
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json'
    };

    try {
      print("즐겨찾기 수 요청 보내기 시작");
      final response = await http.get(
        apiAddress,
        headers: headers
      );

      if (response.statusCode == 200) {
        print("즐겨찾기 수 요청 완료");

        final decodedData = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedData);
        return data["favoriteCount"];
      } else {
        print("즐겨찾기 수 요청 실패");
        return "";
      }
    } catch (e) {
      if (isFinalRequest) {
        print("네트워크 오류: $e");
      }
      return "";
    }
  }
}