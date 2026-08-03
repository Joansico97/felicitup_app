import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/features/details_felicitup/details_felicitup.dart';
import 'package:felicitup_app/features/details_felicitup/details_felicitup_dashboard/widgets/widgets.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:felicitup_app/helpers/facebook_analytics_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DetailsFelicitupDashboardWebPage extends StatefulWidget {
  const DetailsFelicitupDashboardWebPage({
    super.key,
    required this.childView,
    required this.fromNotification,
    this.chatId,
  });

  final Widget childView;
  final bool fromNotification;
  final String? chatId;

  @override
  State<DetailsFelicitupDashboardWebPage> createState() =>
      _DetailsFelicitupDashboardWebPageState();
}

class _DetailsFelicitupDashboardWebPageState
    extends State<DetailsFelicitupDashboardWebPage> {
  @override
  void initState() {
    super.initState();
    FacebookAnalyticsHelper().trackViewContent();

    if (widget.fromNotification) {
      final felicitup = context
          .read<DetailsFelicitupDashboardBloc>()
          .state
          .felicitup;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<DetailsFelicitupDashboardBloc>().add(
              DetailsFelicitupDashboardEvent.changeCurrentIndex(
                (felicitup?.hasVideo ?? false) ? 3 : 4,
              ),
            );
      });
    }
    final currentUser = context.read<AppBloc>().state.currentUser;
    context.read<InfoFelicitupBloc>().add(
          InfoFelicitupEvent.loadFriendsData(currentUser?.matchList ?? []),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      DetailsFelicitupDashboardBloc,
      DetailsFelicitupDashboardState
    >(
      builder: (context, state) {
        final felicitup = state.felicitup;
        final currentIndex = state.currentIndex;

        if (felicitup == null) {
          return Scaffold(
            backgroundColor: context.colors.background,
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final bool hasVideo = felicitup.hasVideo;
        final bool hasBote = felicitup.hasBote;

        return Scaffold(
          backgroundColor: context.colors.background,
          body: Row(
            children: [
              // Left Sidebar Menu (exclusive for Web view)
              Container(
                width: context.sp(280),
                decoration: BoxDecoration(
                  color: context.colors.white,
                  border: Border(
                    right: BorderSide(
                      color: context.colors.otherGrey,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: context.sp(32)),
                    Center(
                      child: InkWell(
                        onTap: () {
                          context.read<MessageFelicitupBloc>().add(
                                const MessageFelicitupEvent.asignCurrentChat(''),
                              );
                          context.go(RouterPaths.felicitupsDashboard);
                        },
                        child: Image.asset(
                          Assets.images.logoLetter.path,
                          width: context.sp(180),
                        ),
                      ),
                    ),
                    SizedBox(height: context.sp(24)),

                    _WebSidebarItem(
                      label: 'Volver a Felicitups',
                      icon: Icons.arrow_back,
                      isActive: false,
                      onTap: () {
                        context.read<MessageFelicitupBloc>().add(
                              const MessageFelicitupEvent.asignCurrentChat(''),
                            );
                        context.go(RouterPaths.felicitupsDashboard);
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.sp(16)),
                      child: Divider(color: context.colors.otherGrey),
                    ),

                    // Option 0: Información
                    _WebSidebarItem(
                      label: 'Información',
                      icon: currentIndex == 0 ? Icons.person : Icons.person_outline,
                      isActive: currentIndex == 0,
                      onTap: () {
                        context.read<DetailsFelicitupDashboardBloc>().add(
                              const DetailsFelicitupDashboardEvent.changeCurrentIndex(0),
                            );
                        context.read<DetailsFelicitupDashboardBloc>().add(
                              const DetailsFelicitupDashboardEvent.asignCurrentChat(''),
                            );
                        detailsFelicitupNavigatorKey.currentContext?.go(
                          RouterPaths.infoFelicitup,
                        );
                      },
                    ),

                    // Option 1: Mensajes
                    _WebSidebarItem(
                      label: 'Mensajes',
                      icon: currentIndex == 1 ? Icons.chat : Icons.chat_outlined,
                      isActive: currentIndex == 1,
                      onTap: () {
                        context.read<DetailsFelicitupDashboardBloc>().add(
                              const DetailsFelicitupDashboardEvent.changeCurrentIndex(1),
                            );
                        context.read<DetailsFelicitupDashboardBloc>().add(
                              DetailsFelicitupDashboardEvent.asignCurrentChat(
                                felicitup.chatId,
                              ),
                            );
                        detailsFelicitupNavigatorKey.currentContext?.go(
                          RouterPaths.messageFelicitup,
                          extra: {'chatId': ''},
                        );
                      },
                    ),

                    // Option 2: Personas
                    _WebSidebarItem(
                      label: 'Personas',
                      icon: currentIndex == 2 ? Icons.people : Icons.people_outline,
                      isActive: currentIndex == 2,
                      onTap: () {
                        context.read<DetailsFelicitupDashboardBloc>().add(
                              const DetailsFelicitupDashboardEvent.changeCurrentIndex(2),
                            );
                        context.read<DetailsFelicitupDashboardBloc>().add(
                              const DetailsFelicitupDashboardEvent.asignCurrentChat(''),
                            );
                        detailsFelicitupNavigatorKey.currentContext?.go(
                          RouterPaths.peopleFelicitup,
                        );
                      },
                    ),

                    // Option 3: Vídeo (if hasVideo is true)
                    if (hasVideo)
                      _WebSidebarItem(
                        label: 'Vídeo',
                        icon: currentIndex == 3 ? Icons.camera_alt : Icons.camera_alt_outlined,
                        isActive: currentIndex == 3,
                        onTap: () {
                          context.read<DetailsFelicitupDashboardBloc>().add(
                                const DetailsFelicitupDashboardEvent.changeCurrentIndex(3),
                              );
                          context.read<DetailsFelicitupDashboardBloc>().add(
                                const DetailsFelicitupDashboardEvent.asignCurrentChat(''),
                              );
                          detailsFelicitupNavigatorKey.currentContext?.go(
                            RouterPaths.videoFelicitup,
                          );
                        },
                      ),

                    // Option 3 or 4: Bote (if hasBote is true)
                    if (hasBote)
                      _WebSidebarItem(
                        label: 'Bote',
                        icon: (!hasVideo ? currentIndex == 3 : currentIndex == 4)
                            ? Icons.attach_money
                            : Icons.attach_money_outlined,
                        isActive: !hasVideo ? currentIndex == 3 : currentIndex == 4,
                        onTap: () {
                          final targetIndex = !hasVideo ? 3 : 4;
                          context.read<DetailsFelicitupDashboardBloc>().add(
                                DetailsFelicitupDashboardEvent.changeCurrentIndex(targetIndex),
                              );
                          context.read<DetailsFelicitupDashboardBloc>().add(
                                const DetailsFelicitupDashboardEvent.asignCurrentChat(''),
                              );
                          detailsFelicitupNavigatorKey.currentContext?.go(
                            RouterPaths.boteFelicitup,
                          );
                        },
                      ),
                  ],
                ),
              ),

              // Right Main Content Panel (Without bottom navigation bar)
              Expanded(
                child: Column(
                  children: [
                    const DetailsHeader(isWebView: true),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.sp(24),
                          vertical: context.sp(16),
                        ),
                        child: widget.childView,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WebSidebarItem extends StatelessWidget {
  const _WebSidebarItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: context.sp(20),
          vertical: context.sp(14),
        ),
        decoration: BoxDecoration(
          color: isActive
              ? context.colors.orange.valueOpacity(0.12)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isActive ? context.colors.orange : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(context.sp(6)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? context.colors.orange : Colors.transparent,
                border: Border.all(
                  color: context.colors.orange,
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                size: context.sp(18),
                color: isActive ? context.colors.white : context.colors.orange,
              ),
            ),
            SizedBox(width: context.sp(16)),
            Text(
              label,
              style: context.styles.paragraph.copyWith(
                color: isActive ? context.colors.orange : context.colors.text,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: context.sp(15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
