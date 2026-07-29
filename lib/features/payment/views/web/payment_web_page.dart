import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/payment/views/mobile/payment_mobile_page.dart';
import 'package:flutter/material.dart';

class PaymentWebPage extends StatelessWidget {
  const PaymentWebPage({
    super.key,
    required this.isVerify,
    required this.felicitup,
    required this.userId,
  });

  final bool isVerify;
  final FelicitupModel felicitup;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 600,
        child: PaymentMobilePage(
          isVerify: isVerify,
          felicitup: felicitup,
          userId: userId,
        ),
      ),
    );
  }
}
