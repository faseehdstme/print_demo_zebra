import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_text.dart';

class AppTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final String label;
  final TextStyle labelStyle;
  final TextInputType textInputType;
  final String? Function(String?)? validator;
  final String? Function(String?)? onChange;

  final String? Function(String?)? onSubmit;
  final bool readOnly;
  final int maxLine;
  final int minLine;
  final bool obscure;
  final Widget? prefixText;
  final Widget? suffix;
  final List<TextInputFormatter>? inputs;
  final FocusNode? focusNode;
  const AppTextFormField(
      {super.key,
      required this.label,
      required this.controller, this.hintText,
      this.textInputType = TextInputType.text,
        this.onChange,
      this.readOnly = false,
      this.maxLine = 1,
      this.minLine = 1,
      this.obscure = false,
      required this.labelStyle,
      this.validator,
      this.inputs,
      this.prefixText,
        this.onSubmit,
      this.suffix,this.focusNode});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(bodyText: label, bodyStyle: labelStyle),
          const SizedBox(
            height: 5,
          ),
          TextFormField(
            enabled: true,
            onFieldSubmitted: onSubmit,
            focusNode: focusNode,
            style: Theme.of(context).textTheme.bodyMedium,
            controller: controller,
            keyboardType: textInputType,
            validator: validator,
            readOnly: readOnly,
            onChanged: onChange,
            maxLines: maxLine,
            minLines: minLine,
            obscureText: obscure,
            inputFormatters: inputs,
            decoration: InputDecoration(
                hintText: hintText??"",
                suffixIcon: suffix,
                prefixIcon: prefixText,
                prefixStyle: Theme.of(context).textTheme.labelSmall),
          ),
        ],
      ),
    );
  }
}
