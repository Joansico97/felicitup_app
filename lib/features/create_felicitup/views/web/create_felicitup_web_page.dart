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

class CreateFelicitupWebPage extends StatefulWidget {
  const CreateFelicitupWebPage({super.key});

  @override
  State<CreateFelicitupWebPage> createState() => _CreateFelicitupWebPageState();
}

class _CreateFelicitupWebPageState extends State<CreateFelicitupWebPage> {
  final TextEditingController messageController = TextEditingController();

  static const List<String> steps = [
    'Quién',
    'Evento',
    'Participantes',
    'Qué',
    'Resumen',
  ];

  late final List<Widget> pages;

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

    pages = [
      const SelectContactsView(),
      const SelectEventView(),
      const SelectParticipantsView(),
      const SelectComplementsView(),
      SummaryView(messageController: messageController),
    ];
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateFelicitupBloc, CreateFelicitupState>(
      builder: (_, state) {
        return Scaffold(
          backgroundColor: context.colors.background,
          drawer: const DrawerApp(),
          body: SafeArea(
            child: Column(
              children: [
                const CommonHeader(),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.sp(20),
                        vertical: context.sp(20),
                      ),
                      child: SizedBox(
                        width: context.sp(550),
                        child: FadeInUp(
                          child: Container(
                            padding: EdgeInsets.all(context.sp(20)),
                            decoration: BoxDecoration(
                              color: context.colors.white,
                              borderRadius: BorderRadius.circular(context.sp(20)),
                              boxShadow: [
                                BoxShadow(
                                  color: context.colors.black.valueOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
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
                                SizedBox(height: context.sp(10)),
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
                                      onBack: () => context
                                          .read<CreateFelicitupBloc>()
                                          .add(
                                            const CreateFelicitupEvent
                                                .previousStep(),
                                          ),
                                      onNext: () => context
                                          .read<CreateFelicitupBloc>()
                                          .add(
                                            CreateFelicitupEvent.nextStep(
                                              steps.length - 1,
                                            ),
                                          ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
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
