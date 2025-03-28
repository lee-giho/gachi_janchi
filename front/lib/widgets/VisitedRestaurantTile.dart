import 'package:flutter/material.dart';
import 'package:gachi_janchi/screens/restaurant_detail_screen.dart';
import 'package:gachi_janchi/screens/review_registration_screen.dart';

class VisitedRestaurantTile extends StatefulWidget {
  final Map<String, dynamic> visitedRestaurant;
  final VoidCallback onReviewCompleted;

  const VisitedRestaurantTile({
    super.key,
    required this.visitedRestaurant,
    required this.onReviewCompleted
  });

  @override
  State<VisitedRestaurantTile> createState() => _VisitedrestauranttileState();
}

class _VisitedrestauranttileState extends State<VisitedRestaurantTile> {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> restaurant = widget.visitedRestaurant["restaurant"];
    print("visitedRestaurant: ${widget.visitedRestaurant}");
    print("reviewWrite: ${widget.visitedRestaurant["reviewWrite"]}");

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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: const BoxDecoration(
          border: Border(bottom:BorderSide(width: 1, color: Colors.grey))
        ),
        child: Row(
          children: [
            Container( // 음식점 이미지
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
            Expanded( // 방문 정보
              child: Container(
                constraints: BoxConstraints(
                  minHeight: 100 // 최소 높이
                ),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text( // 음식점 이름
                      restaurant["restaurantName"],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row( // 방문 날짜 & 시간
                      children: [
                        Icon(
                          Icons.calendar_month,
                          size: 20,
                        ),
                        Text( // 날짜
                          widget.visitedRestaurant["visitedAt"].toString().replaceFirst('T', ' ')
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        foregroundColor: Colors.white,
                        backgroundColor: const Color.fromRGBO(122, 11, 11, 1),
                        side: const BorderSide(
                          width: 0.5,
                          color: Colors.black
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)
                        )
                      ),
                      onPressed: () async { widget.visitedRestaurant["reviewWrite"]
                        ? null
                        : await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewRegistrationScreen(
                                data: {
                                  "visitedId": widget.visitedRestaurant["visitedId"],
                                  "restaurantId": restaurant["id"],
                                  "restaurantMenu": restaurant["menu"]
                                }
                              )
                            )
                          );
                          // pop 후 콜백 실행
                          widget.onReviewCompleted();
                      },
                      child: widget.visitedRestaurant["reviewWrite"]
                      ? const Text(
                          "리뷰 작성완료",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                          ),
                        ) 
                      : const Text(
                          "리뷰 작성하기",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                          ),
                        )
                    )
                  ],
                ),
              )
            ),
            Image.asset(
              'assets/images/ingredient/${widget.visitedRestaurant["ingredientName"]}.png',
              fit: BoxFit.contain,
              width: 60,
            ),
          ],
        ),
      ),
    );
  }
}