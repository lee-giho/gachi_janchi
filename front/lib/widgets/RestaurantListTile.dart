import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gachi_janchi/screens/restaurant_detail_screen.dart';
import 'package:gachi_janchi/utils/favorite_provider.dart';
import 'package:gachi_janchi/utils/secure_storage.dart';
import 'package:http/http.dart'  as http;
import 'dart:convert';


class RestaurantListTile extends ConsumerWidget {
  final Map<String, dynamic> restaurant;
  final Function()? onPressed;
  // final Function()? onBookmarkPressed;

  const RestaurantListTile({
    super.key,
    required this.restaurant,
    this.onPressed,
    // this.onBookmarkPressed,
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
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteProviderNotifier = ref.read(favoriteProvider.notifier);

    // 즐겨찾기 리스트에서 현재 restaurant의 ID를 포함하는지 확인
    final isFavorite = ref.watch(favoriteProvider).any((fav) => fav["id"] == restaurant["id"]);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailScreen(
              data: {
                "restaurant": restaurant
              }
            )
          )
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: FutureBuilder<String>(
        future: favoriteProviderNotifier.getFavoriteCount(restaurant["id"]),
        builder: (context, snapshot) {
          final favoriteCount = snapshot.data ?? "0";
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: const BoxDecoration(
              border: Border(bottom:BorderSide(width: 1, color: Colors.grey))
            ),
            child: Row(
              children: [
                // 음식점 이미지
                Container(
                  width: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: restaurant["imageUrl"] != null && restaurant["imageUrl"].toString().isNotEmpty
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
                  'assets/images/ingredient/${restaurant["ingredientName"]}.png',
                  fit: BoxFit.contain,
                  width: 60,
                ),
                  
                // 즐겨찾기 아이콘 -> 추후 즐겨찾기 기능이 생기면 실제 값으로 수정해야함
                SizedBox(
                  height: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          isFavorite
                            ? Icons.turned_in
                            : Icons.turned_in_not,
                          size: 30, 
                          color: isFavorite
                            ? Colors.yellow
                            : Colors.black,
                        ),
                        onPressed: () {
                          favoriteProviderNotifier.toggleFavoriteRestaurant(restaurant);
                        },
                      ),
                      Text(
                        favoriteCount,
                        style: const TextStyle(fontSize: 12)
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
