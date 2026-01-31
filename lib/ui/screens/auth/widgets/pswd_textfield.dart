import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/core/core.dart';

class PswdTextField extends StatefulWidget {
  const PswdTextField({
    required this.controller,
    super.key,
    this.validator,
    this.hintText,
  });

  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String? hintText;

  @override
  State<PswdTextField> createState() => _PswdTextFieldState();
}

class _PswdTextFieldState extends State<PswdTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onTertiary;
    final primaryColor = Theme.of(context).primaryColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.2),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 25,
                offset: Offset(0, 8),
              ),
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            cursorColor: textColor,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.8),
              fontSize: 16,
              fontWeight: FontWeights.regular,
            ),
            obscureText: _obscureText,
            obscuringCharacter: '*',
            validator: (val) {
              if (val!.isEmpty) {
                return context.tr('passwordRequired');
              } else if (val.length < 6) {
                return context.tr('pwdLengthMsg');
              }

              return widget.validator?.call(val);
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 12,
              ),
              hintText: widget.hintText ?? "${context.tr('pwdLbl')!}*",
              hintStyle: TextStyle(
                color: primaryColor.withValues(alpha: 0.5),
                fontWeight: FontWeights.regular,
                fontSize: 16,
              ),
              prefixIconConstraints: const BoxConstraints(
                minHeight: 48,
                minWidth: 56,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 12, right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 15,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: const SizedBox(
                  height: 40,
                  width: 40,
                  child: Icon(
                    CupertinoIcons.lock,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              suffixIconColor: primaryColor.withValues(alpha: 0.6),
              suffixIcon: GestureDetector(
                child: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onTap: () => setState(() => _obscureText = !_obscureText),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
