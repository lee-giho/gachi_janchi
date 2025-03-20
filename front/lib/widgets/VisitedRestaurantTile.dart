import 'package:flutter/material.dart';

class VisitedRestaurantTile extends StatefulWidget {
  const VisitedRestaurantTile({super.key});

  @override
  State<VisitedRestaurantTile> createState() => _VisitedrestauranttileState();
}

class _VisitedrestauranttileState extends State<VisitedRestaurantTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print("방문 음식점 tile 클릭");
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
              child: const SizedBox(
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
                      "음식점 이름",
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
                          "2025.03.12"
                        ),
                        Text(
                          " / "
                        ),
                        Text( // 시간
                          "15:30"
                        )
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
                      onPressed: () {

                      },
                      child: Text(
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
              'assets/images/material/tomato.png',
              fit: BoxFit.contain,
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}