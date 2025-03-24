import 'package:flutter/material.dart';

class RestaurantMenuListTile extends StatefulWidget {
  final Map<String, dynamic> menu;
  const RestaurantMenuListTile({super.key, required this.menu});

  @override
  State<RestaurantMenuListTile> createState() => _RestaurantmenulisttileState();
}

class _RestaurantmenulisttileState extends State<RestaurantMenuListTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        border: Border(bottom:BorderSide(width: 1, color: Colors.grey))
      ),
      child: Row(
        children: [
          Container( // 메뉴 사진
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(width: 1)
            ),
            child: const Center(
              child: Text(
                "사진 준비중"
              ),
            ),
          ),
          const SizedBox(width: 10,),
          Expanded(
            child: Container( // 메뉴 이름, 가격
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.menu["name"],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                    softWrap: true,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    "메뉴 설명 (추가 해야함)",
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.menu["price"],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}