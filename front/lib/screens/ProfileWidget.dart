import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();

  /// ✅ **프로필 즉시 업데이트 (전역에서 호출 가능)**
  static Future<void> updateProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _ProfileWidgetState.profileImage = prefs.getString('profile_image') != null
        ? File(prefs.getString('profile_image')!)
        : null;
    _ProfileWidgetState.selectedIconIndex = prefs.getInt('profile_icon') ?? 0;
  }
}

class _ProfileWidgetState extends State<ProfileWidget> {
  static File? profileImage; // ✅ 전역에서 접근 가능하도록 static 선언
  static int selectedIconIndex = 0;
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
    _loadProfileData();
  }

  /// ✅ 저장된 프로필 데이터 로드
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image');
    final iconIndex = prefs.getInt('profile_icon') ?? 0;

    setState(() {
      selectedIconIndex = iconIndex;
      profileImage = imagePath != null ? File(imagePath) : null;
    });
  }

  /// ✅ 프로필 이미지 선택 및 저장
  Future<void> _pickAndSaveProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final savedImage = File('${appDir.path}/profile_image.png');

    await File(pickedFile.path).copy(savedImage.path);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image', savedImage.path);

    setState(() {
      profileImage = savedImage;
    });

    // ✅ 변경된 데이터 즉시 반영
    await ProfileWidget.updateProfile();
  }

  /// ✅ 기본 프로필 아이콘 선택 및 저장
  Future<void> _selectDefaultIcon(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('profile_icon', index);
    await prefs.remove('profile_image');

    setState(() {
      profileImage = null;
      selectedIconIndex = index;
    });

    // ✅ 변경된 데이터 즉시 반영
    await ProfileWidget.updateProfile();
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
                  _showDefaultIconSelectionDialog();
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
                  Navigator.pop(context);
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
        backgroundImage: profileImage != null ? FileImage(profileImage!) : null,
        child: profileImage == null
            ? Icon(_defaultIcons[selectedIconIndex],
                size: 50, color: Colors.black)
            : null,
      ),
    );
  }
}
