import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';

const _banks = [
  'State Bank of India',
  'HDFC Bank',
  'ICICI Bank',
  'Axis Bank',
  'Kotak Mahindra Bank',
];

const _wallets = ['Amazon Pay', 'Mobikwik', 'Freecharge'];

const _demoOtp = '123456';

class PaymentGatewayScreen extends StatefulWidget {
  final double amount;
  final String note;
  const PaymentGatewayScreen({
    super.key,
    required this.amount,
    required this.note,
  });

  @override
  State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  final cardNumber = TextEditingController();
  final expiry = TextEditingController();
  final cvv = TextEditingController();
  final holder = TextEditingController();
  final otp = TextEditingController();
  String method = 'Card';
  String? bank;
  String? wallet;
  bool confirming = false;
  bool processing = false;

  @override
  void dispose() {
    cardNumber.dispose();
    expiry.dispose();
    cvv.dispose();
    holder.dispose();
    otp.dispose();
    super.dispose();
  }

  void _editDetails() {
    setState(() {
      confirming = false;
      otp.clear();
    });
  }

  void _pay() {
    final error = _validateDetails();
    if (error != null) {
      notify(context, error);
      return;
    }
    setState(() => confirming = true);
  }

  Future<void> _confirm() async {
    if (otp.text.trim() != _demoOtp) {
      notify(context, 'Enter $_demoOtp to confirm this payment on your phone.');
      return;
    }
    setState(() => processing = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  String? _validateDetails() {
    if (method == 'Card') return _validateCard();
    if (method == 'Net banking') {
      return bank == null ? 'Choose a bank to continue.' : null;
    }
    return wallet == null ? 'Choose a wallet to continue.' : null;
  }

  String? _validateCard() {
    final digits = cardNumber.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 16 || !_luhn(digits)) {
      return 'Enter a valid 16-digit card number.';
    }
    if (_expiryEnd(expiry.text) == null) {
      return 'Enter a valid expiry as MM/YY.';
    }
    final code = cvv.text.trim();
    if (!RegExp(r'^\d{3,4}$').hasMatch(code)) {
      return 'Enter the 3-digit security code.';
    }
    final name = holder.text.trim();
    if (name.length < 2) return 'Enter the name on the card.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Payment',
      bottom: PrimaryButton(
        processing
            ? 'Confirming…'
            : confirming
            ? 'Confirm payment'
            : 'Pay now',
        icon: Icons.lock_outline,
        onPressed: processing ? null : (confirming ? _confirm : _pay),
      ),
      children: [
        const PageHeading(
          'Pay on this phone.',
          subtitle:
              'Card, net banking, or a wallet. You confirm the charge on this phone.',
        ),
        PartyCard(child: InfoPair('Celebration total', money(widget.amount))),
        gap8,
        Text(
          widget.note,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        gap24,
        const Text(
          'Payment method',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        gap8,
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: ['Card', 'Net banking', 'Wallet']
              .map(
                (item) => ChoiceChip(
                  label: Text(item),
                  selected: method == item,
                  onSelected: processing || confirming
                      ? null
                      : (_) => setState(() {
                          method = item;
                          confirming = false;
                          otp.clear();
                        }),
                ),
              )
              .toList(),
        ),
        gap24,
        if (method == 'Card') _cardForm(),
        if (method == 'Net banking') _bankForm(),
        if (method == 'Wallet') _walletForm(),
        if (confirming) ...[
          gap16,
          const Text(
            'Confirm on this phone',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          gap8,
          Text(
            'Enter $_demoOtp. This code confirms the payment gateway charge on your phone.',
            style: const TextStyle(fontSize: 12),
          ),
          gap12,
          TextField(
            key: const ValueKey('payment-otp'),
            controller: otp,
            keyboardType: TextInputType.number,
            maxLength: 6,
            enabled: !processing,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(labelText: 'Confirmation code'),
          ),
          TextButton(
            onPressed: processing ? null : _editDetails,
            child: const Text('Edit payment details'),
          ),
        ],
        const DemoNotice(
          text:
              'Paid on this phone through the payment gateway. Card details are checked here and are not saved.',
        ),
      ],
    );
  }

  Widget _cardForm() => Column(
    children: [
      TextField(
        key: const ValueKey('payment-card-number'),
        controller: cardNumber,
        keyboardType: TextInputType.number,
        enabled: !confirming,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[\d ]')),
          LengthLimitingTextInputFormatter(19),
        ],
        decoration: const InputDecoration(
          labelText: 'Card number',
          hintText: '4242 4242 4242 4242',
        ),
      ),
      gap16,
      Row(
        children: [
          Expanded(
            child: TextField(
              key: const ValueKey('payment-expiry'),
              controller: expiry,
              keyboardType: TextInputType.number,
              enabled: !confirming,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d/]')),
                LengthLimitingTextInputFormatter(5),
              ],
              decoration: const InputDecoration(
                labelText: 'Expiry',
                hintText: 'MM/YY',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              key: const ValueKey('payment-cvv'),
              controller: cvv,
              keyboardType: TextInputType.number,
              obscureText: true,
              enabled: !confirming,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              decoration: const InputDecoration(labelText: 'CVV'),
            ),
          ),
        ],
      ),
      gap16,
      TextField(
        key: const ValueKey('payment-name'),
        controller: holder,
        textCapitalization: TextCapitalization.words,
        enabled: !confirming,
        decoration: const InputDecoration(labelText: 'Name on card'),
      ),
    ],
  );

  Widget _bankForm() => DropdownButtonFormField<String>(
    key: const ValueKey('payment-bank'),
    initialValue: bank,
    isExpanded: true,
    decoration: const InputDecoration(labelText: 'Bank'),
    items: _banks
        .map((item) => DropdownMenuItem(value: item, child: Text(item)))
        .toList(),
    onChanged: confirming ? null : (value) => setState(() => bank = value),
  );

  Widget _walletForm() => Wrap(
    spacing: 8,
    runSpacing: 4,
    children: _wallets
        .map(
          (item) => ChoiceChip(
            label: Text(item),
            selected: wallet == item,
            onSelected: confirming
                ? null
                : (_) => setState(() => wallet = item),
          ),
        )
        .toList(),
  );
}

bool _luhn(String digits) {
  var sum = 0;
  var alternate = false;
  for (var i = digits.length - 1; i >= 0; i--) {
    var n = int.parse(digits[i]);
    if (alternate) {
      n *= 2;
      if (n > 9) n -= 9;
    }
    sum += n;
    alternate = !alternate;
  }
  return sum % 10 == 0;
}

DateTime? _expiryEnd(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.length != 4) return null;
  final month = int.tryParse(digits.substring(0, 2));
  final year = int.tryParse(digits.substring(2));
  if (month == null || year == null || month < 1 || month > 12) return null;
  final end = DateTime(2000 + year, month + 1, 0);
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month);
  if (end.isBefore(startOfMonth)) return null;
  return end;
}
