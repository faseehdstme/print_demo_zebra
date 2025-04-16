import 'package:flutter/material.dart';
import 'package:print_demo_zebra/core/utils/widgets/app_text.dart';

class CompanyDetails extends StatelessWidget {
  const CompanyDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppText(bodyText: 'Delivered By', bodyStyle: Theme.of(context).textTheme.bodyMedium!,textSize: 12,),
          AppText(bodyText: 'DSTME LLC', bodyStyle: Theme.of(context).textTheme.bodyMedium!,textSize: 15,fontWeight: FontWeight.w600,)

        ],
      ),
    );
  }
}
