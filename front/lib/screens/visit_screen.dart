import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gachi_janchi/utils/secure_storage.dart';
import 'package:gachi_janchi/widgets/QRCodeButton.dart';
import 'package:gachi_janchi/widgets/VisitedRestaurantTile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VisitScreen extends StatefulWidget {
  const VisitScreen({super.key});

  @override
  State<VisitScreen> createState() => _VisitScreenState();
}

class _VisitScreenState extends State<VisitScreen> {

  final TextEditingController searchKeywordController = TextEditingController();
  final FocusNode searchKeywordFocus = FocusNode();
  // 검색 상태 관리
  bool isKeywordSearch = false;

  List<dynamic> visitedRestaurants = [];
  List<dynamic> searchVisitedRestaurants = [];

  @override
  void initState() {
    super.initState();
    fetchVisitedRestaurants("latest");
  }

  @override
  void dispose() {
    super.dispose();
    searchKeywordController.dispose();
    searchKeywordFocus.dispose();
  }

  // 서버에서 방문한 음식점 리스트 가져오는 함수
  Future<void> fetchVisitedRestaurants(String sortType) async {
    print("방문한 음식점 리스트 가져오기 요청");
    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/user/visited-restaurants?sortType=$sortType");
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

  // 방문한 음식점 검색 함수
  Future<void> searchVisitedRestaurantsByKeyword() async {
    String keyword = searchKeywordController.text.trim().toLowerCase();

    if (keyword.isNotEmpty) {
      setState(() {
        searchVisitedRestaurants = visitedRestaurants.where((restaurant) {
          final res = restaurant["restaurant"]; // 내부에 restaurant 객체가 들어있음

          String name = (res["restaurantName"] ?? "").toString().toLowerCase();
          String category = (res["category"] ?? "").toString().toLowerCase();
          String menu = (res["menu"] ?? "").toString().toLowerCase();

          return name.contains(keyword) || category.contains(keyword) || menu.contains(keyword);
        }).toList();
      });

      isKeywordSearch = true;
    }
  }

  void refreshScreen(int index) {
    fetchVisitedRestaurants("latest");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.topLeft,
          child: Text(
            "방문내역",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            searchKeywordFocus.unfocus();
          },
          child: Container( // 전체 화면
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Column(
              children: [
                Container( // 검색바
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  // decoration: const BoxDecoration(
                  //   color: Colors.white,
                  //   border: Border(bottom: BorderSide(color: Colors.black26)),
                  // ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset( // 가치, 잔치 로고
                        'assets/images/gachi_janchi_logo.png',
                        fit: BoxFit.contain,
                        height: 40,
                      ),
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: searchKeywordController,
                                  focusNode: searchKeywordFocus,
                                  keyboardType: TextInputType.text,
                                  decoration: const InputDecoration(
                                    hintText: "찾고 있는 잔치집이 있나요?",
                                    hintStyle: TextStyle(fontSize: 15),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              if (searchKeywordFocus.hasFocus)
                                IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  onPressed: () {
                                    searchKeywordController.clear();
                                  },
                                ),
                              IconButton(
                                icon: const Icon(Icons.search, size: 20),
                                onPressed: () {
                                  print("${searchKeywordController.text} 검색!!!");
                                  // 검색 함수 실행
                                  searchVisitedRestaurantsByKeyword();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      QRCodeButton(
                        changeTap: refreshScreen
                      )
                    ],
                  ),
                ),
                if (isKeywordSearch) // 검색했을 경우만 나오는 초기화 버튼
                  ElevatedButton( // 검색 초기화 버튼
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromRGBO(122, 11, 11, 1),
                      side: const BorderSide(
                        width: 0.5,
                        color: Colors.black
                      )
                    ),
                    onPressed: () {
                      print("초기화 버튼 클릭!!!");
                      searchKeywordController.clear();
                      setState(() {
                        isKeywordSearch = false;
                      });
                    },
                    child: const Text(
                      "초기화",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    )
                  ),
                Expanded(
                  child: CustomScrollView(
                    slivers:[
                      SliverList.builder(
                        itemCount: isKeywordSearch
                          ? searchVisitedRestaurants.length
                          : visitedRestaurants.length,
                        itemBuilder: (context, index) {
                          final visitedRestaurant = isKeywordSearch
                            ? searchVisitedRestaurants[index]
                            : visitedRestaurants[index];
                          return VisitedRestaurantTile(
                            visitedRestaurant: visitedRestaurant,
                            onReviewCompleted: () {
                              fetchVisitedRestaurants("latest");
                            },
                          );
                        },
                      ),
                    ] 
                  ),
                )
              ],
            ),
          ),
        )
      )
    );
  }
}