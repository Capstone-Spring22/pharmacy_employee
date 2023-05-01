import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class Input extends StatelessWidget {
  final TextEditingController inputController;
  final String? title;
  final Function(String)? onChanged;
  final FocusNode? focus;
  final TextInputType? inputType;
  final bool enabled;
  final String? hint;
  final Function(String)? onSubmit;
  final bool centerText;
  final TextInputAction? inputAction;
  final int? maxLines;
  final bool expands;
  final bool autofocus;
  final double txtHeight;
  final bool isFormField;
  final String? Function(String?)? validator;
  final List<TextInputFormatter> inputFormatters;
  final VoidCallback? clearBtn;
  const Input({
    Key? key,
    required this.inputController,
    this.title,
    this.clearBtn,
    this.onChanged,
    this.focus,
    this.inputType,
    this.enabled = true,
    this.hint,
    this.inputAction,
    this.inputFormatters = const [],
    this.centerText = false,
    this.expands = false,
    this.onSubmit,
    this.validator,
    this.txtHeight = 50,
    this.autofocus = false,
    this.maxLines = 1,
    this.isFormField = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final txtTheme = context.textTheme;
    final theme = context.theme;

    final deco = InputDecoration(
      suffixIcon: IconButton(
        onPressed: clearBtn ?? () => inputController.clear(),
        icon: const Icon(Icons.clear),
      ),
      label: title != null ? Text(title!) : null,
      labelStyle: context.textTheme.bodyLarge,
      filled: true,
      hintText: hint,
      hintStyle: context.textTheme.labelMedium,
      fillColor: theme.secondaryHeaderColor,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: theme.primaryColor, width: 1.0),
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.primaryColor, width: 1.0),
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: context.theme.colorScheme.error,
          width: 1.0,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: context.theme.secondaryHeaderColor,
          width: 1.0,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 8,
          ),
          Container(
            height: txtHeight,
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                offset: const Offset(12, 26),
                blurRadius: 50,
                spreadRadius: 0,
                color: Colors.grey.withOpacity(.1),
              ),
            ]),
            child: isFormField
                ? TextFormField(
                    textInputAction: inputAction,
                    focusNode: focus,
                    enabled: enabled,
                    expands: expands,
                    inputFormatters: inputFormatters,
                    textAlign: centerText ? TextAlign.center : TextAlign.left,
                    controller: inputController,
                    onChanged: onChanged,
                    keyboardType: inputType ?? TextInputType.text,
                    style: txtTheme.bodyLarge,
                    maxLines: expands ? null : maxLines,
                    autofocus: autofocus,
                    decoration: deco,
                    validator: validator,
                  )
                : TextField(
                    textInputAction: inputAction,
                    focusNode: focus,
                    enabled: enabled,
                    expands: expands,
                    textAlign: centerText ? TextAlign.center : TextAlign.left,
                    onSubmitted: onSubmit,
                    controller: inputController,
                    onChanged: onChanged,
                    keyboardType: inputType ?? TextInputType.text,
                    style: txtTheme.bodyLarge,
                    maxLines: expands ? null : maxLines,
                    autofocus: autofocus,
                    decoration: deco,
                  ),
          ),
        ],
      ),
    );
  }
}
