import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gachi_janchi/utils/qr_code_scanner.dart';
import 'package:gachi_janchi/utils/secure_storage.dart';
import 'package:gachi_janchi/utils/serverRequest.dart';
import 'package:gachi_janchi/widgets/CustomSearchAppBar.dart';
import 'package:gachi_janchi/widgets/RestaurantListTile.dart';
import 'package:http/http.dart'  as http;
import 'dart:convert';

class SearchRestaurantScreen extends StatefulWidget {
  final void Function(int)? changeTap;
  final Map<String, dynamic> data;

  const SearchRestaurantScreen({
    super.key, 
    required this.data,
    required this.changeTap
  });

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
      ServerRequest().serverRequest(({bool isFinalRequest = false}) => searchRestaurantsByKeword(isFinalRequest: isFinalRequest), context);
      // searchRestaurantsByKeword();
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
  Future<bool> searchRestaurantsByKeword({bool isFinalRequest = false})async {
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

          setState(() {
            searchRestaurants = data["restaurants"];
          });

          print("음식점 리스트 불러오기 성공");
          return true;
        } else {
          print("음식점 리스트 불러오기 실패");
          return false;
        }
      } catch (e) {
        if (isFinalRequest) {
          // 예외 처리
          print("네트워크 오류: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("네트워크 오류: ${e.toString()}"))
          );
        }
        return false;
      }
    } else {
      return false;
    }
  }

  void changeTabCustom(int index) {
    Navigator.pop(context);
    widget.changeTap?.call(index);
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
          ServerRequest().serverRequest(({bool isFinalRequest = false}) => searchRestaurantsByKeword(isFinalRequest: isFinalRequest), context);
          // searchRestaurantsByKeword();
        },
        onClearPressed: () {
          searchKeywordController.clear(); // TextField 내용 비우기
        },
        onBackPressed: () {
          Navigator.pop(context);
        },
        changeTap: changeTabCustom
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