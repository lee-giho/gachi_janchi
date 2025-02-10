import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    requestLocationPermission();
    super.initState();
    // FocusNode에 리스너 추가
    searchKeywordFocus.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    searchKeywordFocus.dispose();
    super.dispose();
  }

  // 위치 권한 요청
  void requestLocationPermission() async {
    await Permission.location.request();
    var status = await Permission.location.status;
    print("status: $status");
    log("status: $status");

    if(status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  var searchKeywordController = TextEditingController();
  FocusNode searchKeywordFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          NaverMap(
            options: const NaverMapViewOptions(
              initialCameraPosition: NCameraPosition( // 첫 로딩 포지션
                target: NLatLng(37.5667070936, 126.97876548263318),
                zoom: 15,
                bearing: 0,
                tilt: 0
              ),
              locationButtonEnable: true // 내 위치 찾기 위젯이 하단에 생김
            ),
            onSymbolTapped: (symbolInfo) {
              log("symbolInfo: ${symbolInfo.caption}");
            },
            onMapReady: (controller) {
              log("준비완료!");
            },
          ),
          // 검색바
          Positioned(
            top: 60,
            left: 0,
            right: 0, // Continer를 Align 위젝으로 감싸고 left와 right를 0으로 설정하면 가운데 정렬이 된다.
            child: Align(
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white
                ),
                width: 400,
                height: 50,
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/gachi_janchi_logo.png',
                      fit: BoxFit.contain,
                      height: 40,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      width: 280,
                      height: 40,
                      child: Row(
                        children: [
                          Expanded( // 검색어 입력 부분 
                            child: TextField(
                              controller: searchKeywordController,
                              focusNode: searchKeywordFocus,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                hintText: "찾고 있는 잔치집이 있나요?",
                                hintStyle: TextStyle(
                                  fontSize: 15
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  borderSide: BorderSide(color: Color.fromRGBO(121, 55, 64, 0))
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  borderSide: BorderSide(color: Color.fromRGBO(122, 11, 11, 0))
                                )
                              ),
                            ),
                          ),
                          if (searchKeywordFocus.hasFocus) 
                            IconButton( // 검색어 삭제 부분
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.clear,
                                size: 20,
                              ),
                              onPressed: () {
                                searchKeywordController.clear(); // TextField 내용 비우기
                              },
                            ),
                          IconButton( // 검색 버튼 부분
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.search,
                              size: 20,
                            ),
                            onPressed: () {

                            },
                          )
                        ],
                      ),
                    ), 
                  ],
                ),
              ),
            )
          )
        ]
      ),
    );
  }
}