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
  Set<NMarker> markers = {}; // 🔹 마커를 저장할 Set 선언
  NLatLng? currentPosition;

  List<dynamic> restaurants = [];
  List<dynamic> searchRestaurants = [];

  DraggableScrollableController sheetController = DraggableScrollableController();

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

    // 현재 지도 화면의 경계 가져오기
    NLatLngBounds bounds = await mapController!.getContentBounds();

    double latMin = bounds.southWest.latitude;
    double latMax = bounds.northEast.latitude;
    double lonMin = bounds.southWest.longitude;
    double lonMax = bounds.northEast.longitude;

    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/restaurant/bounds?latMin=$latMin&latMax=$latMax&lonMin=$lonMin&lonMax=$lonMax");
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

        print("API 응답 데이터: ${data}");

        // 🔹 리스트만 전달하도록 수정
        if (data.containsKey("restaurants")) {
          updateMarkers(data["restaurants"]);
          setState(() {
            restaurants = data["restaurants"];
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
    List<dynamic> restaurants = data["restaurants"];
    for (var restaurant in restaurants) {
      if (restaurant.containsKey("restaurantName")) {
        print("음식점 이름: ${restaurant["restaurantName"]}");
      } else {
        print("오류: 'restaurantName' 키가 없음");
      }
    }
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

  // 가져온 음식점 리스트를 마커로 변환하여 지도에 추가
  void updateMarkers(List<dynamic> restaurantList) async {
    Set<NMarker> newMarkers = {};

    // 현재 지도 경계 가져오기
    NLatLngBounds bounds = await mapController!.getContentBounds();
    double latMin = bounds.southWest.latitude;
    double latMax = bounds.northEast.latitude;
    double lonMin = bounds.southWest.longitude;
    double lonMax = bounds.northEast.longitude;

    for (var restaurant in restaurantList) {
      try {
        double latitude = restaurant["location"]["latitude"];
        double longitude = restaurant["location"]["longitude"];
        String restaurantName = restaurant["restaurantName"];

        // ✅ 현재 지도 영역 내에 있는지 확인
        if (latitude >= latMin && latitude <= latMax && longitude >= lonMin && longitude <= lonMax) {
          NMarker marker = NMarker(
            id: restaurantName,
            position: NLatLng(latitude, longitude),
            caption: NOverlayCaption(text: restaurantName),
          );

          newMarkers.add(marker);
        }
      } catch (e) {
        print("마커 추가 중 오류 발생: $e");
      }
    }

    // ✅ 기존 마커 제거하고 새로운 마커 추가
    setState(() {
      // 현재 보이는 영역 내 마커만 유지
      markers.clear();
    });

    // 기존 마커 제거 후 새로운 마커 추가
    mapController?.clearOverlays();
    Set<NAddableOverlay<NOverlay<void>>> castedMarkers = newMarkers.cast<NAddableOverlay<NOverlay<void>>>();
    mapController?.addOverlayAll(castedMarkers);

    print("현재 적용된 마커 개수: ${newMarkers.length}");
  }

  String isRestaurantOpen(Map<String, dynamic> businessHours) { // 음식점이 영업중인지 확인하고 "영업중" 또는 "영업종료"를 반환하는 메서드
    // 현재 요일 가져오기
    DateTime now = DateTime.now();
    List<String> weekDays = ["월", "화", "수", "목", "금", "토", "일"];
    String today = weekDays[now.weekday - 1]; // Datetime의 요일은 1(월) ~ 7(일)

    // 현재 요일의 영업시간 가져오기
    String? todayHours = businessHours[today];

    if (todayHours == null || todayHours == "휴무일") { // 영업 시간이 없거나 "휴무일"이면 영업 종료
      return "영업종료";
    }

    // 영업시간 파싱 (ex. "11:30-21:30" -> "11:30", "21:30")
    List<String> hours = todayHours.split("-");
    if (hours.length != 2) { // 예상 형식이 아니면 영업 종료
      return "영업종료";
    }

    // 영업 시작 시간
    DateTime openTime = DateTime(now.year, now.month, now.day, int.parse(hours[0].split(":")[0]), int.parse(hours[0].split(":")[1]));
    // 영업 종료 시간
    DateTime closeTime = DateTime(now.year, now.month, now.day, int.parse(hours[1].split(":")[0]), int.parse(hours[1].split(":")[1]));

    // 현재 시간과 비교하여 영업 여부 반환
    if (now.isAfter(openTime) && now.isBefore(closeTime)) {
      return "영업중";
    } else {
      return "영업종료";
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
                              print("${searchKeywordController.text} 검색!!!");
                              searchRestaurantsByKeword();
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
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.018,
            maxChildSize: 0.85,
            minChildSize: 0.018,
            controller: sheetController,
            builder: (BuildContext context, scrollController) {
              return Container(
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  )
                ),
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Center(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          height: 4,
                          width: 80,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                        ),
                      ),
                    ),
                    SliverList.builder(
                      itemCount: restaurants.length,
                      itemBuilder: (context, index) {
                        final restaurant = restaurants[index];
                        
                        return ElevatedButton(
                          onPressed: () {
                            print(": ${restaurant}");
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(120),
                            padding: const EdgeInsets.all(10),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                            )
                          ),
                          child: Row(
                            children: [
                              Container( // 음식점 사진이 들어갈 부분
                                width: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1
                                  )
                                ),
                                child: 
                                  restaurant["imageUrl"] != null && restaurant["imageUrl"].toString().isNotEmpty
                                  ? Image(
                                      image: NetworkImage( // imageUrl이 있을 경우
                                        restaurant["imageUrl"]
                                      ),
                                      fit: BoxFit.contain,
                                    )
                                  : const SizedBox(
                                    height: 100,
                                    child: Center(
                                      child: Text(
                                        "사진 준비중",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                              ),
                              Expanded( // 음식점 사진 오른쪽에 정보가 나오는 부분
                                child: Container(
                                  height: 100,
                                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Column( // 음식점 이름, 리뷰, 영업시간 등 정보 표시되는 부분
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text( // 음식점 이름
                                              restaurant["restaurantName"],
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold
                                              ),
                                              softWrap: true,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const Row( // 리뷰 -> 추후 리뷰 작성이 생기면 실제 값으로 수정해야함
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  size: 16,
                                                  color: Colors.amberAccent,
                                                  
                                                ),
                                                Text(
                                                  "4.8 (500)",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                )
                                              ],
                                            ),
                                            Row( // 음식점 영업중인지 아닌지
                                              children: [
                                                Icon(
                                                  Icons.schedule,
                                                  size: 10,
                                                  color: isRestaurantOpen(restaurant["businessHours"]) == "영업중" 
                                                    ? Colors.green 
                                                    : Colors.red,
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  isRestaurantOpen(restaurant["businessHours"]),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: isRestaurantOpen(restaurant["businessHours"]) == "영업중" 
                                                      ? Colors.green 
                                                      : Colors.red,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ),
                              Image.asset(
                                'assets/images/material/carrot.png',
                                fit: BoxFit.contain,
                                height: 60,
                              ),
                              SizedBox(
                                width: 40,
                                height: 100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.turned_in_not,
                                        size: 30,
                                        color: Colors.black,
                                      ),
                                      onPressed: () { // 즐겨찾기 기능 추가 시 수정 필요
                                        print("${restaurant["restaurantName"]} 즐겨찾기 클릭!!");
                                      },
                                    ),
                                    const Text( // 즐겨찾기 기능 추가 시 수정 필요
                                      "500",
                                      style: TextStyle(
                                        fontSize: 12
                                      ),
                                    )
                                  ],
                                )
                              )
                            ],
                          ),
                        );
                      }
                    )
                  ],
                ),
              );
            }
          )
        ]
      ),
    );
  }
}