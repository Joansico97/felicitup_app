import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/features/felicitups_dashboard/bloc/felicitups_dashboard_bloc.dart';
import 'package:felicitup_app/features/felicitups_dashboard/widgets/past_felicitup_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum MenuOption { opcion1, opcion2, opcion3 }

class PastSection extends StatelessWidget {
  const PastSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FelicitupsDashboardBloc, FelicitupsDashboardState>(
      buildWhen: (previous, current) =>
          previous.listFelicitupsPast != current.listFelicitupsPast,
      builder: (_, state) {
        final listFelicitupsPast = state.listFelicitupsPast;

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.sp(24)),
              child: Align(
                alignment: Alignment.centerRight,
                child: Theme(
                  data: ThemeData(
                    popupMenuTheme: PopupMenuThemeData(
                      color: context.colors.grey,
                      elevation: context.sp(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.sp(8)),
                      ),
                    ),
                  ),
                  child: PopupMenuButton<MenuOption>(
                    icon: Container(
                      padding: EdgeInsets.all(context.sp(5)),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.colors.orange,
                      ),
                      child: PhosphorIcon(
                        PhosphorIcons.funnelSimple(),
                        color: context.colors.white,
                      ),
                    ),
                    onSelected: (MenuOption result) {
                      final userId = context
                          .read<AppBloc>()
                          .state
                          .currentUser
                          ?.id;

                      switch (result) {
                        case MenuOption.opcion1:
                          context.read<FelicitupsDashboardBloc>().add(
                            FelicitupsDashboardEvent.sortPastFelicitups(
                              0,
                              userId ?? '',
                            ),
                          );
                          break;
                        case MenuOption.opcion2:
                          context.read<FelicitupsDashboardBloc>().add(
                            FelicitupsDashboardEvent.sortPastFelicitups(
                              1,
                              userId ?? '',
                            ),
                          );
                          break;
                        case MenuOption.opcion3:
                          context.read<FelicitupsDashboardBloc>().add(
                            FelicitupsDashboardEvent.sortPastFelicitups(
                              2,
                              userId ?? '',
                            ),
                          );
                          break;
                      }
                    },
                    itemBuilder: (_) {
                      return [
                        PopupMenuItem(
                          value: MenuOption.opcion1,
                          child: Text(
                            'Ordernar por todos',
                            style: context.styles.paragraph,
                          ),
                        ),
                        PopupMenuItem(
                          value: MenuOption.opcion2,
                          child: Text(
                            'Ordernar por míos',
                            style: context.styles.paragraph,
                          ),
                        ),
                        PopupMenuItem(
                          value: MenuOption.opcion3,
                          child: Text(
                            'Ordernar por otros',
                            style: context.styles.paragraph,
                          ),
                        ),
                      ];
                    },
                  ),
                ),
              ),
            ),
            listFelicitupsPast.isEmpty
                ? Expanded(
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(context.sp(20)),
                        margin: EdgeInsets.symmetric(
                          horizontal: context.sp(20),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(context.sp(30)),
                        ),
                        child: Text(
                          'No estás participando en ninguna felicitup',
                          textAlign: TextAlign.center,
                          style: context.styles.paragraph,
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: listFelicitupsPast.length,
                      itemBuilder: (_, index) => PastFelicitupWidget(
                        felicitup: listFelicitupsPast[index],
                      ),
                    ),
                  ),
          ],
        );
      },
    );
  }
}
