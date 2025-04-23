import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/felicitups_dashboard/bloc/felicitups_dashboard_bloc.dart';
import 'package:felicitup_app/features/felicitups_dashboard/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class PastFelicitupWidget extends StatelessWidget {
  const PastFelicitupWidget({
    super.key,
    required this.felicitup,
    required this.date,
  });

  final FelicitupModel felicitup;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(20),
        vertical: context.sp(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: context.sp(95),
            padding: EdgeInsets.all(context.sp(10)),
            child: Column(
              children: [
                SizedBox(height: context.sp(12)),
                Text(
                  felicitup.owner.length > 2
                      ? '${felicitup.owner[0].name.split(' ')[0]} y ${felicitup.owner.length - 1} más'
                      : felicitup.owner.length == 2
                      ? '${felicitup.owner[0].name.split(' ')[0]} y ${felicitup.owner[1].name.split(' ')[0]}'
                      : felicitup.owner[0].name.split(' ')[0],
                  style: context.styles.subtitle,
                ),
                SizedBox(height: context.sp(8)),
                Container(
                  height: context.sp(68),
                  width: context.sp(68),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.lightGrey,
                  ),
                  child: Text(
                    felicitup.owner[0].name[0],
                    style: context.styles.header2,
                  ),
                ),
                SizedBox(height: context.sp(8)),
                Text(
                  DateFormat('dd·MM·yyyy').format(date),
                  style: context.styles.smallText,
                ),
                SizedBox(height: context.sp(8)),
                SizedBox(
                  width: context.fullWidth,
                  child: Stack(
                    children: [
                      CircleIcon(color: context.colors.orange),
                      Row(
                        children: [
                          SizedBox(
                            // width: context.sizer.width(.03),
                            width: context.sp(15),
                          ),
                          CircleIcon(color: context.colors.orange),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(width: context.sp(30)),
                          CircleIcon(color: context.colors.orange),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(width: context.sp(45)),
                          CircleIcon(color: context.colors.orange),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: context.sp(200),
            padding: EdgeInsets.all(context.sp(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap:
                      () => context.go(
                        (felicitup.finalVideoUrl?.isNotEmpty ?? false)
                            ? RouterPaths.videoPastFelicitup
                            : RouterPaths.mainPastFelicitup,
                        extra: {'felicitupId': felicitup.id},
                      ),
                  child: Container(
                    height: context.sp(240),
                    width: context.sp(200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(context.sp(10)),
                      border: Border.all(
                        color: Colors.black.withAlpha((.18 * 255).toInt()),
                      ),
                    ),
                    child: Stack(
                      children: [
                        SizedBox(
                          height: context.sp(240),
                          width: context.sp(200),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(context.sp(10)),
                            child: Image.network(
                              felicitup.thumbnailUrl ??
                                  'https://picsum.photos/450/600',
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                        Positioned(
                          top: context.sp(95),
                          right: context.sp(65),
                          child: Container(
                            height: context.sp(50),
                            width: context.sp(50),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: context.colors.white.valueOpacity(.6),
                                width: context.sp(5),
                              ),
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              color: context.colors.white.valueOpacity(.6),
                              size: context.sp(25),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    BlocBuilder<
                      FelicitupsDashboardBloc,
                      FelicitupsDashboardState
                    >(
                      builder: (_, state) {
                        final user = context.read<AppBloc>().state.currentUser;
                        return IconButton(
                          onPressed:
                              () => context.read<FelicitupsDashboardBloc>().add(
                                FelicitupsDashboardEvent.setLike(
                                  felicitup.id,
                                  user?.id ?? '',
                                ),
                              ),
                          icon: Icon(
                            felicitup.likes!.contains(user?.id ?? '')
                                ? Icons.favorite
                                : Icons.favorite_outline,
                            color:
                                felicitup.likes!.contains(user?.id ?? '')
                                    ? context.colors.error
                                    : context.colors.black.valueOpacity(.5),
                            size: context.sp(20),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      onPressed:
                          () => context.go(
                            RouterPaths.chatPastFelicitup,
                            extra: {'felicitupId': felicitup.id},
                          ),
                      icon: Icon(
                        Icons.message_outlined,
                        color: Colors.black.withAlpha((.5 * 255).toInt()),
                        size: context.sp(20),
                      ),
                    ),
                    Visibility(
                      visible: false,
                      child: IconButton(
                        onPressed: () {
                          // ref.read(homeEventsProvider.notifier).toggleShowButton();
                          commoBottomModal(
                            context: context,
                            body: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Elige a donde deseas compartir tu felicitup',
                                    style: context.styles.paragraph,
                                  ),
                                ),
                                SizedBox(height: context.sp(20)),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        final whatsAppUrl = Uri.parse(
                                          "whatsapp://send?text=${Uri.encodeComponent('text')}",
                                        );
                                        if (await canLaunchUrl(whatsAppUrl)) {
                                          await launchUrl(whatsAppUrl);
                                        } else {
                                          ScaffoldMessenger.of(
                                            rootNavigatorKey.currentContext!,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'No se pudo lanzar WhatsApp',
                                                style: context.styles.paragraph
                                                    .copyWith(
                                                      color:
                                                          context.colors.white,
                                                    ),
                                              ),
                                              duration: const Duration(
                                                seconds: 2,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        height: context.sp(50),
                                        width: context.sp(50),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: context.sp(10),
                                        ),
                                        margin: EdgeInsets.only(
                                          right: context.sp(10),
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: context.colors.primary,
                                          ),
                                          color: Colors.white.withAlpha(
                                            (.5 * 255).toInt(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        final Uri url = Uri.parse(
                                          'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent('https://felicitup.com/video-section/https://firebasestorage.googleapis.com/v0/b/felicitup-prod.appspot.com/o/videos%2Fraj4iPOUV9QeRYUYEFCb%2F3nppj2XmKJUfhCxp8ROfXKxsC1I2.mp4?alt=media&token=e6774836-5719-41b3-94c3-4c211a4d48c8&fbclid=IwY2xjawIyoCBleHRuA2FlbQIxMAABHTdRNmlIzDd5xyk_oBez5YsXcNljHpx7p93TYakjcDn3mxJjI9FNUnbD7g_aem_2W2Yutt3E_7yJc7udAp79w')}',
                                        );

                                        if (!await launchUrl(
                                          url,
                                          mode: LaunchMode.externalApplication,
                                        )) {
                                          throw Exception(
                                            'Could not launch $url',
                                          );
                                        }
                                      },
                                      child: Container(
                                        height: context.sp(50),
                                        width: context.sp(50),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: context.sp(10),
                                        ),
                                        margin: EdgeInsets.only(
                                          right: context.sp(10),
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: context.colors.primary,
                                          ),
                                          color: Colors.white.withAlpha(
                                            (.5 * 255).toInt(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        height: context.sp(50),
                                        width: context.sp(50),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: context.sp(10),
                                        ),
                                        margin: EdgeInsets.only(
                                          right: context.sp(10),
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: context.colors.primary,
                                          ),
                                          color: Colors.white.withAlpha(
                                            (.5 * 255).toInt(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: context.sp(20)),
                              ],
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.share,
                          color: Colors.black.withAlpha((.5 * 255).toInt()),
                          size: context.sp(20),
                        ),
                      ),
                    ),
                  ],
                ),
                RichText(
                  text: TextSpan(
                    text:
                        felicitup.owner.length > 2
                            ? '#felicitup${felicitup.owner[0].name.split(' ')[0]}${felicitup.owner.length - 1}'
                            : '#felicitup${felicitup.owner[0].name.split(' ')[0]}',
                    style: context.styles.smallText,
                    children: [
                      TextSpan(
                        text: ' ${felicitup.message ?? ''}',
                        style: context.styles.smallText,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.sp(8)),
                GestureDetector(
                  onTap:
                      () => context.go(
                        RouterPaths.mainPastFelicitup,
                        extra: {'felicitupId': felicitup.id},
                      ),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Text('Ver más', style: context.styles.smallText),
                          Container(
                            height: context.sp(1),
                            width: context.sp(45),
                            color: Colors.black,
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.black,
                        size: context.sp(12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
