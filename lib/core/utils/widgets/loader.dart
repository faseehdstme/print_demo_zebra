import 'package:flutter/material.dart';
import 'package:print_demo_zebra/core/color_pellete/app_pellette.dart';

class Loader extends StatefulWidget {
  const Loader({super.key});

  @override
  State<Loader> createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      height: 60,
      width: 60,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: ColorPellete.lightWhiteColor,),
      child:  CircularProgressIndicator(
        color: ColorPellete.lightLavender,
      ),
    );
  }
}