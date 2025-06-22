import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gachi_janchi/utils/secure_storage.dart';
import 'package:gachi_janchi/utils/serverRequest.dart';
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
  List<dynamic> showReviews = [];
  Map<dynamic, dynamic> ratingStatus = {
    "avg": 0.0,
    "totalCount": 0,
    1: 0,
    2: 0,
    3: 0,
    4: 0,
    5: 0
  };
  bool isOnlyImage = false;
  int currentPage = 0;
  int pageSize = 10;
  bool hasMore = true;

  final TextEditingController reviewTypeController = TextEditingController();
  List<String> reviewSortTypeList = ["최신순", "오래된 순", "높은 별점 순", "낮은 별점 순"];
  Map<String, String> sortTypeMap = {
    "최신순": "latest",
    "오래된 순": "earliest",
    "높은 별점 순": "highRating",
    "낮은 별점 순": "lowRating"
  };
  String selectedReviewSortType = "최신순";

  ScrollController scrollController = ScrollController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    ServerRequest().serverRequest(({bool isFinalRequest = false}) => fetchReviewRatingStatus(widget.data["restaurantId"]), context);
    fetchReviews();
    reviewTypeController.text = selectedReviewSortType;
    scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 100 && !isLoading && hasMore) {
      fetchReviews();
    }
  }

  Future<bool> fetchReviewRatingStatus(String restaurantId, {bool isFinalRequest = false}) async {
    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/review/ratingStatus?restaurantId=$restaurantId");
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
        // UTF-8로 디코딩
        final decodedData = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedData);

        log("API 응답 데이터: ${data}");
        
        int sumForAvg = 0;

        for (int i = 1; i <= 5; i++) {
          final key = 'rating_$i';
          if (data.containsKey(key)) {
            int count = data[key] ?? 0;

            ratingStatus[i] = count;
            ratingStatus["totalCount"] += count;
            sumForAvg += i * count;
          } 
        }

        if (ratingStatus["totalCount"] > 0) {
          ratingStatus["avg"] = double.parse(
            (sumForAvg / ratingStatus["totalCount"]).toStringAsFixed(1)
          );
        }

        print("ratingStatus: $ratingStatus");

        return true;
      } else {
        log("ratingStatus 가져오기 실패");
        return false;
      }
    } catch (e) {
      if (isFinalRequest) {
        // 예외 처리
        print("네트워크 오류: ${e.toString()}");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("네트워크 오류: ${e.toString()}")));
      }
      return false;
    }
  }

  Future<void> fetchReviews() async {
    log("시작");
    if (isLoading) return;
    isLoading = true;

    final success = await ServerRequest().serverRequest(({bool isFinalRequest = false}) => getReview(widget.data["restaurantId"], sortTypeMap[selectedReviewSortType]!, isOnlyImage, isFinalRequest: isFinalRequest), context);

    isLoading = false;
    log("끝");
  }

  void resetAndFetchReviews() {
    setState(() {
      currentPage = 0;
      hasMore = true;
      reviews.clear();
      showReviews.clear();
    });

    fetchReviews();
  }
  
  Future<bool> getReview(String restaurantId, String sortType, bool onlyImage, {bool isFinalRequest = false}) async {
    if (!hasMore) return false;

    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/review/restaurantId?restaurantId=$restaurantId&sortType=$sortType&onlyImage=$onlyImage&page=$currentPage&size=$pageSize");
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

        log("API 응답 데이터: ${data}");

        List<dynamic> newReviews = data["reviews"];

        setState(() {
          reviews.addAll(newReviews);
          showReviews = reviews;
          currentPage++;
          hasMore = !data["last"];
        });

        print("리뷰 리스트 요청 성공");
        return true;
      } else {
        print("리뷰 리스트 요청 실패");
        return false;
      }
    } catch (e) {
      if (isFinalRequest) {
        // 예외 처리
        print("네트워크 오류: $e");
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("네트워크 오류: ${e.toString()}")));
      }
      return false;
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
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(5, (index) {
          int star = 5 - index;
          int count = ratingStatus[star] ?? 0;
          double ratio = ratingStatus["totalCount"] > 0 ? count / ratingStatus["totalCount"] : 0;
      
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
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container( // 리뷰 현황
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
                                ratingStatus["avg"].toString(),
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 5),
                          Text( // 총 리뷰 수
                            "${ratingStatus["totalCount"].toString()}개의 평점",
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
              Container( // 필터링 버튼 부분 - 사진 리뷰만 보기
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          isOnlyImage = !isOnlyImage;
                        });
                        // ServerRequest().serverRequest(({bool isFinalRequest = false}) => getReview(widget.data["restaurantId"], sortTypeMap[selectedReviewSortType]!, isOnlyImage, isFinalRequest: isFinalRequest), context);
                        resetAndFetchReviews();
                        print("사진 리뷰만 보기 버튼 클릭!!!!");
                        print("isOnlyImage: $isOnlyImage");
                      },
                      style: TextButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.black,
                          width: 1
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)
                        ),
                        backgroundColor: isOnlyImage
                          ? const Color.fromRGBO(122, 11, 11, 1)
                          : Colors.white,
                        overlayColor: const Color.fromARGB(116, 122, 11, 11),
                      ),
                      icon: Icon(
                        Icons.image,
                        color: isOnlyImage
                        ? Colors.white
                        : Colors.black
                      ),
                      label: Text(
                        "사진 리뷰만 보기",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isOnlyImage
                            ? Colors.white
                            : Colors.black
                        ),
                      ),
                    ),
                    DropdownMenu<String>(
                      controller:reviewTypeController,
                      initialSelection: selectedReviewSortType,
                      label: const Text(
                        "정렬 방식",
                        style: TextStyle(
                          color: Color.fromARGB(255, 83, 83, 83)
                        ),
                      ),
                      onSelected: (String? value) {
                        if (value != null) {
                          setState(() {
                            selectedReviewSortType = value;
                          });
                          // ServerRequest().serverRequest(({bool isFinalRequest = false}) => getReview(widget.data["restaurantId"], sortTypeMap["$value"]!, isOnlyImage, isFinalRequest: isFinalRequest), context);
                          resetAndFetchReviews();
                        }
                      },
                      inputDecorationTheme: const InputDecorationTheme(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 12
                        ),
                        isDense: true
                      ),
                      dropdownMenuEntries: reviewSortTypeList.map((type) => DropdownMenuEntry<String>(
                        value: type,
                        label: type
                      )).toList()
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        SliverList.builder(
          itemCount: showReviews.length,
          itemBuilder: (context, index) {
            final review = showReviews[index];
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