import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:gachi_janchi/utils/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gachi_janchi/utils/secure_storage.dart';
import 'package:http/http.dart'  as http;
import 'dart:convert';

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
  
  var searchKeywordController = TextEditingController();
  FocusNode searchKeywordFocus = FocusNode();

  NaverMapController? mapController;
  NLatLng? currentPosition;

  List<dynamic> restaurants = [];

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

  // 음식점 리스트 요청하는 함수
  Future<void> getRestaurantList() async {

    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/restaurant/dong?dong=상록구");
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
        print("음식점 리스트 요청 완료");

        // 🔹 UTF-8로 디코딩
        final decodedData = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedData);

        print("RestaurantList: ${data}");
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

  Future<void> fetchRestaurantsInBounds(NCameraPosition position) async {

    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/restaurant/bounds?latitude=${position.target.latitude}&longitude=${position.target.longitude}&zoom=${position.zoom}");
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
        print("음식점 리스트 요청 완료");

        // 🔹 UTF-8로 디코딩
        final decodedData = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedData);

        print("RestaurantList: ${data}");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          NaverMap(
            onMapReady: (controller) {
              mapController = controller; // mapController 초기화
              log("준비완료!");
            },
            options: const NaverMapViewOptions(
              initialCameraPosition: NCameraPosition( // 첫 로딩 포지션
                target: NLatLng(37.5667070936, 126.97876548263318),
                zoom: 15,
                bearing: 0,
                tilt: 0
              ),
              locationButtonEnable: true // 내 위치 찾기 위젯이 하단에 생김
            ),
            onCameraChange: (reason, animated) async {
              print("카메라 이동");
            },
            onCameraIdle: () async {
              if (mapController != null) {
                NCameraPosition position = await mapController!.getCameraPosition();
                await fetchRestaurantsInBounds(position);
                // setState(() {
                //   currentPosition = position.target;
                // });
                print("카메라 위치: ${position.target.latitude}, ${position.target.longitude}");
              } else {
                log("mapController가 초기화되지 않았습니다.");
              }
            },
            onSymbolTapped: (symbolInfo) {
              log("symbolInfo: ${symbolInfo.caption}");
            }
          ),
          // 검색바
          Positioned(
            top: 60,
            left: 0,
            right: 0, // Continer를 Align 위젝으로 감싸고 left와 right를 0으로 설정하면 가운데 정렬이 된다.
            child: Align(
              alignment: Alignment.center,
              child: Container( // 홈화면 상단에 떠있는 검색바 전체를 감싸는 Container
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white
                ),
                width: 400,
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset( // 가치, 잔치 로고
                      'assets/images/gachi_janchi_logo.png',
                      fit: BoxFit.contain,
                      height: 40,
                    ),
                    Container( // 검색어 입력 TextField, 검색어 삭제 버튼, 검색 버튼 감싸는 Container
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
                              print("검색 버튼 클릭!!!!!!");
                            },
                          )
                        ],
                      ),
                    ), 
                    IconButton( // QR코드 버튼 부분
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.qr_code_scanner,
                        size: 30,
                      ),
                      onPressed: () {
                        print("QR코드 스캐너 버튼 클릭!!!!!!");
                        // qrScanData();
                        getRestaurantList();
                      },
                    )
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