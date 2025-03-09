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
    if (widget.data['keyword'] != null || widget.data['keyword'].isNotEmpty) {
      setState(() {
        searchKeywordController.text = widget.data['keyword'];
      });
      searchRestaurantsByKeword();
    }
    super.initState();
  }

  @override
  void dispose() {
    searchKeywordController.dispose();
    searchKeywordFocus.dispose();
    super.dispose();
  }

  List<dynamic> searchRestaurants = [];

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

  void qrScanData() async{
    // QrCodeScanner 화면으로 이동
    // QR코드 스캔한 결과를 value로 받아서 사용
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const QrCodeScanner(),
        settings: RouteSettings(name: 'qr_scan')
      )
    )
    .then((value) {
      print('QR value: ${value}');
    });
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
                        onBookmarkPressed: () {
                          print("${restaurant["restaurantName"]} 즐겨찾기 클릭!!");
                        },
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