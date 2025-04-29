import 'package:flutter/material.dart';

import '../../core/color_pellete/app_pellette.dart';

class AppTheme {
  //lightTheme
  static TextStyle lightTextStyle(
      {required double fontSize,
        required FontWeight fontWeight,
        required Color color}) =>
      TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: ColorPellete.lightWhiteColor);

  static TextStyle lightPoppiTextStyle(
      {required double fontSize,
        required FontWeight fontWeight,
        required Color color}) =>
      TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color);

  static TextStyle lightHeadTextStyle(
      {required double textSize,
        required FontWeight fontWeight,
        required Color color}) =>
      TextStyle(
          fontSize: 32,
          fontWeight: fontWeight,
          color: color);
  static ElevatedButtonThemeData lightElevatedButtonTheme() =>
      ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: ColorPellete.lightButtonColor, // Button color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              fixedSize: const Size(200, 30),
              textStyle: lightTextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: ColorPellete.lightBlackColor)));

  static OutlineInputBorder lightOutlineBorder({required Color color}) =>
      OutlineInputBorder(
          borderSide: BorderSide(color: color),
          borderRadius: BorderRadius.circular(10));
  static InputDecorationTheme lightInputDecoration = InputDecorationTheme(
    border: lightOutlineBorder(color: ColorPellete.lightBorderGrey),
    errorBorder: lightOutlineBorder(color: ColorPellete.lightErrorColor),
    focusedBorder: lightOutlineBorder(color: ColorPellete.lightBlackColor),
    enabledBorder: lightOutlineBorder(color: ColorPellete.lightBlackColor),
    hintStyle: lightPoppiTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: ColorPellete.lightBlackColor),
    errorStyle: lightPoppiTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: ColorPellete.lightErrorColor),
    labelStyle: lightPoppiTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: ColorPellete.lightBlackColor),
    prefixStyle: lightPoppiTextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: ColorPellete.lightBlackColor),
    suffixIconColor: ColorPellete.lightBlackColor,
  );
  static dynamic lightTheme = ThemeData.light().copyWith(
    elevatedButtonTheme: lightElevatedButtonTheme(),
    inputDecorationTheme: lightInputDecoration,
    textTheme: TextTheme(
        labelSmall: lightPoppiTextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: ColorPellete.lightBlackColor),
        labelLarge: lightTextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: ColorPellete.lightBlackColor),
        titleMedium: lightPoppiTextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: ColorPellete.lightBlackColor),
        titleSmall: lightPoppiTextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: ColorPellete.lightBlackColor),
        bodyLarge: lightPoppiTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: ColorPellete.lightBlackColor),
        bodyMedium: lightPoppiTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: ColorPellete.lightBlackColor),
        headlineLarge: lightHeadTextStyle(
            textSize: 32,
            fontWeight: FontWeight.w400,
            color: ColorPellete.lightWhiteColor),
        headlineMedium: lightHeadTextStyle(
            textSize: 23,
            fontWeight: FontWeight.w700,
            color: ColorPellete.lightBlackColor)),
  );

  //darkTheme

  static dynamic darkTheme = ThemeData.dark().copyWith();
}