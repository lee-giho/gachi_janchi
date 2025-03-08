import 'package:flutter/material.dart';

class RestaurantListTile extends StatelessWidget {
  final Map<String, dynamic> restaurant;
  final Function()? onPressed;
  final Function()? onBookmarkPressed;

  const RestaurantListTile({
    super.key,
    required this.restaurant,
    this.onPressed,
    this.onBookmarkPressed,
  });

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

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(120),
        padding: const EdgeInsets.all(10),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        children: [
          // 음식점 이미지
          Container(
            width: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: restaurant["imageUrl"] != null &&
                    restaurant["imageUrl"].toString().isNotEmpty
                ? Image.network(
                    restaurant["imageUrl"],
                    fit: BoxFit.contain,
                  )
                : const SizedBox(
                    height: 100,
                    child: Center(
                      child: Text(
                        "사진 준비중",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
          ),

          // 음식점 정보
          Expanded(
            child: Container(
              height: 100,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 음식점 이름
                  Text(
                    restaurant["restaurantName"],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // 리뷰 -> 추후 리뷰 작성 기능이 생기면 실제 값으로 수정해야함
                  const Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amberAccent),
                      SizedBox(width: 5),
                      Text("4.8 (500)", style: TextStyle(fontSize: 16)),
                    ],
                  ),

                  // 영업 여부
                  Row(
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
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 재료 아이콘 -> 추후 재료를 얻을 수 있는 기능이 생기면 실제 값으로 수정해야함
          Image.asset(
            'assets/images/material/carrot.png',
            fit: BoxFit.contain,
            height: 60,
          ),

          // 즐겨찾기 아이콘 -> 추후 즐겨찾기 기능이 생기면 실제 값으로 수정해야함
          SizedBox(
            width: 40,
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.turned_in_not, size: 30, color: Colors.black),
                  onPressed: onBookmarkPressed,
                ),
                const Text("500", style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
