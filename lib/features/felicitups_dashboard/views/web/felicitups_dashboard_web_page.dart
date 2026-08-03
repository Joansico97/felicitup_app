import 'package:animate_do/animate_do.dart';
import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/features/felicitups_dashboard/bloc/felicitups_dashboard_bloc.dart';
import 'package:felicitup_app/features/felicitups_dashboard/widgets/widgets.dart';
import 'package:felicitup_app/features/home/bloc/home_bloc.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class FelicitupsDashboardWebPage extends StatelessWidget {
  const FelicitupsDashboardWebPage({
    super.key,
    required PageController felicitupsDashboardPageController,
    required List<Widget> pages,
  }) : _felicitupsDashboardPageController = felicitupsDashboardPageController,
       _pages = pages;

  final PageController _felicitupsDashboardPageController;
  final List<Widget> _pages;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: context.sp(48)),
                Center(
                  child: BlocBuilder<HomeBloc, HomeState>(
                    builder: (_, state) {
                      return InkWell(
                        onTap: () {
                          context.go(RouterPaths.createFelicitup);
                          // if (state.create) {
                          //   context.go(RouterPaths.createFelicitup);
                          // } else {
                          //   context.go(RouterPaths.felicitupsDashboard);
                          // }
                        },
                        child: Image.asset(
                          Assets.images.logoLetter.path,
                          width: context.sp(200),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: context.sp(24)),
                SettingsButtonWeb(
                  onTap: () {
                    context.go(RouterPaths.profile);
                  },
                  label: 'Perfil',
                  icon: Icons.person,
                ),
                SettingsButtonWeb(
                  onTap: () {
                    context.go(RouterPaths.notifications);
                  },
                  label: 'Notificaciones',
                  icon: Icons.notifications_rounded,
                ),
                SettingsButtonWeb(
                  onTap: () {
                    context.go(RouterPaths.wishList);
                  },
                  label: 'Lista de deseos',
                  icon: Icons.card_giftcard_outlined,
                ),
                SettingsButtonWeb(
                  onTap: () {
                    context.go(RouterPaths.listSingleChat);
                  },
                  label: 'Mensajes directos',
                  icon: Icons.mail_outline,
                ),
                SettingsButtonWeb(
                  onTap: () {
                    context.go(RouterPaths.contacts);
                  },
                  label: 'Contactos',
                  icon: Icons.contacts_outlined,
                ),
                SettingsButtonWeb(
                  onTap: () {
                    context.go(RouterPaths.reminders);
                  },
                  label: 'Recordatorios',
                  icon: Icons.calendar_month_outlined,
                ),
                SettingsButtonWeb(
                  onTap: () {
                    context.go(RouterPaths.onBoarding);
                  },
                  label: 'Manual de usuario',
                  icon: Icons.article_outlined,
                ),
                SettingsButtonWeb(
                  onTap: () {
                    context.go(RouterPaths.notificationsSettings);
                  },
                  label: 'Configuración de notificaciones',
                  icon: Icons.notifications_rounded,
                ),
                SettingsButtonWeb(
                  onTap: () {
                    context.go(RouterPaths.frequentQuestions);
                  },
                  label: 'Preguntas frecuentes',
                  icon: Icons.question_mark_rounded,
                ),
                SettingsButtonWeb(
                  onTap: () {
                    context.read<AppBloc>().add(const AppEvent.logout());
                    context.go(RouterPaths.init);
                  },
                  label: 'Cerrar sesión',
                  icon: Icons.logout,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                BlocBuilder<AppBloc, AppState>(
                  builder: (_, stateApp) {
                    final birthdateAlerts = stateApp
                        .currentUser
                        ?.birthdateAlerts
                        ?.where(
                          (alert) => alert.targetDate!.isAfter(
                            DateTime.now().subtract(const Duration(days: 1)),
                          ),
                        )
                        .toList();
                    return Visibility(
                      visible:
                          (birthdateAlerts?.isNotEmpty ?? false) &&
                          stateApp.showRememberSection,
                      child: const RememberSection(),
                    );
                  },
                ),
                Expanded(
                  child: FadeInDown(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            context.colors.orange,
                            context.colors.background,
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: context.sp(12)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.sp(24),
                            ),
                            child:
                                BlocBuilder<
                                  FelicitupsDashboardBloc,
                                  FelicitupsDashboardState
                                >(
                                  buildWhen: (previous, current) =>
                                      previous.currentIndex !=
                                      current.currentIndex,
                                  builder: (_, state) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        FelicitupsDashboardHeaderOption(
                                          label: context.locale.in_progress,
                                          isActive: state.currentIndex == 0,
                                          textColor: context.colors.orange,
                                          activeColor: context.colors.orange,
                                          onActive: () {
                                            _felicitupsDashboardPageController
                                                .animateToPage(
                                                  0,
                                                  duration: const Duration(
                                                    milliseconds: 300,
                                                  ),
                                                  curve: Curves.easeInOut,
                                                );
                                            context
                                                .read<FelicitupsDashboardBloc>()
                                                .add(
                                                  const FelicitupsDashboardEvent.changeIndex(
                                                    0,
                                                  ),
                                                );
                                          },
                                        ),
                                        SizedBox(width: context.sp(14)),
                                        FelicitupsDashboardHeaderOption(
                                          label: context.locale.past,
                                          isActive: state.currentIndex == 1,
                                          textColor: context.colors.orange,
                                          activeColor: context.colors.orange,
                                          onActive: () {
                                            _felicitupsDashboardPageController
                                                .animateToPage(
                                                  1,
                                                  duration: const Duration(
                                                    milliseconds: 300,
                                                  ),
                                                  curve: Curves.easeInOut,
                                                );
                                            context
                                                .read<FelicitupsDashboardBloc>()
                                                .add(
                                                  const FelicitupsDashboardEvent.changeIndex(
                                                    1,
                                                  ),
                                                );
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                          ),
                          SizedBox(height: context.sp(12)),
                          Expanded(
                            child: PageView.builder(
                              controller: _felicitupsDashboardPageController,
                              itemCount: 2,
                              itemBuilder: (_, index) {
                                return _pages[index];
                              },
                              onPageChanged: (index) async {
                                _felicitupsDashboardPageController
                                    .animateToPage(
                                      index,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                context.read<FelicitupsDashboardBloc>().add(
                                  FelicitupsDashboardEvent.changeIndex(index),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
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
