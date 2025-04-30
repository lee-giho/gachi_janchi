import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gachi_janchi/utils/favorite_provider.dart';
import 'package:gachi_janchi/utils/serverRequest.dart';
import 'package:gachi_janchi/widgets/QRCodeButton.dart';
import 'package:gachi_janchi/widgets/RestaurantListTile.dart';

class FavoriteScreen extends ConsumerStatefulWidget {
  final void Function(int)? changeTab;
  const FavoriteScreen({
    super.key,
    required this.changeTab
  });

  @override
  ConsumerState<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends ConsumerState<FavoriteScreen> {

  final TextEditingController searchKeywordController = TextEditingController();
  final FocusNode searchKeywordFocus = FocusNode();

  // 검색어로 찾은 즐겨찾기 음식점 리스트
  List<dynamic> searchFavoriteRestaurants = [];
  // 검색 상태 관리
  bool isKeywordSearch = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ServerRequest().serverRequest(({bool isFinalRequest = false}) => ref.read(favoriteProvider.notifier).fetchFavoriteRestaurants(isFinalRequest: isFinalRequest), context);
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchKeywordController.dispose();
    searchKeywordFocus.dispose();
  }

  // 즐겨찾기 음식점 검색 함수
  Future<void> searchFavoriteRestaurantsByKeword() async {
    String keyword = searchKeywordController.text.trim().toLowerCase();
    final favoriteRestaurants = ref.read(favoriteProvider); // 즐겨찾기 목록 가져오기

    if (keyword.isNotEmpty) {
      setState(() {
        searchFavoriteRestaurants = favoriteRestaurants.where((restaurant) {
          // 음식점 이름 검색
          bool nameMatch = restaurant["restaurantName"].toLowerCase().contains(keyword);

          // 카테고리 검색
          bool categoryMatch = (restaurant["categories"] as List<dynamic>)
              .any((category) => category.toString().toLowerCase().contains(keyword));

          // 메뉴 검색
          bool menuMatch = (restaurant["menu"] as List<dynamic>)
              .any((menuItem) => menuItem["name"].toString().toLowerCase().contains(keyword));

          // 🔥 하나라도 검색어와 일치하면 true 반환
          return nameMatch || categoryMatch || menuMatch;
        }).toList();
      });

      isKeywordSearch = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteRestaurants = ref.watch(favoriteProvider);
    print("favoriteRestaurants: ${favoriteRestaurants}");

    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.topLeft,
          child: Text(
            "즐겨찾기",
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
                                  searchFavoriteRestaurantsByKeword();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      QRCodeButton(
                        changeTap: widget.changeTab
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
                    slivers: [
                      SliverList.builder(
                        itemCount: isKeywordSearch 
                          ? searchFavoriteRestaurants.length
                          : favoriteRestaurants.length,
                        itemBuilder: (context, index) {
                          final restaurant = isKeywordSearch 
                            ? searchFavoriteRestaurants[index]
                            : favoriteRestaurants[index];
                          return RestaurantListTile(
                            restaurant: restaurant,
                            onPressed: () {
                              print("클릭한 음식점: ${restaurant["restaurantName"]}");
                            },
                          );
                        }
                      )
                    ],
                  )
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}