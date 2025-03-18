import 'package:flutter/material.dart';

import '../../router/router.dart';

Future<void> startLoadingModal() async {
  return await showDialog<void>(
    context: rootNavigatorKey.currentContext!,
    barrierDismissible: false,
    builder: (_) => Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: const CircularProgressIndicator(),
      ),
    ),
  );
}

Future<void> stopLoadingModal() async {
  Navigator.of(rootNavigatorKey.currentContext!).pop();
}
