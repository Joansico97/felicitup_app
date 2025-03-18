import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/details_felicitup/details_felicitup_dashboard/bloc/details_felicitup_dashboard_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InfoFelicitupPage extends StatelessWidget {
  const InfoFelicitupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailsFelicitupDashboardBloc, DetailsFelicitupDashboardState>(
      buildWhen: (previous, current) => previous.felicitup != current.felicitup,
      builder: (_, state) {
        final felicitup = state.felicitup;
        final currentUser = context.read<AppBloc>().state.currentUser;

        return Scaffold(
          backgroundColor: context.colors.background,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.sp(60)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (felicitup!.createdBy == currentUser!.id)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FloatingActionButton(
                        heroTag: '1',
                        onPressed: () {},
                        // onPressed: () => notifier.addNewContactModal(
                        //   felicitup!: felicitup!,
                        // ),
                        backgroundColor: context.colors.orange,
                        child: Icon(
                          Icons.person_add,
                          color: context.colors.white,
                        ),
                      ),
                    ],
                  ),
                if (felicitup.createdBy == currentUser.id)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FloatingActionButton(
                        heroTag: '2',
                        onPressed: () {},
                        // onPressed: () => notifier.editDateModal(
                        //   felicitup!: felicitup!,
                        // ),
                        backgroundColor: context.colors.orange,
                        child: Icon(
                          Icons.edit,
                          color: context.colors.white,
                        ),
                      ),
                    ],
                  ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      onPressed: () => showConfirmModal(
                        title: 'Estás seguro de querer enviar la felicitup?', onAccept: () async {},
                        // onAccept: () async => await notifier.sendManualFelicitup(felicitupId: felicitupId),
                      ),
                      backgroundColor: context.colors.orange,
                      child: Icon(
                        Icons.send,
                        color: context.colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              SizedBox(height: context.sp(26)),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: context.sp(40),
                  width: context.sp(85),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(context.sp(20)),
                    color: context.colors.white,
                  ),
                  child: Text(
                    'Resumen',
                    style: context.styles.smallText.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: context.sp(22)),
              DetailsRow(
                onTap: () {
                  customModal(
                    title: 'Felicitados',
                    child: Column(
                      children: [
                        ...List.generate(
                          felicitup.owner.length,
                          (index) => ListTile(
                            title: Text(
                              felicitup.owner[index].name,
                              style: context.styles.subtitle,
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
                prefixChild: Text(
                  'Felicitados',
                  style: context.styles.smallText.copyWith(
                    color: context.colors.text,
                  ),
                ),
                sufixChild: Text(
                  felicitup.owner.length.toString(),
                  style: context.styles.smallText.copyWith(
                    color: context.colors.text,
                  ),
                ),
              ),
              SizedBox(height: context.sp(15)),
              DetailsRow(
                onTap: () {
                  customModal(
                    title: 'Participantes',
                    child: Column(
                      children: [
                        ...List.generate(
                          felicitup.invitedUserDetails.length,
                          (index) => ListTile(
                            title: Text(
                              felicitup.invitedUserDetails[index].name ?? '',
                              style: context.styles.subtitle,
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
                prefixChild: Text(
                  'Participantes',
                  style: context.styles.smallText.copyWith(
                    color: context.colors.text,
                  ),
                ),
                sufixChild: Text(
                  felicitup.invitedUsers.length.toString(),
                  style: context.styles.smallText.copyWith(
                    color: context.colors.text,
                  ),
                ),
              ),
              SizedBox(height: context.sp(15)),
              DetailsRow(
                prefixChild: Text(
                  'Chat',
                  style: context.styles.smallText.copyWith(
                    color: context.colors.text,
                  ),
                ),
                sufixChild: Container(
                  padding: EdgeInsets.all(context.sp(5)),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.orange,
                  ),
                  child: Icon(
                    Icons.check,
                    color: context.colors.white,
                    size: context.sp(11),
                  ),
                ),
              ),
              Visibility(
                visible: felicitup.hasVideo,
                child: Column(
                  children: [
                    SizedBox(height: context.sp(15)),
                    DetailsRow(
                      prefixChild: Text(
                        'Video',
                        style: context.styles.smallText.copyWith(
                          color: context.colors.text,
                        ),
                      ),
                      sufixChild: Container(
                        padding: EdgeInsets.all(context.sp(5)),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.colors.orange,
                        ),
                        child: Icon(
                          Icons.check,
                          color: context.colors.white,
                          size: context.sp(11),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: felicitup.hasBote,
                child: Column(
                  children: [
                    SizedBox(height: context.sp(15)),
                    DetailsRow(
                      prefixChild: Text(
                        'Bote regalo',
                        style: context.styles.smallText.copyWith(
                          color: context.colors.text,
                        ),
                      ),
                      sufixChild: Text(
                        '${felicitup.boteQuantity}€',
                        style: context.styles.smallText.copyWith(
                          color: context.colors.text,
                        ),
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
