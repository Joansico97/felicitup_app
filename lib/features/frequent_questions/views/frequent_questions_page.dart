import 'package:felicitup_app/core/constants/constants.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/terms_policies/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class FrequentQuestionsPage extends StatelessWidget {
  const FrequentQuestionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> listContent = frequentQuestions;

    return Scaffold(
      persistentFooterAlignment: AlignmentDirectional.bottomCenter,
      persistentFooterButtons: [
        SizedBox(
          width: context.sp(300),
          child: PrimaryButton(
            onTap: () async {
              final url = 'https://felicitup.com/guia-de-inicio/';
              final link = Uri.parse(url);
              if (await canLaunchUrl(link)) {
                launchUrl(link, mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('No se puede abrir la URL')),
                );
              }
            },
            label: 'Visitar pagina web',
            isActive: true,
          ),
        ),
      ],
      body: SizedBox(
        height: context.fullHeight,
        width: context.fullWidth,
        child: SafeArea(
          child: Column(
            children: [
              CollapsedHeader(
                title: 'Preguntas Frecuentes',
                onPressed: () => context.go(RouterPaths.felicitupsDashboard),
              ),
              SizedBox(height: context.sp(24)),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: context.sp(12)),
                  itemCount: listContent.length,
                  itemBuilder:
                      (_, index) => ScrollButton(
                        title: listContent[index]['title'] ?? '',
                        content: listContent[index]['content'] ?? '',
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
