import 'package:animate_do/animate_do.dart';
import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/felicitups_dashboard/bloc/felicitups_dashboard_bloc.dart';
import 'package:felicitup_app/features/felicitups_dashboard/widgets/widgets.dart';
import 'package:felicitup_app/features/home/bloc/home_bloc.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DashboardMobileView extends StatelessWidget {
  const DashboardMobileView({
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
      drawer: const DrawerApp(),
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: [
        BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) =>
              previous.showButton != current.showButton ||
              previous.create != current.create,
          builder: (_, state) => GestureDetector(
            onTap: () {
              context.read<AppBloc>().add(AppEvent.loadUserData());
              context.go(RouterPaths.createFelicitup);
            },
            child: Container(
              height: context.sp(48),
              width: context.sp(48),
              decoration: BoxDecoration(
                color: context.colors.lightGrey,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                Assets.images.logo.path,
                scale: context.sp(11),
              ),
            ),
          ),
        ),
      ],
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CommonHeader(),
            BlocBuilder<AppBloc, AppState>(
              builder: (_, stateApp) {
                final birthdateAlerts = stateApp.currentUser?.birthdateAlerts
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
                  child: RememberSection(),
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
                                  previous.currentIndex != current.currentIndex,
                              builder: (_, state) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FelicitupsDashboardHeaderOption(
                                      label: 'EN CURSO',
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
                                              FelicitupsDashboardEvent.changeIndex(
                                                0,
                                              ),
                                            );
                                      },
                                    ),
                                    SizedBox(width: context.sp(14)),
                                    FelicitupsDashboardHeaderOption(
                                      label: 'PASADOS',
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
                                              FelicitupsDashboardEvent.changeIndex(
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
                            _felicitupsDashboardPageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
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
            Container(height: context.sp(85), color: context.colors.orange),
          ],
        ),
      ),
    );
  }
}
