import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:gachi_janchi/screens/search_restaurant_screen.dart';
import 'package:gachi_janchi/utils/qr_code_scanner.dart';
import 'package:gachi_janchi/widgets/IngredientFilterPopUp.dart';
import 'package:gachi_janchi/widgets/RestaurantListTile.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gachi_janchi/utils/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final void Function(int)? changeTap;
  const HomeScreen({
    super.key,
    this.changeTap
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var searchKeywordController = TextEditingController();
  FocusNode searchKeywordFocus = FocusNode();

  NaverMapController? mapController; // 네이버 지도 컨트롤러
  Set<NMarker> markers = {}; // 마커를 저장할 Set 선언
  String? selectedMarkerId; // 현재 클릭된 마커 ID 저장
  Map<String, NMarker> markerMap = {}; // 마커 ID를 Key로 저장
  bool isMarkerTap = false; // 마커를 클릭 상태 관리
  Map<String, dynamic> tapRestaurant = {};
  NLatLng? currentPosition;

  List<dynamic> restaurants = [];
  List<dynamic> searchRestaurants = [];
  List<dynamic> filterRestaurants = [];

  List<dynamic> selectIngredients = [];

  DraggableScrollableController sheetController =
      DraggableScrollableController();

  OverlayEntry? overlayEntry; // 오버레이 창을 위한 변수
  final LayerLink layerLink = LayerLink(); // 위젯의 위치를 추적하는 변수
  double buttonWidth = 55;
  double overlayWidth = 300;

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    // FocusNode에 리스너 추가
    searchKeywordFocus.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchKeywordController.dispose();
    searchKeywordFocus.dispose();
    sheetController.dispose();

    removeOverlay();
  }

  // 위치 권한 요청
  void requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      getCurrentLocation();
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  // 현재 위치 가져오는 함수
  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        currentPosition = NLatLng(position.latitude, position.longitude);
      });

      // 🔥 현재 위치로 지도 이동
      if (mapController != null) {
        mapController!.updateCamera(
          NCameraUpdate.withParams(
            target: currentPosition!,
            zoom: 15,
          ),
        );
      }
    } catch (e) {
      print("현재 위치를 가져오는 데 실패했습니다: $e");
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
        widget.changeTap?.call(3);
      }
    );

    // 임시로 음식점 아이디를 통해 정보를 가져오는 것
    // getRestaurant("67c9e0bb79b5e9cfd182e151");
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

  // // 음식점 리스트 요청하는 함수
  // Future<void> getRestaurantList() async {
  //   String? accessToken = await SecureStorage.getAccessToken();

  //   // .env에서 서버 URL 가져오기
  //   final apiAddress =
  //       Uri.parse("${dotenv.get("API_ADDRESS")}/api/restaurant/dong?dong=상록구");
  //   final headers = {
  //     'Authorization': 'Bearer ${accessToken}',
  //     'Content-Type': 'application/json'
  //   };

  //   try {
  //     final response = await http.get(apiAddress, headers: headers);

  //     if (response.statusCode == 200) {
  //       print("음식점 리스트 요청 완료");

  //       // 🔹 UTF-8로 디코딩
  //       final decodedData = utf8.decode(response.bodyBytes);
  //       final data = json.decode(decodedData);

  //       print("RestaurantList: ${data}");
  //     } else {
  //       print("음식점 리스트를 불러올 수 없습니다.");
  //     }
  //   } catch (e) {
  //     // 예외 처리
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text("네트워크 오류: ${e.toString()}")));
  //   }
  // }

  Future<void> fetchRestaurantsInBounds(NCameraPosition position) async {
    // 현재 지도 화면의 경계 가져오기
    NLatLngBounds bounds = await mapController!.getContentBounds();

    double latMin = bounds.southWest.latitude;
    double latMax = bounds.northEast.latitude;
    double lonMin = bounds.southWest.longitude;
    double lonMax = bounds.northEast.longitude;

    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse(
        "${dotenv.get("API_ADDRESS")}/api/restaurant/bounds?latMin=$latMin&latMax=$latMax&lonMin=$lonMin&lonMax=$lonMax");
    final headers = {
      'Authorization': 'Bearer ${accessToken}',
      'Content-Type': 'application/json'
    };

    try {
      final response = await http.get(apiAddress, headers: headers);

      if (response.statusCode == 200) {
        print("음식점 리스트 요청 완료");

        // UTF-8로 디코딩
        final decodedData = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedData);

        print("API 응답 데이터: ${data}");

        // 리스트만 저장
        if (data.containsKey("restaurants")) {
          setState(() {
            restaurants = data["restaurants"];
          });
          if (selectIngredients.isNotEmpty) { // 재료 필터가 적용됐을 때 filterRestaurants 보여주기
            print("filterRestaurants.length: $filterRestaurants.length");
            updateMarkers(filterRestaurants);
          } else {
            updateMarkers(restaurants);
          }
          
        } else {
          print("오류: 'restaurants' 키가 없음");
        }
      } else {
        print("음식점 리스트를 불러올 수 없습니다.");
      }
    } catch (e) {
      // 예외 처리
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("네트워크 오류: ${e.toString()}")));
    }
  }

  // 음식점 검색 요청 함수
  Future<void> searchRestaurantsByKeword() async {
    String? accessToken = await SecureStorage.getAccessToken();
    String keyword = searchKeywordController.text.trim();
    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse(
        "${dotenv.get("API_ADDRESS")}/api/restaurant/keyword?keyword=$keyword");
    final headers = {
      'Authorization': 'Bearer ${accessToken}',
      'Content-Type': 'application/json'
    };

    if (keyword.isNotEmpty) {
      try {
        final response = await http.get(apiAddress, headers: headers);

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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("네트워크 오류: ${e.toString()}")));
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
        String ingredient = restaurant["ingredientName"];
        print("assets/images/ingredient/$ingredient.png");

        // 현재 지도 영역 내에 있는지 확인
        if (latitude >= latMin &&
            latitude <= latMax &&
            longitude >= lonMin &&
            longitude <= lonMax) {
          NMarker marker = NMarker(
            id: restaurantName,
            position: NLatLng(latitude, longitude),
            icon: NOverlayImage.fromAssetImage(
                "assets/images/ingredient/$ingredient.png"),
            caption: NOverlayCaption(text: restaurantName),
          );

          marker.setOnTapListener((overlay) {
            setState(() {
              // 이전에 선택된 마커 크기 원래대로 되돌리기
              if (selectedMarkerId != null &&
                  markerMap.containsKey(selectedMarkerId)) {
                markerMap[selectedMarkerId]!
                    .setSize(const Size(40, 40)); // 원래 크기로 되돌리기
              }

              // 새로운 마커 크기 키우기
              marker.setSize(const Size(60, 60));

              // 현재 선택된 마커 ID 업데이트
              selectedMarkerId = marker.info.id;
              markerMap[selectedMarkerId!] = marker; // Map에 저장

              // 선택한 가게 정보 업데이트
              isMarkerTap = true;
              tapRestaurant = restaurant;
            });
            updateSheetSize(); // 바텀 시트 크기 업데이트
          });

          marker.setSize(const Size(40, 40));
          // markerMap에 마커 저장
          markerMap[restaurantName] = marker;
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
    Set<NAddableOverlay<NOverlay<void>>> castedMarkers =
        newMarkers.cast<NAddableOverlay<NOverlay<void>>>();
    mapController?.addOverlayAll(castedMarkers);

    print("현재 적용된 마커 개수: ${newMarkers.length}");
  }

  String isRestaurantOpen(Map<String, dynamic> businessHours) {
    // 음식점이 영업중인지 확인하고 "영업중" 또는 "영업종료"를 반환하는 메서드
    // 현재 요일 가져오기
    DateTime now = DateTime.now();
    List<String> weekDays = ["월", "화", "수", "목", "금", "토", "일"];
    String today = weekDays[now.weekday - 1]; // Datetime의 요일은 1(월) ~ 7(일)

    // 현재 요일의 영업시간 가져오기
    String? todayHours = businessHours[today];

    if (todayHours == null || todayHours == "휴무일") {
      // 영업 시간이 없거나 "휴무일"이면 영업 종료
      return "영업종료";
    }

    // 영업시간 파싱 (ex. "11:30-21:30" -> "11:30", "21:30")
    List<String> hours = todayHours.split("-");
    if (hours.length != 2) {
      // 예상 형식이 아니면 영업 종료
      return "영업종료";
    }

    // 영업 시작 시간
    DateTime openTime = DateTime(now.year, now.month, now.day,
        int.parse(hours[0].split(":")[0]), int.parse(hours[0].split(":")[1]));
    // 영업 종료 시간
    DateTime closeTime = DateTime(now.year, now.month, now.day,
        int.parse(hours[1].split(":")[0]), int.parse(hours[1].split(":")[1]));

    // 현재 시간과 비교하여 영업 여부 반환
    if (now.isAfter(openTime) && now.isBefore(closeTime)) {
      return "영업중";
    } else {
      return "영업종료";
    }
  }

  double sheetChildSize = 0.1; // 기본값 설정

  void updateSheetSize() {
    if (isMarkerTap) {
      setState(() {
        sheetChildSize = (tapRestaurant.length * 0.05).clamp(0.16, 0.16);
      });
    } else {
      setState(() {
        sheetChildSize = 0.018;
      });

      sheetController.animateTo(sheetChildSize,
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
    print("sheetChildSize: ${sheetChildSize}");
  }

  // 오버레이 창을 표시하는 함수
  void showOverlay(BuildContext context) {
    if (overlayEntry != null) return; // 이미 열려있으면 중복 생성 방지

    OverlayState overlayState = Overlay.of(context);
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: overlayWidth,
        child: CompositedTransformFollower(
          link: layerLink,
          offset: Offset(-overlayWidth + buttonWidth, -300), // 위치 조정
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            child: IngredientFilterPopUp(
              selected: selectIngredients,
              selectIngredient: selectIngredient,
            )
          ),
        )
      )
    );

    overlayState.insert(overlayEntry!);
  }

  // 오버레이 창 닫는 함수
  void removeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  // 오버레이 토글 함수 (클릭하면 열고, 다시 클릭하면 닫음)
  void toggleOverlay(BuildContext context) {
    if (overlayEntry == null) {
      showOverlay(context);
    } else {
      removeOverlay();
    }
  }

  void selectIngredient(String name) {
    setState(() {
      if (selectIngredients.contains(name)) {
        selectIngredients.remove(name);
      } else {
        selectIngredients.add(name);
      }  
    });
    fetchFilterRestaurants();
    print("----selectIngredients: $selectIngredients");
  }

  void fetchFilterRestaurants() {
    List<dynamic> filtered = restaurants.where((restaurant) {
      final String ingredient = restaurant["ingredientName"];
      return selectIngredients.contains(ingredient);
    }).toList();

    setState(() {
      filterRestaurants = filtered;
    });

    print("필터링된 음식점 수: ${filterRestaurants.length}");

    if (selectIngredients.isNotEmpty) {
      updateMarkers(filterRestaurants);
    } else {
      updateMarkers(restaurants);
    }
    
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        NaverMap(
            onMapReady: (controller) {
              mapController = controller; // mapController 초기화
              log("준비완료!");
              log("currentPosition: $currentPosition");
              // 현재 위치가 있으면 지도 이동
              if (currentPosition != null) {
                mapController!.updateCamera(NCameraUpdate.withParams(
                    target: currentPosition, zoom: 15));
              }
            },
            onMapTapped: (point, latLng) {
              setState(() {
                isMarkerTap = false;
                tapRestaurant = {};
              });
              print(isMarkerTap);
              updateSheetSize(); // 크기 업데이트
            },
            options: const NaverMapViewOptions(
                initialCameraPosition: NCameraPosition(
                    // 첫 로딩 포지션
                    target: NLatLng(37.5667070936, 126.97876548263318),
                    zoom: 15,
                    bearing: 0,
                    tilt: 0),
                locationButtonEnable: true // 내 위치 찾기 위젯이 하단에 생김
                ),
            onCameraChange: (reason, animated) async {
              setState(() {
                isMarkerTap = false;
                tapRestaurant = {};
              });
              print(isMarkerTap);
              updateSheetSize(); // 크기 업데이트
              print("카메라 이동");
            },
            onCameraIdle: () async {
              if (mapController != null) {
                NCameraPosition position =
                    await mapController!.getCameraPosition();
                await fetchRestaurantsInBounds(position);
                setState(() {
                  isMarkerTap = false;
                  tapRestaurant = {};
                });
                // setState(() {
                //   currentPosition = position.target;
                // });
                print(
                    "카메라 위치: ${position.target.latitude}, ${position.target.longitude}");
              } else {
                log("mapController가 초기화되지 않았습니다.");
              }
            },
            onSymbolTapped: (symbolInfo) {
              log("symbolInfo: ${symbolInfo.caption}");
            }),
        // 검색바
        Positioned(
            top: 60,
            left: 0,
            right:
                0, // Continer를 Align 위젝으로 감싸고 left와 right를 0으로 설정하면 가운데 정렬이 된다.
            child: Align(
              alignment: Alignment.center,
              child: Container(
                // 홈화면 상단에 떠있는 검색바 전체를 감싸는 Container
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white),
                width: 400,
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      // 가치, 잔치 로고
                      'assets/images/gachi_janchi_logo.png',
                      fit: BoxFit.contain,
                      height: 40,
                    ),
                    Container(
                      // 검색어 입력 TextField, 검색어 삭제 버튼, 검색 버튼 감싸는 Container
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      width: 280,
                      height: 40,
                      child: Row(
                        children: [
                          Expanded(
                            // 검색어 입력 부분
                            child: TextField(
                              controller: searchKeywordController,
                              focusNode: searchKeywordFocus,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                  hintText: "찾고 있는 잔치집이 있나요?",
                                  hintStyle: TextStyle(fontSize: 15),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 10),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      borderSide: BorderSide(
                                          color:
                                              Color.fromRGBO(121, 55, 64, 0))),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      borderSide: BorderSide(
                                          color:
                                              Color.fromRGBO(122, 11, 11, 0)))),
                            ),
                          ),
                          if (searchKeywordFocus.hasFocus)
                            IconButton(
                              // 검색어 삭제 부분
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.clear,
                                size: 20,
                              ),
                              onPressed: () {
                                searchKeywordController
                                    .clear(); // TextField 내용 비우기
                              },
                            ),
                          IconButton(
                            // 검색 버튼 부분
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.search,
                              size: 20,
                            ),
                            onPressed: () {
                              print("${searchKeywordController.text} 검색!!!");
                              // searchRestaurantsByKeword();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          SearchRestaurantScreen(data: {
                                            "keyword":
                                                searchKeywordController.text
                                          })));
                            },
                          )
                        ],
                      ),
                    ),
                    IconButton(
                      // QR코드 버튼 부분
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.qr_code_scanner,
                        size: 30,
                      ),
                      onPressed: () {
                        print("QR코드 스캐너 버튼 클릭!!!!!!");
                        qrScanData();
                      },
                    )
                  ],
                ),
              ),
            )),
        Positioned(
          bottom: 25,
          right: 10, // Continer를 Align 위젝으로 감싸고 left와 right를 0으로 설정하면 가운데 정렬이 된다.
          child: CompositedTransformTarget(
            link: layerLink,
            child: InkWell(
              onTap: () {
                print("aaa");
                toggleOverlay(context);
              },
              child: Container(
                width: buttonWidth,
                height: 55,
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white
                  ),
                child: Icon(
                  Icons.shopping_cart,
                  size: 30,
                ),
              ),
            ),
          )
        ),
        // if (tapRestaurant.isNotEmpty)
        //   Positioned(
        //     bottom: 100,
        //     child: Container(
        //       decoration: const BoxDecoration(
        //         color: Colors.white,
        //       ),
        //       width: MediaQuery.of(context).size.width,
        //       child: RestaurantListTile(restaurant: tapRestaurant)
        //     )
        //   ),
        isMarkerTap
            ? DraggableScrollableSheet(
                initialChildSize: sheetChildSize, // 동적으로 크기 조정
                minChildSize: sheetChildSize,
                maxChildSize: sheetChildSize, // 최대 크기 제한
                controller: sheetController,
                builder: (BuildContext context, scrollController) {
                  return Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        )),
                    child: CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        SliverToBoxAdapter(
                          child: Center(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              height: 4,
                              width: 80,
                              margin: const EdgeInsets.symmetric(vertical: 5),
                            ),
                          ),
                        ),
                        SliverList.builder(
                            itemCount: 1,
                            itemBuilder: (context, index) {
                              final restaurant = tapRestaurant;

                              return RestaurantListTile(
                                restaurant: restaurant,
                                // onPressed: () {
                                //   print("클릭한 음식점: ${restaurant["restaurantName"]}");
                                // },
                                // onBookmarkPressed: () {
                                //   print("${restaurant["restaurantName"]} 즐겨찾기 클릭!!");
                                // },
                              );
                            })
                      ],
                    ),
                  );
                })
            : DraggableScrollableSheet(
                initialChildSize: sheetChildSize,
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
                        )),
                    child: CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        SliverToBoxAdapter(
                          child: Center(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
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

                              return RestaurantListTile(
                                restaurant: restaurant,
                                // onPressed: () {
                                //   print("클릭한 음식점: ${restaurant["restaurantName"]}");
                                // },
                                // onBookmarkPressed: () {
                                //   print("${restaurant["restaurantName"]} 즐겨찾기 클릭!!");
                                // },
                              );
                            })
                      ],
                    ),
                  );
                })
      ]),
    );
  }
}
