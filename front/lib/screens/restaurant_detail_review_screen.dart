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
  List<int> ratings = [];
  Map<int, int> ratingCounts = {
    1: 0,
    2: 0,
    3: 0,
    4: 0,
    5: 0
  };

  @override
  void initState() {
    super.initState();
    getReview(widget.data["restaurantId"], "latest");
  }
  
  Future<void> getReview(String restaurantId, String sortType) async {
    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/review/restaurantId?restaurantId=${restaurantId}&sortType=${sortType}");
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
          
          // 값 초기화
          ratings = [];
          ratingCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

          for (var review in reviews) {
            int? rating = review["review"]["rating"];
            if (rating != null) {
              ratings.add(rating);
              ratingCounts[rating] = ratingCounts[rating]! + 1;
            }
          }
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

  String calculateAvgStarRating(List<int> ratings) {
    if (ratings.isEmpty) {
      return "0.0";
    } else {
      int sum = ratings.reduce((a, b) => a + b);
      double avg = sum / ratings.length;
      return avg.toStringAsFixed(1); // 소수점 1자리
    }
  }

  Widget buildRatingDistribution() {
    int total = ratings.length;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(5, (index) {
          int star = 5 - index;
          int count = ratingCounts[star] ?? 0;
          double ratio = total > 0 ? count / total : 0;
      
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Text(
                    "$star.0",
                    style: const TextStyle(
                      fontSize: 14
                    ),
                  ),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: ratio,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color.fromRGBO(122, 11, 11, 1),
                    ),
                    minHeight: 8,
                  )
                ),
                const SizedBox(width: 8),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black
                  ),
                )
              ],
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container( // 리뷰 현황
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: Colors.grey
                )
              )
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column( // 평균 별점
                    children: [
                      Row( // 평균
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.yellow,
                            size: 40,
                          ),
                          Text( // 평균값
                            calculateAvgStarRating(ratings),
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 5),
                      Text( // 총 리뷰 수
                        "${ratings.length.toString()}개의 평점",
                        style: TextStyle(
                          color: Colors.grey[800]
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: buildRatingDistribution()
                ),
              ],
            ),
          ),
        ),
        SliverList.builder(
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            return ReviewTile(
              reviewInfo: review,
              menuButton: false,
            );
          }
        )
      ],
    );
  }
}