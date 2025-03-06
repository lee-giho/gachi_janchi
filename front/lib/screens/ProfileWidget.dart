import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  File? _profileImage; // ✅ 현재 선택된 프로필 이미지
  int _selectedIconIndex = 0; // ✅ 기본 프로필 아이콘 인덱스
  final ImagePicker _picker = ImagePicker();

  // ✅ 기본 제공 아이콘 리스트
  final List<IconData> _defaultIcons = [
    Icons.person,
    Icons.account_circle,
    Icons.emoji_emotions,
    Icons.face,
    Icons.pets
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileData(); // 앱 실행 시 저장된 프로필 정보 불러오기
  }

  /// ✅ 저장된 프로필 데이터 로드 (이미지 & 기본 아이콘)
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image');
    final iconIndex = prefs.getInt('profile_icon') ?? 0;

    setState(() {
      _selectedIconIndex = iconIndex;
      _profileImage = imagePath != null ? File(imagePath) : null;
    });
  }

  /// ✅ 프로필 이미지 선택 및 저장
  Future<void> _pickAndSaveProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final savedImage = File('${appDir.path}/profile_image.png');

    await File(pickedFile.path).copy(savedImage.path); // 이미지 저장

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image', savedImage.path); // 경로 저장

    setState(() {
      _profileImage = savedImage;
    });
  }

  /// ✅ 기본 프로필 아이콘 선택 및 저장
  Future<void> _selectDefaultIcon(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('profile_icon', index); // 선택한 기본 아이콘 인덱스 저장
    await prefs.remove('profile_image'); // 기존 이미지 삭제

    setState(() {
      _profileImage = null; // 기본 이미지로 변경
      _selectedIconIndex = index;
    });
  }

  /// ✅ 프로필 변경 다이얼로그
  void _showProfileOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("프로필 변경"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  _pickAndSaveProfileImage();
                  Navigator.pop(context);
                },
                child: const Text("갤러리에서 선택"),
              ),
              TextButton(
                onPressed: () {
                  _showDefaultIconSelectionDialog(); // 기본 아이콘 선택 창 띄우기
                },
                child: const Text("기본 아이콘 선택"),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ✅ 기본 아이콘 선택 다이얼로그
  void _showDefaultIconSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("기본 아이콘 선택"),
          content: Wrap(
            spacing: 10,
            children: List.generate(_defaultIcons.length, (index) {
              return GestureDetector(
                onTap: () {
                  _selectDefaultIcon(index);
                  Navigator.pop(context);
                  Navigator.pop(context); // 메인 다이얼로그도 닫기
                },
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  child:
                      Icon(_defaultIcons[index], size: 30, color: Colors.black),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showProfileOptionsDialog,
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[300],
        backgroundImage:
            _profileImage != null ? FileImage(_profileImage!) : null,
        child: _profileImage == null
            ? Icon(_defaultIcons[_selectedIconIndex],
                size: 50, color: Colors.black)
            : null,
      ),
    );
  }
}
