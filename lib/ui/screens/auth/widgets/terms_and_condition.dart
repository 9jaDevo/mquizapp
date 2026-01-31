import 'package:flutter/material.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/ui/screens/app_settings_screen.dart';

class TermsAndCondition extends StatelessWidget {
  const TermsAndCondition({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeights.regular,
      color: Theme.of(context).primaryColor.withValues(alpha: 0.6),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(context.tr('termAgreement')!, style: textStyle),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () => context.pushNamed(
                Routes.appSettings,
                arguments: const AppSettingsScreenArgs(termsAndConditions),
              ),
              child: Text(
                context.tr('termOfService')!,
                style: textStyle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeights.semiBold,
                  decoration: TextDecoration.underline,
                  decorationColor: Theme.of(context).primaryColor,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(context.tr('andLbl')!, style: textStyle),
            const SizedBox(width: 6),
            InkWell(
              onTap: () => context.pushNamed(
                Routes.appSettings,
                arguments: const AppSettingsScreenArgs(privacyPolicy),
              ),
              child: Text(
                context.tr('privacyPolicy')!,
                style: textStyle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeights.semiBold,
                  decoration: TextDecoration.underline,
                  decorationColor: Theme.of(context).primaryColor,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
