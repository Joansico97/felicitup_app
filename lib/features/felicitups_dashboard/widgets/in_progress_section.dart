import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/felicitups_dashboard/bloc/felicitups_dashboard_bloc.dart';
import 'package:felicitup_app/features/felicitups_dashboard/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class InProgressSection extends StatelessWidget {
  const InProgressSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FelicitupsDashboardBloc, FelicitupsDashboardState>(
      builder: (_, state) {
        List<FelicitupModel> listFelicitups = [...state.listFelicitups];
        listFelicitups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final currentUser = context.read<AppBloc>().state.currentUser;

        return listFelicitups.isEmpty
            ? Center(
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
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    ...List.generate(
                      listFelicitups.length,
                      (index) => GestureDetector(
                        onTap: () => context.go(
                          RouterPaths.messageFelicitup,
                          extra: {
                            'felicitupId': listFelicitups[index].id,
                            'fromNotification': false,
                          },
                        ),
                        onLongPress: () {
                          if (listFelicitups[index].createdBy == currentUser?.id) {
                            showConfirmModal(
                              title: '¿Estás seguro de que quieres eliminar esta felicitup?',
                              content: 'Una vez eliminada no podrás recuperarla',
                              onAccept: () async {
                                context.read<FelicitupsDashboardBloc>().add(
                                      FelicitupsDashboardEvent.deleteFelicitup(
                                        listFelicitups[index].id,
                                        listFelicitups[index].chatId,
                                      ),
                                    );
                              },
                            );
                          }
                        },
                        child: FelicitupCard(
                          felicitup: listFelicitups[index],
                        ),
                      ),
                    ),
                  ],
                ),
              );
      },
    );
  }
}
