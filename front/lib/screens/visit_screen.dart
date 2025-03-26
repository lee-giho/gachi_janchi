import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gachi_janchi/utils/secure_storage.dart';
import 'package:gachi_janchi/widgets/VisitedRestaurantTile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VisitScreen extends StatefulWidget {
  const VisitScreen({super.key});

  @override
  State<VisitScreen> createState() => _VisitScreenState();
}

class _VisitScreenState extends State<VisitScreen> {

  List<dynamic> visitedRestaurants = [];

  @override
  void initState() {
    super.initState();
    fetchVisitedRestaurants();
  }

  // 서버에서 방문한 음식점 리스트 가져오는 함수
  Future<void> fetchVisitedRestaurants() async {
    print("방문한 음식점 리스트 가져오기 요청");
    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/user/visited-restaurants");
    final headers = {'Authorization': 'Bearer $accessToken'};

    try {
      print("방문한 음식점 리스트 불러오기 요청 시작");
      final response = await http.get(
        apiAddress,
        headers: headers
      );

      if(response.statusCode == 200) {
        print("방문한 음식점 리스트 불러오기 요청 성공");

        // 🔹 UTF-8로 디코딩
        final decodedData = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedData);

        print("jsonResponse: $data");

        // 리스트만 저장
        if (data.containsKey("visitedRestaurants")) {
          setState(() {
            visitedRestaurants = data["visitedRestaurants"];
          });
        } else {
          print("오류: 'visitedRestaurants' 키가 없음");
        }
      } else {
        print("방문한 음식점 리스트 불러오기 요청 실패");
      }
    } catch (e) {
      // 예외 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("네트워크 오류: ${e.toString()}"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container( // 전체 화면
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          child: Column(
            children: [
              const Align( // 페이지 타이틀
                alignment: Alignment.topLeft,
                child: Text(
                  "방문내역",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold
                  ),
                )
              ),
              Expanded(
                child: CustomScrollView(
                  slivers:[
                    SliverList.builder(
                      itemCount: visitedRestaurants.length,
                      itemBuilder: (context, index) {
                        final visitedRestaurant = visitedRestaurants[index];
                        return VisitedRestaurantTile(
                          visitedRestaurant: visitedRestaurant
                        );
                      },
                    ),
                  ] 
                ),
              )
            ],
          ),
        )
      )
    );
  }
}