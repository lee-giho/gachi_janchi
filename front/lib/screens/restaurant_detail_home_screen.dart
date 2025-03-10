import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class RestaurantDetailHomeScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const RestaurantDetailHomeScreen({super.key, required this.data});

  @override
  State<RestaurantDetailHomeScreen> createState() => _RestaurantDetailHomeScreenState();
}

class _RestaurantDetailHomeScreenState extends State<RestaurantDetailHomeScreen> {

  // 네이버 지도 컨트롤러
  NaverMapController? mapController;
  late NMarker marker;

  @override
  Widget build(BuildContext context) {

    double latitude = widget.data["location"]["latitude"];
    double longitude = widget.data["location"]["longitude"];

    String fullAddress = [
      widget.data["address"]["sido"],
      widget.data["address"]["sigungu"],
      widget.data["address"]["dong"],
      widget.data["address"]["roadName"],
      widget.data["address"]["buildingNumber"],
      if (widget.data["address"]["detailed"] != null && widget.data["address"]["detailed"]!.isNotEmpty) widget.data["address"]["detailed"]
    ].where((element) => element != null && element.toString().isNotEmpty).join(" ");

    String phoneNumber = widget.data["phoneNumber"];

    // 마커 초기화
    marker = NMarker(
      id: "restaurant_marker",
      position: NLatLng(latitude, longitude),
      
    );
    return Column(
      children: [
        Container( // 네이버 지도
          height: 250,
          child: NaverMap(
            onMapReady: (controller) {
              mapController = controller; // mapController 초기화
              mapController!.addOverlay(marker); // 마커 추가
              log("준비 완료!");
            },
          options: NaverMapViewOptions(
            initialCameraPosition: NCameraPosition( // 첫 로딩 포지션
              target: NLatLng(latitude, longitude),
              zoom: 15,
              bearing: 0,
              tilt: 0
            ),
            locationButtonEnable: false, // 내 위치 찾기 위젯이 하단에 생김
            scrollGesturesEnable: false, // 드래그 방지
          ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "정보",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.place
                  ),
                  const SizedBox(width: 5),
                  Text(fullAddress),
                  IconButton(
                    icon: const Icon(
                      Icons.copy,
                      size: 18,
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: fullAddress));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("주소가 복사되었습니다."))
                      );
                    }
                  )
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.phone
                  ),
                  const SizedBox(width: 5),
                  phoneNumber.isNotEmpty 
                    ? Text(phoneNumber)
                    : const Text("준비중"),
                  phoneNumber.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(
                        Icons.copy,
                        size: 18,
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: phoneNumber));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("전화번호가 복사되었습니다."))
                        );
                      }
                    )
                  : const Text("")
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}