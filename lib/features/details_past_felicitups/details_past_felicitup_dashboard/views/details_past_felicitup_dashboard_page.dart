import 'dart:async';

import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/details_past_felicitups/details_past_felicitup_dashboard/widgets/widgets.dart';
import 'package:felicitup_app/features/details_past_felicitups/details_past_felicitups.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DetailsPastFelicitupDashboardPage extends StatefulWidget {
  const DetailsPastFelicitupDashboardPage({
    super.key,
    required this.childView,
    required this.fromNotification,
  });

  final Widget childView;
  final bool fromNotification;

  @override
  State<DetailsPastFelicitupDashboardPage> createState() => _DetailsPastFelicitupDashboardPageState();
}

class _DetailsPastFelicitupDashboardPageState extends State<DetailsPastFelicitupDashboardPage> {
  @override
  void initState() {
    super.initState();
    if (widget.fromNotification) {
      final felicitup = context.read<DetailsPastFelicitupDashboardBloc>().state.felicitup;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<DetailsPastFelicitupDashboardBloc>().add(DetailsPastFelicitupDashboardEvent.changeCurrentIndex(
            (felicitup?.finalVideoUrl?.isNotEmpty ?? false) ? 2 : 3));
      });
    }
  }

  final List<Widget> pagesComplete = [
    MainPastFelicitupPage(),
    ChatPastFelicitupPage(),
    PeoplePastFelicitupPage(),
    VideoPastFelicitupPage(),
  ];

  final List<Widget> pagesWithoutVideo = [
    MainPastFelicitupPage(),
    ChatPastFelicitupPage(),
    PeoplePastFelicitupPage(),
  ];

  List<IconData> icons = [
    Icons.card_giftcard_outlined,
    Icons.chat_outlined,
    Icons.people_outline,
    Icons.camera_alt_outlined,
  ];

  List<IconData> iconsWithoutVideo = [
    Icons.card_giftcard_outlined,
    Icons.chat_outlined,
    Icons.people_outline,
  ];

  List<IconData> selectedIcons = [
    Icons.card_giftcard,
    Icons.chat,
    Icons.people,
    Icons.camera_alt,
  ];

  List<IconData> selectedIconsWithoutVideo = [
    Icons.card_giftcard,
    Icons.chat,
    Icons.people,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<DetailsPastFelicitupDashboardBloc, DetailsPastFelicitupDashboardState>(
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
            context
                .read<DetailsPastFelicitupDashboardBloc>()
                .add(DetailsPastFelicitupDashboardEvent.asignCurrentChat(''));
            context.go(RouterPaths.felicitupsDashboard);
          }
        },
        child: BlocBuilder<DetailsPastFelicitupDashboardBloc, DetailsPastFelicitupDashboardState>(
          buildWhen: (previous, current) => previous.felicitup != current.felicitup,
          builder: (_, state) {
            final felicitup = state.felicitup;

            return felicitup != null
                ? Scaffold(
                    backgroundColor: context.colors.background,
                    body: SafeArea(
                      child: Column(
                        children: [
                          PastHeader(felicitup: felicitup),
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
                                  (felicitup.finalVideoUrl?.isEmpty ?? false)
                                      ? pagesWithoutVideo.length
                                      : pagesComplete.length,
                                  (index) => IconButton(
                                    onPressed: () {
                                      detailsPastFelicitupNavigatorKey.currentContext!
                                          .read<DetailsPastFelicitupDashboardBloc>()
                                          .add(DetailsPastFelicitupDashboardEvent.changeCurrentIndex(index));

                                      switch (index) {
                                        case 0:
                                          context.go(RouterPaths.mainPastFelicitup);
                                          detailsPastFelicitupNavigatorKey.currentContext!
                                              .read<DetailsPastFelicitupDashboardBloc>()
                                              .add(DetailsPastFelicitupDashboardEvent.asignCurrentChat(''));
                                          break;
                                        case 1:
                                          context.go(RouterPaths.chatPastFelicitup);
                                          detailsPastFelicitupNavigatorKey.currentContext!
                                              .read<DetailsPastFelicitupDashboardBloc>()
                                              .add(
                                                DetailsPastFelicitupDashboardEvent.asignCurrentChat(felicitup.chatId),
                                              );
                                          break;
                                        case 2:
                                          context.go(RouterPaths.peoplePastFelicitup);
                                          detailsPastFelicitupNavigatorKey.currentContext!
                                              .read<DetailsPastFelicitupDashboardBloc>()
                                              .add(DetailsPastFelicitupDashboardEvent.asignCurrentChat(''));
                                          break;
                                        case 3:
                                          context.go(RouterPaths.videoPastFelicitup);
                                          detailsPastFelicitupNavigatorKey.currentContext!
                                              .read<DetailsPastFelicitupDashboardBloc>()
                                              .add(DetailsPastFelicitupDashboardEvent.asignCurrentChat(''));
                                          break;

                                        default:
                                      }
                                    },
                                    icon: BlocBuilder<DetailsPastFelicitupDashboardBloc,
                                        DetailsPastFelicitupDashboardState>(
                                      builder: (_, state) {
                                        final currentIndex = state.currentIndex;

                                        return Container(
                                          padding: EdgeInsets.all(context.sp(10)),
                                          alignment: Alignment.center,
                                          child: Icon(
                                            (felicitup.finalVideoUrl?.isEmpty ?? false)
                                                ? (currentIndex == index)
                                                    ? selectedIconsWithoutVideo[index]
                                                    : iconsWithoutVideo[index]
                                                : (currentIndex == index)
                                                    ? selectedIcons[index]
                                                    : icons[index],
                                            color: context.colors.orange,
                                            size: currentIndex == index ? context.sp(30) : context.sp(20),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
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
