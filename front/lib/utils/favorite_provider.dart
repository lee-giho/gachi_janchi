import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gachi_janchi/utils/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Provider 정의 (StateNotifierProvider 사용)
final favoriteProvider = StateNotifierProvider<FavoriteNotifier, Set<String>>((ref) {
  return FavoriteNotifier();
});

class FavoriteNotifier extends StateNotifier<Set<String>> {
  FavoriteNotifier() : super({}) {
    fetchFavoriteRestaurants();
  }

  // 서버에서 즐겨찾기 음식점 가져오기
  Future<void> fetchFavoriteRestaurants() async {
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

        // FavoriteRestaurants 키에서 List<String>을 추출
        final List<dynamic> favoriteList = jsonResponse["favoriteRestaurants"];

        state = favoriteList.map((item) =>item.toString()).toSet();
      } else {
        print("즐겨찾기 리스트 불러오기 실패");
      }
    } catch (e) {
      print("네트워크 오류: $e");
    }
  }

  // 즐겨찾기 추가/삭제
  Future<void> toggleFavoriteRestaurant(String restaurantId) async {
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
      final response = await (state.contains(restaurantId)
        ? http.delete(
            apiAddress,
            headers: deleteHeaders,
            body: json.encode({
              "restaurantId": restaurantId
            })
          )
        : http.post(
            apiAddress,
            headers: postHeaders,
            body: json.encode({
            "restaurantId": restaurantId
          })
        )
      );

      if(response.statusCode == 200) {
        print("음식점 즐겨찾기 추가/삭제 요청 성공");
        state = state.contains(restaurantId) 
          ? state.where((id) => id != restaurantId).toSet() // 특정 요소 제거
          : {...state, restaurantId}; // 새로운 요소 추가
      } else {
        print("음식점 즐겨찾기 추가/삭제 요청 실패");
      }
    } catch (e) {
      print("네트워크 오류: $e");
    }
  }

  // 음식점 즐겨찾기 리스트 state 초기화 -> 로그아웃 시 실행
  void resetFavoriteRestaurants() {
    print("음식점 즐겨찾기 리스트 초기화");
    state = {};
  }
}