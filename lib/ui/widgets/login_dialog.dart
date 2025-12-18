import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/core/core.dart';

Future<void> showLoginDialog(
  BuildContext context, {
  required VoidCallback onTapYes,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogCtx) {
      final buttonTextStyle = TextStyle(
        color: context.primaryColor,
        fontWeight: FontWeights.medium,
        fontSize: 16,
      );
      final contentTextStyle = TextStyle(
        color: context.primaryTextColor,
        fontSize: 16,
        fontWeight: FontWeights.regular,
      );
      final titleTextStyle = TextStyle(
        color: context.primaryTextColor,
        fontSize: 18,
        fontWeight: FontWeights.bold,
      );

      return AlertDialog(
        title: Text(
          'Sign In to Get Coins',
          style: titleTextStyle,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Purchase coins and unlock exclusive rewards:',
              style: contentTextStyle,
            ),
            const SizedBox(height: 12),
            Text(
              '• Save your progress\n• Compete on leaderboards\n• Earn badges\n• Challenge friends',
              style: TextStyle(
                color: context.primaryTextColor.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeights.regular,
              ),
            ),
          ],
        ),
        actions: [
          CupertinoButton(
            onPressed: dialogCtx.shouldPop,
            child: Text(context.tr('maybeLater')!, style: buttonTextStyle),
          ),
          CupertinoButton(
            onPressed: () {
              dialogCtx.shouldPop();
              onTapYes();
            },
            child: Text(context.tr('loginLbl')!, style: buttonTextStyle),
          ),
        ],
      );
    },
  );
}
