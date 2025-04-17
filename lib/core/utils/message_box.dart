import 'package:flutter/material.dart';
import 'package:print_demo_zebra/core/color_pellete/app_pellette.dart';
import 'package:print_demo_zebra/core/utils/widgets/app_text.dart';

import '../../../../../core/constants/app_constants.dart';

class MessageBox extends StatelessWidget {
  final String asset;
  final String message;
  const MessageBox(
      {super.key,
        required this.asset,
        required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 10,
          children: [
            Image.asset(
              asset,
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
            AppText(
              bodyText: message,
              maxLines: 3,
              bodyStyle: Theme.of(context).textTheme.labelMedium!,
              textColor:ColorPellete.lightBlackColor,
              textSize: 15,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
