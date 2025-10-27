import 'dart:io';

import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/felicitups_dashboard/bloc/felicitups_dashboard_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

enum MenuOption { opcion1, opcion2, opcion3 }

class PastFelicitupWidget extends StatelessWidget {
  const PastFelicitupWidget({super.key, required this.felicitup});

  final FelicitupModel felicitup;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(36),
        vertical: context.sp(14),
      ),
      child: Container(
        width: context.fullWidth,
        decoration: BoxDecoration(
          color: context.colors.white.valueOpacity(.5),
          borderRadius: BorderRadius.circular(context.sp(10)),
          boxShadow: [
            BoxShadow(
              color: context.colors.black.valueOpacity(.1),
              blurRadius: 12,
              offset: Offset(0, 2),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: context.fullWidth,
              padding: EdgeInsets.all(context.sp(5)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(context.sp(10)),
                  topRight: Radius.circular(context.sp(10)),
                ),
                color: context.colors.orange,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: context.sp(45),
                    width: context.sp(45),
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(context.sp(10)),
                      child: CommonNetworkImage(
                        imageUrl: felicitup.owner.first.userImg ?? '',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: context.sp(250),
                    child: felicitup.owner.length > 2
                        ? Column(
                            children: [
                              Text(
                                '${felicitup.reason} de',
                                style: context.styles.subtitle.copyWith(
                                  color: context.colors.white,
                                ),
                                maxLines: 1,
                              ),
                              Wrap(
                                children: [
                                  ...List.generate(
                                    felicitup.owner.length,
                                    (index) =>
                                        index != felicitup.owner.length - 1
                                        ? Text(
                                            '${felicitup.owner[index].name} ',
                                            style: context.styles.subtitle
                                                .copyWith(
                                                  color: context.colors.white,
                                                ),
                                          )
                                        : Text(
                                            'y ${felicitup.owner[index].name} ',
                                            style: context.styles.subtitle
                                                .copyWith(
                                                  color: context.colors.white,
                                                ),
                                          ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Text(
                            '${felicitup.reason} de ${felicitup.owner[0].name}',
                            style: context.styles.subtitle.copyWith(
                              color: context.colors.white,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            Container(
              width: context.fullWidth,
              padding: EdgeInsets.symmetric(
                horizontal: context.sp(24),
                vertical: context.sp(20),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(context.sp(10)),
                  bottomRight: Radius.circular(context.sp(10)),
                ),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => context.go(
                      (felicitup.finalVideoUrl?.isNotEmpty ?? false)
                          ? RouterPaths.videoPastFelicitup
                          : RouterPaths.mainPastFelicitup,
                      extra: {'felicitupId': felicitup.id},
                    ),
                    child: Container(
                      height: context.sp(260),
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
                            height: context.sp(260),
                            width: context.sp(200),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                context.sp(10),
                              ),
                              child: CommonNetworkImage(
                                imageUrl: felicitup.thumbnailUrl ?? '',
                              ),
                            ),
                          ),
                          Align(
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
                          final user = context
                              .read<AppBloc>()
                              .state
                              .currentUser;
                          return IconButton(
                            onPressed: () =>
                                context.read<FelicitupsDashboardBloc>().add(
                                  FelicitupsDashboardEvent.setLike(
                                    felicitup.id,
                                    user?.id ?? '',
                                  ),
                                ),
                            icon: Icon(
                              felicitup.likes!.contains(user?.id ?? '')
                                  ? Icons.favorite
                                  : Icons.favorite_outline,
                              color: felicitup.likes!.contains(user?.id ?? '')
                                  ? context.colors.error
                                  : context.colors.black.valueOpacity(.5),
                              size: context.sp(20),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        onPressed: () => context.go(
                          RouterPaths.chatPastFelicitup,
                          extra: {'felicitupId': felicitup.id},
                        ),
                        icon: Icon(
                          Icons.message_outlined,
                          color: Colors.black.withAlpha((.5 * 255).toInt()),
                          size: context.sp(20),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final encoded =
                              'http://play.felicitup.hq/index.html?id=${felicitup.id}}';

                          final Uri url = Uri.parse(
                            "whatsapp://send?text=$encoded",
                          );

                          if (await canLaunchUrl(url)) {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          } else {
                            const playStore =
                                "https://play.google.com/store/apps/details?id=com.whatsapp";
                            const appStore =
                                "https://apps.apple.com/app/whatsapp-messenger/id310633997";

                            await launchUrl(
                              Uri.parse(
                                Platform.isAndroid ? playStore : appStore,
                              ),
                            );
                          }
                        },
                        icon: Icon(
                          Icons.share,
                          color: Colors.black.withAlpha((.5 * 255).toInt()),
                          size: context.sp(20),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => context.go(
                          RouterPaths.mainPastFelicitup,
                          extra: {'felicitupId': felicitup.id},
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Ver más',
                              style: context.styles.smallText.copyWith(
                                decoration: TextDecoration.underline,
                                decorationThickness: context.sp(1.5),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.black,
                              size: context.sp(12),
                            ),
                          ],
                        ),
                      ),
                      Theme(
                        data: ThemeData(
                          popupMenuTheme: PopupMenuThemeData(
                            color: context.colors.grey,
                            elevation: context.sp(8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                context.sp(8),
                              ),
                            ),
                          ),
                        ),
                        child: PopupMenuButton<MenuOption>(
                          icon: Icon(Icons.more_vert),
                          onSelected: (MenuOption result) {
                            switch (result) {
                              case MenuOption.opcion1:
                                showConfirmModal(
                                  title: 'Eliminar felicitup',
                                  content:
                                      '¿Estás seguro de eliminar esta felicitup? Si la eliminas no podrás recuperarla.',
                                  onAccept: () async {
                                    context.read<FelicitupsDashboardBloc>().add(
                                      FelicitupsDashboardEvent.deletePastFelicitup(
                                        felicitupId: felicitup.id,
                                      ),
                                    );
                                  },
                                );
                                break;
                              case MenuOption.opcion2:
                                break;
                              case MenuOption.opcion3:
                                break;
                            }
                          },
                          itemBuilder: (_) {
                            return [
                              PopupMenuItem(
                                value: MenuOption.opcion1,
                                child: Text(
                                  'Eliminar felicitup',
                                  style: context.styles.paragraph,
                                ),
                              ),
                            ];
                          },
                        ),
                      ),
                    ],
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
