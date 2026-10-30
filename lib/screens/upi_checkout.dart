import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';

class UpiApp {
  final String name, scheme;
  const UpiApp(this.name, this.scheme);
}

const upiApps = <UpiApp>[
  UpiApp('Google Pay', 'tez://upi/pay'),
  UpiApp('PhonePe', 'phonepe://pay'),
  UpiApp('Paytm', 'paytmmp://pay'),
  UpiApp('BHIM', 'upi://pay'),
  UpiApp('Any UPI app', 'upi://pay'),
];

Future<UpiApp?> showUpiCheckout(
  BuildContext context, {
  required double amount,
  required String note,
}) {
  return showModalBottomSheet<UpiApp>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheet) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pay with UPI',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                letterSpacing: -.4,
                color: AppColors.ink,
              ),
            ),
            gap8,
            Text('Celebration total ${money(amount)}'),
            gap8,
            Text(
              note,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            gap16,
            ...upiApps.map(
              (app) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: PartyCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  onTap: () => Navigator.pop(sheet, app),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: AppColors.purple,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          app.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.muted),
                    ],
                  ),
                ),
              ),
            ),
            const Text(
              'You’ll confirm the payment in the UPI app you choose.',
              style: TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<bool> openUpiApp({
  required UpiApp app,
  required double amount,
  required String note,
}) async {
  final uri = Uri.parse(
    '${app.scheme}?pa=planmyparty@okaxis&pn=${Uri.encodeComponent('Plan My Party')}&am=${amount.toStringAsFixed(2)}&cu=INR&tn=${Uri.encodeComponent(note)}',
  );
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
