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

class FelicitupsDashboardPage extends StatefulWidget {
  const FelicitupsDashboardPage({
    super.key,
  });

  @override
  State<FelicitupsDashboardPage> createState() => _FelicitupsDashboardPageState();
}

class _FelicitupsDashboardPageState extends State<FelicitupsDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<FelicitupsDashboardBloc>().add(const FelicitupsDashboardEvent.startListening());
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      InProgressSection(),
      PastSection(),
    ];
    final PageController felicitupsDashboardPageController = PageController();

    return Scaffold(
      backgroundColor: context.colors.background,
      drawer: const DrawerApp(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) =>
            previous.showButton != current.showButton || previous.create != current.create,
        builder: (_, state) {
          return FloatingActionButton(
            onPressed: () {
              context.go(RouterPaths.createFelicitup);
            },
            backgroundColor: context.colors.lightGrey,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.sp(50)),
            ),
            child: Image.asset(
              Assets.images.logo.path,
              scale: context.sp(11),
            ),
          );
        },
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CommonHeader(),
            BlocBuilder<AppBloc, AppState>(
              builder: (_, state) {
                return Visibility(
                  visible: state.currentUser?.birthdateAlerts?.isNotEmpty ?? false,
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
                        child: BlocBuilder<FelicitupsDashboardBloc, FelicitupsDashboardState>(
                          builder: (_, state) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _FelicitupsDashboardHeaderOption(
                                  label: 'EN CURSO',
                                  isActive: state.listBoolsTap[0],
                                  textColor: context.colors.orange,
                                  activeColor: context.colors.orange,
                                  onActive: () => context.read<FelicitupsDashboardBloc>().add(
                                      FelicitupsDashboardEvent.changeListBoolsTap(
                                          0, felicitupsDashboardPageController)),
                                ),
                                SizedBox(width: context.sp(14)),
                                _FelicitupsDashboardHeaderOption(
                                  label: 'PASADOS',
                                  isActive: state.listBoolsTap[1],
                                  textColor: context.colors.orange,
                                  activeColor: context.colors.orange,
                                  onActive: () => context.read<FelicitupsDashboardBloc>().add(
                                      FelicitupsDashboardEvent.changeListBoolsTap(
                                          1, felicitupsDashboardPageController)),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      SizedBox(height: context.sp(12)),
                      Expanded(
                        child: PageView.builder(
                          controller: felicitupsDashboardPageController,
                          itemCount: 2,
                          itemBuilder: (_, index) {
                            return pages[index];
                          },
                          onPageChanged: (index) async {
                            context.read<FelicitupsDashboardBloc>().add(
                                FelicitupsDashboardEvent.changeListBoolsTap(index, felicitupsDashboardPageController));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: context.sp(85),
              color: context.colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}

class _FelicitupsDashboardHeaderOption extends StatelessWidget {
  const _FelicitupsDashboardHeaderOption({
    required this.label,
    required this.isActive,
    required this.onActive,
    required this.activeColor,
    required this.textColor,
  });

  final String label;
  final bool isActive;
  final VoidCallback onActive;
  final Color activeColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onActive,
      child: Container(
        height: context.sp(28),
        width: context.sp(90),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.sp(20)),
          color: context.colors.ligthOrange.valueOpacity(.6),
          border: Border.all(
            color: context.colors.white,
          ),
        ),
        child: Text(
          label,
          style: context.styles.menu.copyWith(
            color: isActive ? activeColor : context.colors.darkGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
