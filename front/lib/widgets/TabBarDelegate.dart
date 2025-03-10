import 'package:flutter/material.dart';

class TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  TabBarDelegate(this.child);

  @override
  double get minExtent => 50; // 최소 높이
  @override
  double get maxExtent => 50; // 최대 높이

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true; // ✅ 변경된 상태를 감지하고 다시 빌드하도록 설정
  }
}
