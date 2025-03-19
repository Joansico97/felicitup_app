import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: context.sp(50),
              width: context.fullWidth,
              padding: EdgeInsets.symmetric(
                horizontal: context.sp(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: context.fullWidth,
                    child: Text(
                      'Notificaciones',
                      textAlign: TextAlign.center,
                      style: context.styles.subtitle,
                    ),
                  ),
                  Container(
                    width: context.fullWidth,
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black,
                      ),
                      onPressed: () async {
                        if (context.mounted) {
                          context.go(
                            RouterPaths.felicitupsDashboard,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
