import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gachi_janchi/utils/secure_storage.dart';
import 'package:gachi_janchi/widgets/ReviewTile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {

  List<dynamic> reviews = [];

  @override
  void initState() {
    super.initState();
    fetchReviews("latest");
  }

  Future<void> fetchReviews(String sortType) async {
    print("방문한 음식점 리스트 가져오기 요청");
    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/review/userId?sortType=$sortType");
    final headers = {'Authorization': 'Bearer $accessToken'};

    try {
      print("리뷰 요청 시작");
      final response = await http.get(
        apiAddress,
        headers: headers
      );

      if(response.statusCode == 200) {
        print("작성한 리뷰 리스트 불러오기 요청 성공");

        // UTF-8로 디코딩
        final decodedData = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedData);

        print("jsonResponse: $data");

        if (data.containsKey("reviews")) {
          setState(() {
            reviews = data["reviews"];
          });
        } else {
          print("오류: 'reviews' 키가 없음");
        }
      } else {
        print("작성한 리뷰 리스트 불러오기 요청 실패");
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
      appBar: AppBar(title: const Text("리뷰")),
      body: CustomScrollView(
        slivers: [
          SliverList.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return ReviewTile(
                reviewInfo: review,
                menuButton: true,
              );
            }
          )
        ],
      )
    );
  }
}