import 'package:flutter/material.dart';
import 'package:gachi_janchi/widgets/RestaurantMenuListTIle.dart';

class RestaurantDetailMenuScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const RestaurantDetailMenuScreen({super.key, required this.data});

  @override
  State<RestaurantDetailMenuScreen> createState() => _RestaurantDetailMenuScreenState();
}

class _RestaurantDetailMenuScreenState extends State<RestaurantDetailMenuScreen> {
  @override
  Widget build(BuildContext context) {
    print(widget.data["menu"]);
    return CustomScrollView(
      slivers: [
        SliverList.builder(
          itemCount: widget.data["menu"].length,
          itemBuilder: (context, index) {
            final menu = widget.data["menu"][index];
            return RestaurantMenuListTile(
              menu: menu
            );
          }
        )
      ],
    );
  }
}