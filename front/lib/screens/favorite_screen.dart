import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gachi_janchi/utils/favorite_provider.dart';
import 'package:gachi_janchi/utils/qr_code_scanner.dart';
import 'package:gachi_janchi/utils/secure_storage.dart';
import 'package:gachi_janchi/widgets/RestaurantListTile.dart';
import 'package:http/http.dart'  as http;
import 'dart:convert';

class FavoriteScreen extends ConsumerStatefulWidget {
  const FavoriteScreen({super.key});

  @override
  ConsumerState<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends ConsumerState<FavoriteScreen> {

  final TextEditingController searchKeywordController = TextEditingController();
  final FocusNode searchKeywordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(favoriteProvider.notifier).fetchFavoriteRestaurants();
    });
  }

  @override
  void dispose() {
    searchKeywordController.dispose();
    searchKeywordFocus.dispose();
    super.dispose();
  }

  // List<dynamic> favoriteRestaurants = [];
  List<dynamic> searchRestaurants = [];

  // 즐겨찾기 음식점 검색 요청 함수
  Future<void> searchFavoriteRestaurantsByKeword() async {
    String keyword = searchKeywordController.text.trim();
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
    final favoriteRestaurants = ref.watch(favoriteProvider);
    print("favoriteRestaurants: ${favoriteRestaurants}");

    return Scaffold(
      body: SafeArea(
        child: Container( // 전체 화면
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          child: Column(
            children: [
              const Align( // 페이지 타이틀
                alignment: Alignment.topLeft,
                child: Text(
                  "즐겨찾기",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold
                  ),
                )
              ),
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
                                searchFavoriteRestaurantsByKeword();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.qr_code_scanner, size: 30),
                      onPressed: () {
                        qrScanData();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverList.builder(
                      itemCount: favoriteRestaurants.length,
                      itemBuilder: (context, index) {
                        final restaurant = favoriteRestaurants[index];
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
      )
    );
  }
}