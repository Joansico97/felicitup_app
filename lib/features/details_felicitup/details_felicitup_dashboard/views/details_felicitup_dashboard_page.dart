import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/features/details_felicitup/details_felicitup.dart';
import 'package:felicitup_app/features/details_felicitup/details_felicitup_dashboard/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/models/models.dart';

class DetailsFelicitupDashboardPage extends StatefulWidget {
  const DetailsFelicitupDashboardPage({
    super.key,
    required this.childView,
    required this.fromNotification,
    this.chatId,
  });

  final Widget childView;
  final bool fromNotification;
  final String? chatId;

  @override
  State<DetailsFelicitupDashboardPage> createState() =>
      _DetailsFelicitupDashboardPageState();
}

class _DetailsFelicitupDashboardPageState
    extends State<DetailsFelicitupDashboardPage> {
  final List<Widget> pagesComplete = [
    const InfoFelicitupPage(),
    const MessageFelicitupPage(),
    const PeopleFelicitupPage(),
    const VideoFelicitupPage(),
    const BoteFelicitupPage(),
  ];

  final List<Widget> pagesWithoutBote = [
    const InfoFelicitupPage(),
    const MessageFelicitupPage(),
    const PeopleFelicitupPage(),
    const VideoFelicitupPage(),
  ];

  final List<Widget> pagesWithoutVideo = [
    const InfoFelicitupPage(),
    const MessageFelicitupPage(),
    const PeopleFelicitupPage(),
    const BoteFelicitupPage(),
  ];

  List<IconData> icons = [
    Icons.person_outline,
    Icons.chat_outlined,
    Icons.people_outline,
    Icons.camera_alt_outlined,
    Icons.attach_money_outlined,
  ];

  List<IconData> iconsWithoutBote = [
    Icons.person_outline,
    Icons.chat_outlined,
    Icons.people_outline,
    Icons.camera_alt_outlined,
  ];

  List<IconData> iconsWithoutVideo = [
    Icons.person_outline,
    Icons.chat_outlined,
    Icons.people_outline,
    Icons.attach_money_outlined,
  ];

  List<IconData> selectedIcons = [
    Icons.person,
    Icons.chat,
    Icons.people,
    Icons.camera_alt,
    Icons.attach_money,
  ];

  List<IconData> selectedIconsWithoutBote = [
    Icons.person,
    Icons.chat,
    Icons.people,
    Icons.camera_alt,
  ];

  List<IconData> selectedIconsWithoutVideo = [
    Icons.person,
    Icons.chat,
    Icons.people,
    Icons.attach_money,
  ];

  @override
  void initState() {
    super.initState();
    final currentUser = context.read<AppBloc>().state.currentUser;
    context.read<InfoFelicitupBloc>().add(
      InfoFelicitupEvent.loadFriendsData(currentUser?.matchList ?? []),
    );
    context.read<PeopleFelicitupBloc>().add(
      PeopleFelicitupEvent.loadFriendsData(currentUser?.matchList ?? []),
    );
  }

  void _onTabTapped(int index, FelicitupModel felicitup) {
    context.read<DetailsFelicitupDashboardBloc>().add(
      DetailsFelicitupDashboardEvent.changeCurrentIndex(index),
    );

    final navigatorContext = detailsFelicitupNavigatorKey.currentContext;
    if (navigatorContext == null) return;

    switch (index) {
      case 0:
        GoRouter.of(navigatorContext).go(RouterPaths.infoFelicitup);
        context.read<DetailsFelicitupDashboardBloc>().add(
          const DetailsFelicitupDashboardEvent.asignCurrentChat(''),
        );
        break;
      case 1:
        GoRouter.of(
          navigatorContext,
        ).go(RouterPaths.messageFelicitup, extra: {'chatId': ''});
        context.read<DetailsFelicitupDashboardBloc>().add(
          DetailsFelicitupDashboardEvent.asignCurrentChat(felicitup.chatId),
        );
        break;
      case 2:
        GoRouter.of(navigatorContext).go(RouterPaths.peopleFelicitup);
        context.read<DetailsFelicitupDashboardBloc>().add(
          const DetailsFelicitupDashboardEvent.asignCurrentChat(''),
        );
        break;
      case 3:
        if (!felicitup.hasVideo) {
          GoRouter.of(navigatorContext).go(RouterPaths.boteFelicitup);
        } else {
          GoRouter.of(navigatorContext).go(RouterPaths.videoFelicitup);
        }
        context.read<DetailsFelicitupDashboardBloc>().add(
          const DetailsFelicitupDashboardEvent.asignCurrentChat(''),
        );
        break;
      case 4:
        GoRouter.of(navigatorContext).go(RouterPaths.boteFelicitup);
        context.read<DetailsFelicitupDashboardBloc>().add(
          const DetailsFelicitupDashboardEvent.asignCurrentChat(''),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<
          DetailsFelicitupDashboardBloc,
          DetailsFelicitupDashboardState
        >(
          listenWhen: (p, c) =>
              p.felicitup == null &&
              c.felicitup != null &&
              c.initialSubRoute != null,
          listener: (context, state) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted &&
                  detailsFelicitupNavigatorKey.currentContext != null) {
                final subRoute = state.initialSubRoute!;
                int targetIndex = 0;

                if (subRoute == RouterPaths.infoFelicitup) targetIndex = 0;
                if (subRoute == RouterPaths.messageFelicitup) targetIndex = 1;
                if (subRoute == RouterPaths.peopleFelicitup) targetIndex = 2;
                if (subRoute == RouterPaths.videoFelicitup) {
                  targetIndex = (state.felicitup?.hasVideo ?? false) ? 3 : -1;
                } else if (subRoute == RouterPaths.boteFelicitup) {
                  targetIndex = (state.felicitup?.hasVideo ?? false) ? 4 : 3;
                }

                if (targetIndex != -1) {
                  _onTabTapped(targetIndex, state.felicitup!);
                }

                context.read<DetailsFelicitupDashboardBloc>().add(
                  const DetailsFelicitupDashboardEvent.clearInitialSubRoute(),
                );
              }
            });
          },
        ),
      ],
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            context.read<MessageFelicitupBloc>().add(
              MessageFelicitupEvent.asignCurrentChat(''),
            );
            context.go(RouterPaths.felicitupsDashboard);
          }
        },
        child:
            BlocBuilder<
              DetailsFelicitupDashboardBloc,
              DetailsFelicitupDashboardState
            >(
              buildWhen: (previous, current) =>
                  previous.felicitup != current.felicitup ||
                  previous.currentIndex != current.currentIndex ||
                  previous.status != current.status ||
                  previous.isLoading != current.isLoading,
              builder: (_, state) {
                final felicitup = state.felicitup;
                final currentIndex = state.currentIndex;

                if (state.isLoading) {
                  return Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(
                        color: context.colors.orange,
                      ),
                    ),
                  );
                }

                if (state.status == DetailsStatus.failure) {
                  return Scaffold(
                    body: Center(
                      child: Text(
                        state.errorMessage ??
                            'Error obteniendo información de la felicitup',
                        textAlign: TextAlign.center,
                        style: context.styles.header2,
                      ),
                    ),
                  );
                }

                if (felicitup == null) {
                  return Scaffold(
                    body: Center(
                      child: Text(
                        'Error obteniendo información de la felicitup',
                        textAlign: TextAlign.center,
                        style: context.styles.header2,
                      ),
                    ),
                  );
                }

                return Scaffold(
                  backgroundColor: context.colors.background,
                  body: SafeArea(
                    child: Column(
                      children: [
                        const DetailsHeader(),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.sp(24),
                            ),
                            child: widget.childView,
                          ),
                        ),
                        Container(
                          height: context.sp(60),
                          width: context.sp(335),
                          margin: EdgeInsets.symmetric(
                            vertical: context.sp(20),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(context.sp(40)),
                            color: context.colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: context.colors.black.valueOpacity(.5),
                                blurRadius: context.sp(10),
                                spreadRadius: context.sp(1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ...List.generate(
                                !felicitup.hasBote
                                    ? pagesWithoutBote.length
                                    : !felicitup.hasVideo
                                    ? pagesWithoutVideo.length
                                    : pagesComplete.length,
                                (index) => IconButton(
                                  onPressed: () =>
                                      _onTabTapped(index, felicitup),
                                  icon: Container(
                                    padding: EdgeInsets.all(context.sp(10)),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      currentIndex == index
                                          ? !felicitup.hasBote
                                                ? selectedIconsWithoutBote[index]
                                                : !felicitup.hasVideo
                                                ? selectedIconsWithoutVideo[index]
                                                : selectedIcons[index]
                                          : !felicitup.hasBote
                                          ? iconsWithoutBote[index]
                                          : !felicitup.hasVideo
                                          ? iconsWithoutVideo[index]
                                          : icons[index],
                                      color: context.colors.orange,
                                      size: currentIndex == index
                                          ? context.sp(30)
                                          : context.sp(20),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}
