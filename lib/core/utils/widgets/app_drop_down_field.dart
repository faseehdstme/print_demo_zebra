

import 'package:flutter/material.dart';

import 'app_text.dart';

class AppDropDownField extends StatelessWidget {
  final List<String> items;
  final String? selectedItem;
  final String label;
  final TextStyle labelStyle;
  final String hintText;
  final void Function(String?)? onChange;
  const AppDropDownField(
      {super.key,
        required this.items,
        required this.selectedItem,
        required this.onChange,
        required this.hintText,
        required this.label,
        required this.labelStyle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(bodyText: label, bodyStyle: labelStyle),
          const SizedBox(
            height: 5,
          ),
          DropdownButtonFormField(
            value: selectedItem,
            items: items
                .map<DropdownMenuItem<String>>((e) => DropdownMenuItem(
                value: e,
                child: AppText(
                    bodyText: e,
                    bodyStyle: Theme.of(context).textTheme.bodyMedium!)))
                .toList(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select an option';
              }
              return null;
            },
            onChanged: onChange,
            hint: AppText(
              bodyText: hintText,
              bodyStyle: Theme.of(context).textTheme.bodyMedium!,
            ),
          ),
        ],
      ),
    );
  }
}