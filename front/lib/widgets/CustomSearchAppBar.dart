import 'package:flutter/material.dart';
import 'package:gachi_janchi/widgets/QRCodeButton.dart';

class CustomSearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final VoidCallback onSearchPressed;
  final VoidCallback onClearPressed;
  final VoidCallback onBackPressed;
  final void Function(int)? changeTap;

  const CustomSearchAppBar({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
    required this.onSearchPressed,
    required this.onClearPressed,
    required this.onBackPressed,
    required this.changeTap
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: onBackPressed,
            ),
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        focusNode: searchFocusNode,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          hintText: "찾고 있는 잔치집이 있나요?",
                          hintStyle: TextStyle(fontSize: 15),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    if (searchFocusNode.hasFocus)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: onClearPressed,
                      ),
                    IconButton(
                      icon: const Icon(Icons.search, size: 20),
                      onPressed: onSearchPressed,
                    ),
                  ],
                ),
              ),
            ),
            QRCodeButton(
              changeTap: changeTap
            )
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60); // AppBar 높이 설정
}
