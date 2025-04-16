import 'package:flutter/material.dart';
import 'package:print_demo_zebra/core/color_pellete/app_pellette.dart';

import 'app_text.dart';

void showAppSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
        backgroundColor: ColorPellete.lightPetProfileColor,
        content: AppText(
          bodyText: content,
          textSize: 13,
          maxLines: 3,
          bodyStyle: Theme.of(context).textTheme.bodyMedium!,
          textColor: Colors.white,
        )));
}