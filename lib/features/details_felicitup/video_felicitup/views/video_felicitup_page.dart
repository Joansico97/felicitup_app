import 'dart:async';

import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/details_felicitup/details_felicitup.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class VideoFelicitupPage extends StatefulWidget {
  const VideoFelicitupPage({super.key});

  @override
  State<VideoFelicitupPage> createState() => _VideoFelicitupPageState();
}

class _VideoFelicitupPageState extends State<VideoFelicitupPage> {
  void _startTimer(BuildContext context) {
    // Inicia el temporizador con una duración, por ejemplo, 60 segundos
    context.read<AppBloc>().add(
      const AppEvent.startGlobalTimer(duration: Duration(seconds: 180)),
    );
  }

  @override
  void initState() {
    super.initState();
    final felicitup =
        context.read<DetailsFelicitupDashboardBloc>().state.felicitup;
    detailsFelicitupNavigatorKey.currentContext!
        .read<DetailsFelicitupDashboardBloc>()
        .add(DetailsFelicitupDashboardEvent.changeCurrentIndex(3));
    context.read<VideoFelicitupBloc>().add(
      VideoFelicitupEvent.startListening(felicitup?.id ?? ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VideoFelicitupBloc, VideoFelicitupState>(
      listenWhen:
          (previous, current) => previous.isLoading != current.isLoading,
      listener: (_, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }
        if (state.showModal) {
          unawaited(
            showConfirmModal(
              title: 'Tu video está siendo procesado',
              content: 'Te avisaremos cuando esté listo para que puedas verlo',
              onAccept: () async {},
            ),
          );
        }
      },
      child: BlocBuilder<
        DetailsFelicitupDashboardBloc,
        DetailsFelicitupDashboardState
      >(
        buildWhen:
            (previous, current) => previous.felicitup != current.felicitup,
        builder: (_, state) {
          final felicitup = state.felicitup;
          final currentUser = context.read<AppBloc>().state.currentUser;

          return PopScope(
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) {
                context.go(RouterPaths.felicitupsDashboard);
              }
            },
            child: Scaffold(
              backgroundColor: context.colors.background,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              floatingActionButton: Padding(
                padding: EdgeInsets.symmetric(horizontal: context.sp(30)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (felicitup!.createdBy == currentUser!.id)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              BlocBuilder<AppBloc, AppState>(
                                builder: (_, state) {
                                  return FloatingActionButton.extended(
                                    heroTag: '3',
                                    onPressed:
                                        !state.isGlobalTimerActive
                                            ? () => showConfirmModal(
                                              title:
                                                  'Estás seguro de querer mixear los videos de ${felicitup.reason} de ${felicitup.owner.first.name}?',
                                              onAccept: () async {
                                                final listVideos =
                                                    felicitup.invitedUserDetails
                                                        .map(
                                                          (e) =>
                                                              e
                                                                  .videoData
                                                                  ?.videoUrl,
                                                        )
                                                        .where(
                                                          (url) =>
                                                              url != null &&
                                                              url.isNotEmpty,
                                                        )
                                                        .cast<String>()
                                                        .toList();

                                                if (context.mounted) {
                                                  _startTimer(context);

                                                  context
                                                      .read<
                                                        VideoFelicitupBloc
                                                      >()
                                                      .add(
                                                        VideoFelicitupEvent.mergeVideos(
                                                          felicitup.id,
                                                          listVideos,
                                                        ),
                                                      );
                                                }
                                              },
                                            )
                                            : null,
                                    backgroundColor:
                                        !state.isGlobalTimerActive
                                            ? context.colors.orange
                                            : context.colors.grey,
                                    label: Row(
                                      children: [
                                        Icon(
                                          Icons.cameraswitch_rounded,
                                          color: context.colors.white,
                                        ),
                                        SizedBox(width: context.sp(6)),
                                        Text(
                                          !state.isGlobalTimerActive
                                              ? 'Mix'
                                              : 'Mix${state.globalTimerRemaining != null ? ' (${state.globalTimerRemaining!.inSeconds})' : ''}',
                                          style: context.styles.smallText
                                              .copyWith(
                                                color: context.colors.white,
                                              ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            FloatingActionButton.extended(
                              heroTag: '4',
                              onPressed:
                                  felicitup.finalVideoUrl != null &&
                                          felicitup.finalVideoUrl!.isNotEmpty
                                      ? () {
                                        context.go(
                                          RouterPaths.videoEditor,
                                          extra: {
                                            'felicitupId': felicitup.id,
                                            'videoUrl':
                                                felicitup.finalVideoUrl ?? '',
                                          },
                                        );
                                      }
                                      : null,
                              backgroundColor:
                                  felicitup.finalVideoUrl != null &&
                                          felicitup.finalVideoUrl!.isNotEmpty
                                      ? context.colors.orange
                                      : context.colors.grey,
                              label: Row(
                                children: [
                                  Icon(
                                    Icons.play_arrow,
                                    color: context.colors.white,
                                  ),
                                  SizedBox(width: context.sp(6)),
                                  Text(
                                    'Ver video',
                                    style: context.styles.smallText.copyWith(
                                      color: context.colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: context.sp(12)),
                    FloatingActionButton.extended(
                      heroTag: '9',
                      onPressed:
                          () => context.go(
                            RouterPaths.videoEditor,
                            extra: {
                              'felicitupId': felicitup.id,
                              'videoUrl': '',
                            },
                          ),
                      backgroundColor: context.colors.orange,
                      label: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.sp(60),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.videocam_rounded,
                              color: context.colors.white,
                            ),
                            SizedBox(width: context.sp(6)),
                            Text(
                              'Grabar video',
                              style: context.styles.smallText.copyWith(
                                color: context.colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              body: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: context.sp(40),
                      width: context.sp(113),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(context.sp(20)),
                        color: context.colors.white,
                      ),
                      child: Text(
                        'Vídeo',
                        style: context.styles.smallText.copyWith(
                          color: context.colors.softOrange,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.sp(22)),
                  BlocBuilder<VideoFelicitupBloc, VideoFelicitupState>(
                    builder: (_, state) {
                      final invitedUsers = state.invitedUsers;

                      return Column(
                        children: [
                          ...List.generate(
                            invitedUsers?.length ?? 0,
                            (index) => Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    context.go(
                                      RouterPaths.videoEditor,
                                      extra: {
                                        'felicitupId': felicitup.id,
                                        'videoUrl':
                                            invitedUsers?[index]
                                                .videoData
                                                ?.videoUrl ??
                                            '',
                                      },
                                    );
                                  },
                                  child: DetailsRow(
                                    prefixChild: Row(
                                      children: [
                                        Container(
                                          height: context.sp(23),
                                          width: context.sp(23),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: context.colors.lightGrey,
                                          ),
                                          child: Text(
                                            invitedUsers?[index].name![0]
                                                    .toUpperCase() ??
                                                '',
                                            style: context.styles.subtitle,
                                          ),
                                        ),
                                        SizedBox(width: context.sp(14)),
                                        Text(
                                          invitedUsers?[index].name ?? '',
                                          style: context.styles.smallText
                                              .copyWith(
                                                color:
                                                    invitedUsers?[index]
                                                                .videoData
                                                                ?.videoUrl
                                                                ?.isEmpty ??
                                                            false
                                                        ? context.colors.text
                                                        : context
                                                            .colors
                                                            .primary,
                                              ),
                                        ),
                                      ],
                                    ),
                                    sufixChild: Container(
                                      padding: EdgeInsets.all(context.sp(5)),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            invitedUsers?[index]
                                                        .videoData
                                                        ?.videoUrl
                                                        ?.isNotEmpty ??
                                                    false
                                                ? context.colors.softOrange
                                                : context.colors.text,
                                      ),
                                      child: Icon(
                                        Icons.play_arrow,
                                        color:
                                            invitedUsers?[index]
                                                        .videoData
                                                        ?.videoUrl
                                                        ?.isNotEmpty ??
                                                    false
                                                ? Colors.white
                                                : context.colors.text,
                                        size: context.sp(11),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: context.sp(12)),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
