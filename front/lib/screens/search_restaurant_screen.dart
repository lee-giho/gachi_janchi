import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gachi_janchi/utils/qr_code_scanner.dart';
import 'package:gachi_janchi/utils/secure_storage.dart';
import 'package:gachi_janchi/widgets/CustomSearchAppBar.dart';
import 'package:gachi_janchi/widgets/RestaurantListTile.dart';
import 'package:http/http.dart'  as http;
import 'dart:convert';

class SearchRestaurantScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const SearchRestaurantScreen({super.key, required this.data});

  @override
  State<SearchRestaurantScreen> createState() => _SearchRestaurantScreenState();
}

class _SearchRestaurantScreenState extends State<SearchRestaurantScreen> {

  final TextEditingController searchKeywordController = TextEditingController();
  final FocusNode searchKeywordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.data['keyword'] != null || widget.data['keyword'].isNotEmpty) {
      setState(() {
        searchKeywordController.text = widget.data['keyword'];
      });
      searchRestaurantsByKeword();
    }
  }

  @override
  void dispose() {
    super.dispose();
    searchKeywordController.dispose();
    searchKeywordFocus.dispose();
  }

  List<dynamic> searchRestaurants = [];
  String favoriteCount = "";

  // 음식점 검색 요청 함수
  Future<void> searchRestaurantsByKeword() async {
    String? accessToken = await SecureStorage.getAccessToken();
    String keyword = searchKeywordController.text.trim();
    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/restaurant/keyword?keyword=$keyword");
    final headers = {
      'Authorization': 'Bearer ${accessToken}',
      'Content-Type': 'application/json'
    };

    if (keyword.isNotEmpty) {
      try {
        final response = await http.get(
          apiAddress,
          headers: headers
        );

        if (response.statusCode == 200) {
          print("음식점 리스트 요청 완료");

          // 🔹 UTF-8로 디코딩
          final decodedData = utf8.decode(response.bodyBytes);
          final data = json.decode(decodedData);

          print("API 응답 데이터: $data");

          if (data.containsKey("restaurants")) {
            // List<dynamic> restaurants = data["restaurants"];
            // for (var restaurant in restaurants) {
            //   if (restaurant.containsKey("restaurantName")) {
            //     print("음식점 이름: ${restaurant["restaurantName"]}");
            //   } else {
            //     print("오류: 'restaurantName' 키가 없음");
            //   }
            // }
            setState(() {
              searchRestaurants = data["restaurants"];
            });
          } else {
            print("오류: 'restaurants' 키가 없음");
          }
        } else {
          print("음식점 리스트를 불러올 수 없습니다.");
        }
      } catch (e) {
        // 예외 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("네트워크 오류: ${e.toString()}"))
        );
      }
    }
  }

  void qrScanData() async {
    // QrCodeScanner 화면으로 이동
    // QR코드 스캔한 결과를 value로 받아서 사용

    // 실제 핸드폰으로 qr코드를 찍을 수 있을 때 사용
    Navigator.of(context)
      .push(MaterialPageRoute(
        builder: (context) => const QrCodeScanner(),
        settings: RouteSettings(name: 'qr_scan')))
      .then((value) {
        print('QR value: ${value}');
        getRestaurant(value);
      }
    );

    // 임시로 음식점 아이디를 통해 정보를 가져오는 것
    // getRestaurant("67c9e0b479b5e9cfd182e150");
  }

  // 음식점 아이디로 재료 요청하는 함수
  Future<void> getRestaurant(String restaurantId) async {

    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/restaurant/ingredientId?restaurantId=$restaurantId");
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
        print("방문 음식점에 대한 재료 아이디 요청 완료");
        
        final decodedData = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedData);
        final ingredientId = data["ingredientId"];
        print("ingredientId: $ingredientId");

        addVisitedRestaurant(restaurantId, ingredientId);

      } else {
        print("방문 음식점에 대한 재료 아이디를 불러올 수 없습니다.");
      }
    } catch (e) {
      // 예외 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("네트워크 오류: ${e.toString()}"))
      );
    }
  }

  // 방문한 음식점 저장하는 함수
  Future<void> addVisitedRestaurant(String restaurantId, int ingredientId) async {
    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/user/visited-restaurant");
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json'
    };

    try {
      print("방문한 음식점 저장 요청 보내기 시작");
      final response = await http.post(
        apiAddress,
        headers: headers,
        body: json.encode({
          "restaurantId": restaurantId,
          "ingredientId": ingredientId
        })
      );

      if (response.statusCode == 200) {
        print("방문 음식점 저장 요청 완료");
        
        final decodedData = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedData);

        print("result: $data");


      } else {
        print("방문 음식점 저장 요청 실패");
      }
    } catch (e) {
      // 예외 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("네트워크 오류: ${e.toString()}"))
      );
    }
  }

  // 즐겨찾기 수 요청하는 함수
  Future<void> getFavoriteCount(String restaurantId) async {
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
        setState(() {
          favoriteCount = data["favoriteCount"];
        });
      } else {
        print("즐겨찾기 수 요청 실패");
      }
    } catch (e) {
      print("네트워크 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomSearchAppBar(
        searchController: searchKeywordController,
        searchFocusNode: searchKeywordFocus,
        onSearchPressed: () {
          print("${searchKeywordController.text} 검색!!!");
          // 검색 함수 실행
          searchRestaurantsByKeword();
        },
        onClearPressed: () {
          searchKeywordController.clear(); // TextField 내용 비우기
        },
        onQrPressed: () {
          qrScanData();
        },
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Text("검색 결과"),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // SliverToBoxAdapter(
                  //   child: Center(
                  //     child: Container(
                  //       decoration: const BoxDecoration(
                  //         color: Colors.black,
                  //         borderRadius: BorderRadius.all(Radius.circular(10))
                  //       ),
                  //       height: 4,
                  //       width: 80,
                  //       margin: const EdgeInsets.symmetric(vertical: 5),
                  //     ),
                  //   ),
                  // ),
                  SliverList.builder(
                    itemCount: searchRestaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = searchRestaurants[index];

                      return RestaurantListTile(
                        restaurant: restaurant,
                        onPressed: () {
                          print("클릭한 음식점: ${restaurant["restaurantName"]}");
                        },
                        // onBookmarkPressed: () {
                        //   print("${restaurant["restaurantName"]} 즐겨찾기 클릭!!");
                        // },
                      );
                    }
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}