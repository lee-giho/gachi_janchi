import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gachi_janchi/utils/secure_storage.dart';
import 'package:gachi_janchi/widgets/ReviewTile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RestaurantDetailReviewScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const RestaurantDetailReviewScreen({
    super.key,
    required this.data
  });

  @override
  State<RestaurantDetailReviewScreen> createState() => _RestaurantDetailReviewScreenState();
}

class _RestaurantDetailReviewScreenState extends State<RestaurantDetailReviewScreen> {

  List<dynamic> reviews = [];

  @override
  void initState() {
    super.initState();
    getReview(widget.data["restaurantId"]);
  }
  
  Future<void> getReview(String restaurantId) async {
    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/review/restaurantId?restaurantId=${restaurantId}");
    final headers = {
      'Authorization': 'Bearer ${accessToken}',
      'Content-Type': 'application/json'
    };

    try {
      final response = await http.get(
        apiAddress,
        headers: headers
      );

      if (response.statusCode == 200) {
        print("리뷰 리스트 요청 완료");

        // UTF-8로 디코딩
        final decodedData = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedData);

        print("API 응답 데이터: ${data}");

        setState(() {
          reviews = data["reviews"];
        });
      } else {
        print("리뷰 리스트 요청 실패");
      }
    } catch (e) {
      // 예외 처리
      ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("네트워크 오류: ${e.toString()}")));
    }

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverList.builder(
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return ReviewTile(
                    reviewInfo: review
                  );
                }
              )
            ],
          )
        )
      ],
    );
  }
}