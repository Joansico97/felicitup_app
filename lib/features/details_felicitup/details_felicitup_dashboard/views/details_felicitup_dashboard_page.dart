import 'dart:async';

import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/details_felicitup/details_felicitup.dart';
import 'package:felicitup_app/features/details_felicitup/details_felicitup_dashboard/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DetailsFelicitupDashboardPage extends StatefulWidget {
  const DetailsFelicitupDashboardPage({
    super.key,
    required this.childView,
    required this.fromNotification,
  });

  final Widget childView;
  final bool fromNotification;

  @override
  State<DetailsFelicitupDashboardPage> createState() => _DetailsFelicitupDashboardPageState();
}

class _DetailsFelicitupDashboardPageState extends State<DetailsFelicitupDashboardPage> {
  @override
  void initState() {
    super.initState();

    if (widget.fromNotification) {
      final felicitup = context.read<DetailsFelicitupDashboardBloc>().state.felicitup;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context
            .read<DetailsFelicitupDashboardBloc>()
            .add(DetailsFelicitupDashboardEvent.changeCurrentIndex((felicitup?.hasVideo ?? false) ? 3 : 4));
      });
    }
    final currentUser = context.read<AppBloc>().state.currentUser;
    context.read<InfoFelicitupBloc>().add(InfoFelicitupEvent.loadFriendsData(currentUser?.matchList ?? []));
    context.read<PeopleFelicitupBloc>().add(PeopleFelicitupEvent.loadFriendsData(currentUser?.matchList ?? []));
  }

  final List<Widget> pagesComplete = [
    InfoFelicitupPage(),
    MessageFelicitupPage(),
    PeopleFelicitupPage(),
    VideoFelicitupPage(),
    BoteFelicitupPage(),
  ];

  final List<Widget> pagesWithoutBote = [
    InfoFelicitupPage(),
    MessageFelicitupPage(),
    PeopleFelicitupPage(),
    VideoFelicitupPage(),
  ];

  final List<Widget> pagesWithoutVideo = [
    InfoFelicitupPage(),
    MessageFelicitupPage(),
    PeopleFelicitupPage(),
    BoteFelicitupPage(),
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
  Widget build(BuildContext context) {
    return BlocListener<DetailsFelicitupDashboardBloc, DetailsFelicitupDashboardState>(
      listenWhen: (previous, current) => previous.isLoading != current.isLoading,
      listener: (_, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }
      },
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            context.read<MessageFelicitupBloc>().add(MessageFelicitupEvent.asignCurrentChat(''));
            context.go(RouterPaths.felicitupsDashboard);
          }
        },
        child: BlocBuilder<DetailsFelicitupDashboardBloc, DetailsFelicitupDashboardState>(
          buildWhen: (previous, current) => previous.felicitup != current.felicitup,
          builder: (_, state) {
            final felicitup = state.felicitup;

            return felicitup != null
                ? Scaffold(
                    backgroundColor: context.colors.background,
                    body: SafeArea(
                      child: Column(
                        children: [
                          DetailsHeader(felicitup: felicitup),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: context.sp(24)),
                              child: widget.childView,
                            ),
                          ),
                          Container(
                            height: context.sp(60),
                            width: context.sp(335),
                            margin: EdgeInsets.symmetric(vertical: context.sp(20)),
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
                                    onPressed: () async {
                                      detailsFelicitupNavigatorKey.currentContext!
                                          .read<DetailsFelicitupDashboardBloc>()
                                          .add(DetailsFelicitupDashboardEvent.changeCurrentIndex(index));
                                      switch (index) {
                                        case 0:
                                          detailsFelicitupNavigatorKey.currentContext!.go(RouterPaths.infoFelicitup);
                                          context
                                              .read<DetailsFelicitupDashboardBloc>()
                                              .add(DetailsFelicitupDashboardEvent.asignCurrentChat(''));
                                          break;
                                        case 1:
                                          detailsFelicitupNavigatorKey.currentContext!.go(RouterPaths.messageFelicitup);
                                          context
                                              .read<DetailsFelicitupDashboardBloc>()
                                              .add(DetailsFelicitupDashboardEvent.asignCurrentChat(felicitup.chatId));
                                          break;
                                        case 2:
                                          detailsFelicitupNavigatorKey.currentContext!.go(RouterPaths.peopleFelicitup);
                                          context
                                              .read<DetailsFelicitupDashboardBloc>()
                                              .add(DetailsFelicitupDashboardEvent.asignCurrentChat(''));
                                          break;
                                        case 3:
                                          detailsFelicitupNavigatorKey.currentContext!.go(RouterPaths.videoFelicitup);
                                          context
                                              .read<DetailsFelicitupDashboardBloc>()
                                              .add(DetailsFelicitupDashboardEvent.asignCurrentChat(''));
                                          break;
                                        case 4:
                                          detailsFelicitupNavigatorKey.currentContext!.go(RouterPaths.boteFelicitup);
                                          context
                                              .read<DetailsFelicitupDashboardBloc>()
                                              .add(DetailsFelicitupDashboardEvent.asignCurrentChat(''));
                                          break;
                                        default:
                                      }
                                    },
                                    icon: BlocBuilder<DetailsFelicitupDashboardBloc, DetailsFelicitupDashboardState>(
                                      builder: (_, state) {
                                        final currentIndex = state.currentIndex;

                                        return Container(
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
                                            size: currentIndex == index ? context.sp(30) : context.sp(20),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Scaffold(
                    backgroundColor: context.colors.background,
                    appBar: AppBar(
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          context.go(RouterPaths.felicitupsDashboard);
                        },
                      ),
                    ),
                  );
          },
        ),
      ),
    );
  }
}
