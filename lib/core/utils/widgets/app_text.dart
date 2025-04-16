

import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String bodyText;
  final TextStyle bodyStyle;
  final Color? textColor;
  final double? textSize;
  final FontWeight? fontWeight;
  final TextOverflow? overFlow;
  final TextAlign? textAlign;
  final int maxLines;
  const AppText(
      {super.key,
        required this.bodyText,
        required this.bodyStyle,
        this.textColor,
        this.overFlow,
        this.textAlign,
        this.textSize,
        this.fontWeight,this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Text(
      bodyText,
      style: bodyStyle.copyWith(
        color: textColor,
        fontSize: textSize,
        fontWeight: fontWeight,
        overflow: overFlow,
      ),
      maxLines: maxLines,
      textAlign: textAlign,
    );
  }
}