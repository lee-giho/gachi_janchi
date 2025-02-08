import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:permission_handler/permission_handler.dart';

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
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NaverMap(
          options: const NaverMapViewOptions(
            initialCameraPosition: NCameraPosition( // 첫 로딩 포지션
              target: NLatLng(37.5667070936, 126.97876548263318),
              zoom: 15,
              bearing: 0,
              tilt: 0
            ),
            locationButtonEnable: true // 내 위치 찾기 위젯이 하단에 생김
          ),
          onSymbolTapped: (symbolInfo) {
            log("symbolInfo: ${symbolInfo.caption}");
          },
          onMapReady: (controller) {
            log("준비완료!");
          },
        )
      ),
    );
  }
}