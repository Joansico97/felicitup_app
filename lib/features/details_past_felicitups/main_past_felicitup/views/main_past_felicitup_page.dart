import 'dart:async';

import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/details_past_felicitups/details_past_felicitups.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MainPastFelicitupPage extends StatelessWidget {
  const MainPastFelicitupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<MainPastFelicitupBloc, MainPastFelicitupState>(
      listenWhen:
          (previous, current) => previous.isLoading != current.isLoading,
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
            context.go(RouterPaths.felicitupsDashboard);
          }
        },
        child: Scaffold(
          backgroundColor: context.colors.background,
          body: SizedBox(
            height: context.fullHeight,
            width: context.fullWidth,
            child: Stack(
              children: [
                Positioned(
                  top: -context.sp(70),
                  left: -context.sp(70),
                  child: Container(
                    height: context.sp(170),
                    width: context.sp(170),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.darkBlue,
                    ),
                  ),
                ),
                Positioned(
                  top: -context.sp(110),
                  right: -context.sp(110),
                  child: Container(
                    height: context.sp(260),
                    width: context.sp(260),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.orange,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -context.sp(150),
                  left: -context.sp(150),
                  child: Container(
                    height: context.sp(350),
                    width: context.sp(350),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFEE775A),
                    ),
                  ),
                ),
                BlocBuilder<
                  DetailsPastFelicitupDashboardBloc,
                  DetailsPastFelicitupDashboardState
                >(
                  builder: (_, state) {
                    final felicitup = state.felicitup;

                    return felicitup != null
                        ? SizedBox(
                          height: context.fullHeight,
                          width: context.fullWidth,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:
                                    felicitup.owner
                                        .map(
                                          (list) => Text(
                                            'Hola, ${list.name}',
                                            style: context.styles.subtitle,
                                          ),
                                        )
                                        .toList(),
                              ),
                              SizedBox(height: context.sp(24)),
                              Text(
                                '¡Felicitaciones!',
                                style: context.styles.header1,
                              ),
                              SizedBox(height: context.sp(24)),
                              Text(
                                felicitup.message ?? '',
                                textAlign: TextAlign.center,
                                style: context.styles.smallText,
                              ),
                              SizedBox(height: context.sp(24)),
                              Text(
                                'Tus amigos hicieron posible esta felicitup',
                                textAlign: TextAlign.center,
                                style: context.styles.paragraph,
                              ),
                              SizedBox(height: context.sp(24)),
                              (felicitup.finalVideoUrl?.isNotEmpty ?? false)
                                  ? SizedBox(
                                    width: context.sp(300),
                                    child: PrimaryButton(
                                      onTap: () {
                                        context.go(
                                          RouterPaths.videoPastFelicitup,
                                        );
                                        detailsPastFelicitupNavigatorKey
                                            .currentContext!
                                            .read<
                                              DetailsPastFelicitupDashboardBloc
                                            >()
                                            .add(
                                              DetailsPastFelicitupDashboardEvent.asignCurrentChat(
                                                '',
                                              ),
                                            );
                                        detailsPastFelicitupNavigatorKey
                                            .currentContext!
                                            .read<
                                              DetailsPastFelicitupDashboardBloc
                                            >()
                                            .add(
                                              DetailsPastFelicitupDashboardEvent.changeCurrentIndex(
                                                3,
                                              ),
                                            );
                                      },
                                      label: 'Ver Video',
                                      isActive: true,
                                    ),
                                  )
                                  : SizedBox(),
                            ],
                          ),
                        )
                        : SizedBox();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
