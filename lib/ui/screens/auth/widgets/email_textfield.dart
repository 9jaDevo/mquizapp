import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/utils/validators.dart';

class EmailTextField extends StatelessWidget {
  const EmailTextField({required this.controller, super.key});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = Theme.of(context).primaryColor;
    final hintText = "${context.tr('emailAddress')!}*";

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
            cursorColor: colorScheme.onTertiary,
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            validator: (val) => Validators.validateEmail(
              val!,
              context.tr('emailRequiredMsg'),
              context.tr('enterValidEmailMsg'),
            ),
            style: TextStyle(
              color: colorScheme.onTertiary.withValues(alpha: 0.8),
              fontSize: 16,
              fontWeight: FontWeights.regular,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(
                color: primaryColor.withValues(alpha: 0.5),
                fontSize: 16,
                fontWeight: FontWeights.regular,
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
                    colors: [Color(0xFF1F51D9), Color(0xFF4A75E8)],
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
                    Icons.mail_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
