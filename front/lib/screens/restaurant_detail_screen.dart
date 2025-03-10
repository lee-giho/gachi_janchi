import 'package:flutter/material.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const RestaurantDetailScreen({super.key, required this.data});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {

  Map<String, dynamic> restaurant = {};
  OverlayEntry? overlayEntry; // ✅ 오버레이 창을 위한 변수
  final LayerLink layerLink = LayerLink(); // ✅ 위젯의 위치를 추적하는 변수

  @override
  void initState() {
    if (widget.data['restaurant'] != null || widget.data['restaurant'].isNotEmpty) {
      setState(() {
        restaurant = widget.data['restaurant'];
      });
    }
    super.initState();
  }

  // 음식점 사진 dialog로 보여주는 함수
  Future<dynamic> showImageDialog(BuildContext context) {
    return showDialog(
      
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            child: restaurant["imageUrl"] != null && restaurant["imageUrl"].toString().isNotEmpty
                  ? Image.network(
                      restaurant["imageUrl"],
                      fit: BoxFit.fitWidth,
                    )
                  : Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 1)
                      ),
                      height: 200,
                      child: const Center(
                        child: Text(
                          "사진 준비중",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
          ),
        ),
      )
    );
  }

  // 음식점이 영업 중인지 확인하는 함수
  String isRestaurantOpen(Map<String, dynamic> businessHours) {
    DateTime now = DateTime.now();
    List<String> weekDays = ["월", "화", "수", "목", "금", "토", "일"];
    String today = weekDays[now.weekday - 1]; // Datetime의 요일은 1(월) ~ 7(일)

    // 현재 요일의 영업시간 가져오기
    String? todayHours = businessHours[today];

    if (todayHours == null || todayHours == "휴무일") {
      return "영업종료";
    }

    // 영업시간 파싱 (ex. "11:30-21:30" -> "11:30", "21:30")
    List<String> hours = todayHours.split("-");
    if (hours.length != 2) {
      return "영업종료";
    }

    // 영업 시작 시간
    DateTime openTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(hours[0].split(":")[0]),
      int.parse(hours[0].split(":")[1]),
    );

    // 영업 종료 시간
    DateTime closeTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(hours[1].split(":")[0]),
      int.parse(hours[1].split(":")[1]),
    );

    // 현재 시간과 비교하여 영업 여부 반환
    return (now.isAfter(openTime) && now.isBefore(closeTime)) ? "영업중" : "영업종료";
  }

  // ✅ 오버레이 창을 표시하는 함수
  void showOverlay(BuildContext context) {
    if (overlayEntry != null) return; // 이미 열려있으면 중복 생성 방지

    OverlayState overlayState = Overlay.of(context);
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 150,
        child: CompositedTransformFollower(
          link: layerLink,
          offset: const Offset(-110, 40), // 아이콘 아래 위치 조정
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: restaurant["businessHours"].entries.map<Widget>((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key, // 요일
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          entry.value, // 영업 시간
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry!);
  }

  // ✅ 오버레이 창 닫는 함수
  void removeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  // ✅ 오버레이 토글 함수 (클릭하면 열고, 다시 클릭하면 닫음)
  void toggleOverlay(BuildContext context) {
    if (overlayEntry == null) {
      showOverlay(context);
    } else {
      removeOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(restaurant['restaurantName'])
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            InkWell( // 음식점 사진
              onTap: () {
                showImageDialog(context);
              },
              child: Container(
                height: 200,
                width: double.maxFinite,
                child: restaurant["imageUrl"] != null && restaurant["imageUrl"].toString().isNotEmpty
                      ? Image.network(
                          restaurant["imageUrl"],
                          fit: BoxFit.fitWidth,
                        )
                      : Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 1)
                          ),
                          height: 200,
                          child: const Center(
                            child: Text(
                              "사진 준비중",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
              ),
            ),
            Container( // 음식점 기본 정보
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text( // 음식점 이름
                        restaurant["restaurantName"],
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold
                        ),
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row( // 음식점 카테고리
                        children: restaurant["categories"].map<Widget>((category) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8), // 카테고리 간 간격
                            child: Text(
                              category,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 108, 108, 108),
                                fontSize: 14,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const Row( // 리뷰 - 추후 리뷰 작성 기능이 생기면 실제 값으로 수정해야함
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.yellow,
                          ),
                          Text(
                            "4.8",
                            style: TextStyle(
                              fontSize: 16
                            ),
                          ),
                          SizedBox(width: 2,),
                          Text(
                            "(500)"
                          )
                        ],
                      ),
                      // 영업 여부
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 20,
                            color: isRestaurantOpen(restaurant["businessHours"]) == "영업중"
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isRestaurantOpen(restaurant["businessHours"]),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isRestaurantOpen(restaurant["businessHours"]) == "영업중"
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          const SizedBox(width: 10,),
                          Text(
                            "${restaurant["businessHours"][DateTime.now().weekday == 1 ? "월" : 
                                    DateTime.now().weekday == 2 ? "화" : 
                                    DateTime.now().weekday == 3 ? "수" : 
                                    DateTime.now().weekday == 4 ? "목" : 
                                    DateTime.now().weekday == 5 ? "금" : 
                                    DateTime.now().weekday == 6 ? "토" : "일"] ?? "휴무"}", // 🔥 영업 시간 표시
                            style: const TextStyle(
                              fontSize: 16
                            ),
                          ),
                          CompositedTransformTarget(
                            link: layerLink, // 아이콘의 위치를 추적
                            child: IconButton(
                              icon: Icon(
                                overlayEntry == null ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                                size: 20,
                              ),
                              onPressed: () {
                                toggleOverlay(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Column(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero, // ✅ 내부 패딩 제거
                            constraints: BoxConstraints(), // ✅ 기본 크기 제한 제거
                            onPressed: () {
                              print("즐겨찾기 버튼 클릭!!!");
                            },
                            icon: const Icon(
                              Icons.turned_in_not,
                              size: 50,
                            ),

                          ),
                          const Text(
                            "즐겨찾기"
                          )
                        ],
                      ),
                      const SizedBox(width: 10),
                      Column(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero, // ✅ 내부 패딩 제거
                            constraints: BoxConstraints(), // ✅ 기본 크기 제한 제거
                            onPressed: () {
                              print("공유 버튼 클릭!!!");
                            },
                            icon: const Icon(
                              Icons.share,
                              size: 50,
                            ),
                          ),
                          const Text(
                            "공유"
                          )
                        ],
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        )
      ),
    );
  }
}