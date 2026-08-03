import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showDownloadAppModal({
  BuildContext? context,
  String? message,
}) async {
  final targetContext = context ?? rootNavigatorKey.currentContext!;

  return await showDialog<void>(
    context: targetContext,
    barrierDismissible: true,
    builder: (modalContext) {
      return Center(
        child: Container(
          width: modalContext.sp(420),
          margin: EdgeInsets.symmetric(
            horizontal: modalContext.sp(24),
          ),
          padding: EdgeInsets.only(
            top: modalContext.sp(24),
            left: modalContext.sp(24),
            right: modalContext.sp(24),
            bottom: modalContext.sp(20),
          ),
          decoration: BoxDecoration(
            color: modalContext.colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: modalContext.colors.black.valueOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: GestureDetector(
                    onTap: () => Navigator.of(modalContext).pop(),
                    child: Container(
                      padding: EdgeInsets.all(modalContext.sp(4)),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: modalContext.colors.orange,
                      ),
                      child: Icon(
                        Icons.close,
                        color: modalContext.colors.white,
                        size: modalContext.sp(18),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: modalContext.sp(8)),
                Container(
                  padding: EdgeInsets.all(modalContext.sp(16)),
                  decoration: BoxDecoration(
                    color: modalContext.colors.ligthOrange.valueOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.videocam_rounded,
                    color: modalContext.colors.orange,
                    size: modalContext.sp(40),
                  ),
                ),
                SizedBox(height: modalContext.sp(16)),
                Text(
                  'Descarga la App de Felicitup',
                  textAlign: TextAlign.center,
                  style: modalContext.styles.header1.copyWith(
                    color: modalContext.colors.orange,
                  ),
                ),
                SizedBox(height: modalContext.sp(12)),
                Text(
                  message ??
                      'Para poder grabar y subir tu video a esta Felicitup, debes hacerlo desde la App de Felicitup en tu dispositivo móvil.',
                  textAlign: TextAlign.center,
                  style: modalContext.styles.paragraph.copyWith(
                    color: modalContext.colors.text,
                  ),
                ),
                SizedBox(height: modalContext.sp(24)),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: modalContext.sp(48),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final Uri url = Uri.parse(
                            'https://play.google.com/store/apps/details?id=com.felicitup.felicitup_app&pcampaignid=web_share',
                          );
                          if (await canLaunchUrl(url)) {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: modalContext.colors.orange,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(modalContext.sp(24)),
                          ),
                        ),
                        icon: Icon(
                          Icons.android_rounded,
                          color: modalContext.colors.white,
                          size: modalContext.sp(22),
                        ),
                        label: Text(
                          'Descargar para Android',
                          style: modalContext.styles.buttons.copyWith(
                            color: modalContext.colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: modalContext.sp(12)),
                    SizedBox(
                      width: double.infinity,
                      height: modalContext.sp(48),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final Uri url = Uri.parse(
                            'https://apps.apple.com/co/app/felicitup/id6743689559',
                          );
                          if (await canLaunchUrl(url)) {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: modalContext.colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(modalContext.sp(24)),
                          ),
                        ),
                        icon: Icon(
                          Icons.apple_rounded,
                          color: modalContext.colors.white,
                          size: modalContext.sp(22),
                        ),
                        label: Text(
                          'Descargar para iOS',
                          style: modalContext.styles.buttons.copyWith(
                            color: modalContext.colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
