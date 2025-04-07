import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gachi_janchi/utils/secure_storage.dart';
import 'package:gachi_janchi/utils/translation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IngredientFilterPopUp extends StatefulWidget {
  List<dynamic> selected;
  final void Function(String)? selectIngredient;
  IngredientFilterPopUp({
    super.key,
    required this.selected,
    required this.selectIngredient
  });

  @override
  State<IngredientFilterPopUp> createState() => _IngredientFilterPopUpState();
}

class _IngredientFilterPopUpState extends State<IngredientFilterPopUp> {

  List<dynamic> allIngredients = []; // 서버에서 받아온 전체 재료 정보
  List<dynamic> selectIngredients = [];

  @override
  void initState() {
    super.initState();
    fetchAllIngredients();
    selectIngredients = List.from(widget.selected);
  }

  /// 전체 재료 목록 불러오기 (이름순 정렬 추가됨)
  Future<void> fetchAllIngredients() async {
    String? accessToken = await SecureStorage.getAccessToken();
    if (accessToken == null) return;

    // .env에서 서버 URL 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/ingredients/all");
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
        print("전체 재료 목록 불러오기 요청 완료");

        final decodedData = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedData);
        data.sort((a, b) => (a["name"] as String).compareTo(b["name"] as String));
        print("data: $decodedData");
        setState(() {
          allIngredients = data;
        });

        print("allIngredients: $allIngredients");
        print("전체 재료 목록 불러오기 성공 ");
      } else {
        print("전체 재료 목록 불러오기 실패");
      }
    } catch (e) {
      // 예외 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("네트워크 오류: ${e.toString()}"))
      );
    }
  }

  Future<void> clickIngredient(String name, bool isSelected) async {
    setState(() {
      if (isSelected) {
        selectIngredients.remove(name);
      } else {
        selectIngredients.add(name);
      }  
    });
    
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 300,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black)

      ),
      child: Align(
        alignment: Alignment.center,
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: allIngredients.map((ingredient) {
            String name = ingredient["name"];
            String imagePath = 'assets/images/ingredient/$name.png';
            bool isSelected = selectIngredients.contains(name);
        
            return GestureDetector(
              onTap: () {
                clickIngredient(name, isSelected);
                widget.selectIngredient!(name);
                print("name: $name");
                print("selectIngredients: $selectIngredients");
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                    ? Border.all(width: 2, color: const Color.fromRGBO(122, 11, 11, 1),)
                    : Border.all(width: 1, color: Colors.black26),
                ),
                child: Center(
                  child: ColorFiltered(
                    colorFilter: isSelected
                      ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                      : const ColorFilter.matrix([
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0, 0, 0, 1, 0,
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      // child: GridView.builder(
      //   itemCount: allIngredients.length,
      //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      //     crossAxisCount: 4,
      //     childAspectRatio: 1,
      //     crossAxisSpacing: 10,
      //     mainAxisSpacing: 10,
      //   ),
      //   itemBuilder: (context, index) {
      //     final ingredient = allIngredients[index];
      //     String name = ingredient["name"];
      //     String imagePath = 'assets/images/ingredient/$name.png'; // 여기 수정
      //     bool isSelected = false;
            
      //     return GestureDetector(
      //       onTap: () {
            
      //       },
      //       child: Container(
      //         decoration: BoxDecoration(
      //           color: Colors.white,
      //           borderRadius: BorderRadius.circular(12),
      //           border: Border.all(color: Colors.black26),
      //         ),
      //         child: Center(
      //           child: ColorFiltered(
      //             colorFilter: isSelected
      //                 ? const ColorFilter.mode(
      //                     Colors.transparent, BlendMode.dst)
      //                 : const ColorFilter.matrix([
      //                     0.2126,
      //                     0.7152,
      //                     0.0722,
      //                     0,
      //                     0,
      //                     0.2126,
      //                     0.7152,
      //                     0.0722,
      //                     0,
      //                     0,
      //                     0.2126,
      //                     0.7152,
      //                     0.0722,
      //                     0,
      //                     0,
      //                     0,
      //                     0,
      //                     0,
      //                     1,
      //                     0,
      //                   ]),
      //             child: Padding(
      //               padding: const EdgeInsets.all(8.0),
      //               child: Image.asset(
      //                 imagePath,
      //                 fit: BoxFit.contain,
      //                 errorBuilder: (_, __, ___) =>
      //                     const Icon(Icons.error),
      //               ),
      //             ),
      //           ),
      //         ),
      //       ),
      //     );
      //   },
      // ),
    );
  }
} 