import 'package:animate_do/animate_do.dart';
import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/create_felicitup/bloc/create_felicitup_bloc.dart';
import 'package:felicitup_app/features/create_felicitup/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CreateFelicitupMobilePage extends StatefulWidget {
  const CreateFelicitupMobilePage({super.key});

  @override
  State<CreateFelicitupMobilePage> createState() =>
      _CreateFelicitupMobilePageState();
}

class _CreateFelicitupMobilePageState
    extends State<CreateFelicitupMobilePage> {
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<AppBloc>().state;

    final matchList = state.currentUser?.matchList ?? [];
    final myId = state.currentUser?.id;
    if (matchList.isNotEmpty && myId != null) {
      final listData = matchList.where((e) => e != myId).toList();
      context.read<CreateFelicitupBloc>().add(
            CreateFelicitupEvent.loadFriendsData(listData),
          );
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AppBloc>().state.currentUser;
    final matchList = currentUser?.matchList ?? [];
    final bool hasMatchList = matchList.isNotEmpty;

    final List<String> steps = [
      'Quién',
      'Evento',
      if (hasMatchList) 'Participantes',
      'Qué',
      'Resumen',
    ];

    final List<Widget> pages = [
      const SelectContactsView(),
      const SelectEventView(),
      if (hasMatchList) const SelectParticipantsView(),
      const SelectComplementsView(),
      SummaryView(messageController: messageController),
    ];

    return BlocBuilder<CreateFelicitupBloc, CreateFelicitupState>(
      builder: (_, state) {
        return Scaffold(
          backgroundColor: context.colors.background,
          drawer: const DrawerApp(),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const CommonHeader(),
                FadeInUp(
                  child: Container(
                    width: context.sp(360),
                    padding: EdgeInsets.symmetric(
                      horizontal: context.sp(8),
                    ),
                    margin: EdgeInsets.only(top: context.sp(20)),
                    decoration: BoxDecoration(
                      color: context.colors.white,
                      borderRadius: BorderRadius.circular(context.sp(20)),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: context.sp(5)),
                          Container(
                            width: context.fullWidth,
                            height: context.sp(30),
                            margin: EdgeInsets.only(bottom: context.sp(10)),
                            padding: EdgeInsets.symmetric(
                              horizontal: context.sp(5),
                            ),
                            child: Row(
                              children: [
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => showConfirmModal(
                                    title: context.locale
                                        .exit_create_felicitup_confirm,
                                    onAccept: () async {
                                      context.go(
                                        RouterPaths.felicitupsDashboard,
                                      );
                                      context.read<CreateFelicitupBloc>().add(
                                            const CreateFelicitupEvent
                                                .deleteCurrentFelicitup(),
                                          );
                                    },
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: context.colors.orange,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: context.colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.sp(20),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Column(
                                  children: [
                                    SizedBox(height: context.sp(10)),
                                    SizedBox(
                                      width: context.sp(200),
                                      child: Divider(
                                        color: context.colors.lightGrey,
                                      ),
                                    ),
                                  ],
                                ),
                                BlocSelector<
                                  CreateFelicitupBloc,
                                  CreateFelicitupState,
                                  int
                                >(
                                  selector: (state) => state.steperIndex,
                                  builder: (_, currentStep) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        ...List.generate(
                                          steps.length,
                                          (index) => _HeaderStep(
                                            title: steps[index],
                                            step: (index + 1).toString(),
                                            isActive: index == currentStep,
                                            onTap: () => context
                                                .read<CreateFelicitupBloc>()
                                                .add(
                                                  CreateFelicitupEvent.jumpToStep(
                                                    index,
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: context.sp(20)),
                          BlocSelector<
                            CreateFelicitupBloc,
                            CreateFelicitupState,
                            int
                          >(
                            selector: (state) => state.steperIndex,
                            builder: (_, currentStep) {
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (widget, animation) {
                                  final slideAnimation = Tween<Offset>(
                                    begin: const Offset(1.0, 0.0),
                                    end: Offset.zero,
                                  ).animate(animation);

                                  final fadeAnimation = Tween<double>(
                                    begin: 0.0,
                                    end: 1.0,
                                  ).animate(animation);
                                  return FadeTransition(
                                    opacity: fadeAnimation,
                                    child: SlideTransition(
                                      position: slideAnimation,
                                      child: widget,
                                    ),
                                  );
                                },
                                child: KeyedSubtree(
                                  key: ValueKey<int>(currentStep),
                                  child: pages[currentStep],
                                ),
                              );
                            },
                          ),
                          SizedBox(height: context.sp(20)),
                          BlocSelector<
                            CreateFelicitupBloc,
                            CreateFelicitupState,
                            int
                          >(
                            selector: (state) => state.steperIndex,
                            builder: (_, currentStep) {
                              return BottomButtons(
                                showBack: currentStep > 0,
                                showNext: currentStep < steps.length - 1,
                                onBack: () =>
                                    context.read<CreateFelicitupBloc>().add(
                                          const CreateFelicitupEvent
                                              .previousStep(),
                                        ),
                                onNext: () =>
                                    context.read<CreateFelicitupBloc>().add(
                                          CreateFelicitupEvent.nextStep(
                                            steps.length - 1,
                                          ),
                                        ),
                              );
                            },
                          ),
                          SizedBox(height: context.sp(16)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeaderStep extends StatelessWidget {
  const _HeaderStep({
    required this.title,
    required this.step,
    required this.isActive,
    required this.onTap,
  });

  final String title;
  final String step;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: context.sp(40)),
        child: Column(
          children: [
            Text(
              title,
              style: context.styles.menu.copyWith(fontSize: context.sp(10)),
            ),
            SizedBox(height: context.sp(6)),
            Container(
              padding: EdgeInsets.all(context.sp(8)),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      isActive ? context.colors.orange : context.colors.text,
                  width: 1,
                ),
                color:
                    isActive ? context.colors.white : context.colors.lightGrey,
                shape: BoxShape.circle,
              ),
              child: Text(
                step,
                style: context.styles.menu.copyWith(
                  color:
                      isActive ? context.colors.orange : context.colors.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
