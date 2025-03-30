import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int trimLines;
  final TextStyle? style;

  const ExpandableText({
    Key? key,
    required this.text,
    this.trimLines = 3,
    this.style,
  }) : super(key: key);

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  bool shouldTrim = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 텍스트 오버플로우 체크
        final textPainter = TextPainter(
          text: TextSpan(
            text: widget.text,
            style: widget.style ?? DefaultTextStyle.of(context).style,
          ),
          maxLines: widget.trimLines,
          textDirection: TextDirection.ltr,
        );

        textPainter.layout(maxWidth: constraints.maxWidth);
        shouldTrim = textPainter.didExceedMaxLines;

        return Column(
          children: [
            AnimatedSize(
              alignment: Alignment.topCenter,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.text,
                    style: widget.style,
                    maxLines: isExpanded
                      ? null
                      : widget.trimLines,
                    overflow: isExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (shouldTrim)
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        isExpanded 
                          ? "접기"
                          : "더보기",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down
                      )
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
