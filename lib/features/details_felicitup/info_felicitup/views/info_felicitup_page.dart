import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/create_felicitup/widgets/contact_card_row.dart';
import 'package:felicitup_app/features/details_felicitup/details_felicitup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class InfoFelicitupPage extends StatefulWidget {
  const InfoFelicitupPage({super.key});

  @override
  State<InfoFelicitupPage> createState() => _InfoFelicitupPageState();
}

class _InfoFelicitupPageState extends State<InfoFelicitupPage> {
  @override
  void initState() {
    super.initState();
    detailsFelicitupNavigatorKey.currentContext!
        .read<DetailsFelicitupDashboardBloc>()
        .add(DetailsFelicitupDashboardEvent.changeCurrentIndex(0));
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AppBloc>().state.currentUser;
    return Scaffold(
      backgroundColor: context.colors.background,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.sp(12)),
        child: BlocBuilder<
          DetailsFelicitupDashboardBloc,
          DetailsFelicitupDashboardState
        >(
          buildWhen:
              (previous, current) =>
                  previous.felicitup!.owner != current.felicitup!.owner,
          builder: (_, state) {
            final felicitup = state.felicitup;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (felicitup!.createdBy == currentUser!.id)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      BlocBuilder<InfoFelicitupBloc, InfoFelicitupState>(
                        builder: (_, state) {
                          return FloatingActionButton.extended(
                            heroTag: '1',
                            onPressed: () {
                              final friendList = [...state.friendList];
                              friendList.removeWhere(
                                (friend) => felicitup.owner.any(
                                  (owner) => owner.id == friend.id,
                                ),
                              );
                              friendList.removeWhere(
                                (friend) => felicitup.invitedUsers.any(
                                  (invitedUser) => invitedUser == friend.id,
                                ),
                              );
                              commoBottomModal(
                                context: rootNavigatorKey.currentContext!,
                                hasBottomButton: true,
                                onTap: () async {
                                  context.read<InfoFelicitupBloc>().add(
                                    InfoFelicitupEvent.updateFelicitupOwners(
                                      felicitup.id,
                                    ),
                                  );
                                  setState(() {});
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    context.pop();
                                  });
                                },
                                body: BlocProvider.value(
                                  value: context.read<InfoFelicitupBloc>(),
                                  child: Column(
                                    children: [
                                      ...List.generate(
                                        friendList.length,
                                        (index) => GestureDetector(
                                          onTap: () {
                                            final owner = OwnerModel(
                                              id: friendList[index].id ?? '',
                                              name:
                                                  friendList[index].fullName ??
                                                  '',
                                              date:
                                                  friendList[index].birthDate ??
                                                  DateTime.now(),
                                              userImg:
                                                  friendList[index].userImg ??
                                                  '',
                                            );
                                            context.read<InfoFelicitupBloc>().add(
                                              InfoFelicitupEvent.addToOwnerList(
                                                owner,
                                              ),
                                            );
                                          },
                                          child: BlocBuilder<
                                            InfoFelicitupBloc,
                                            InfoFelicitupState
                                          >(
                                            builder: (_, state) {
                                              return ContactCardRow(
                                                contact: friendList[index],
                                                isSelected: state.ownersList
                                                    .any(
                                                      (owner) =>
                                                          owner.id ==
                                                          friendList[index].id,
                                                    ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            backgroundColor: context.colors.orange,
                            label: Row(
                              children: [
                                Icon(
                                  Icons.person_add,
                                  color: context.colors.white,
                                ),
                                SizedBox(width: context.sp(5)),
                                Text(
                                  'Añadir',
                                  style: context.styles.smallText.copyWith(
                                    color: context.colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                if (felicitup.createdBy == currentUser.id)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FloatingActionButton.extended(
                        heroTag: '2',
                        onPressed: () async {
                          final DateTime? pickedDate =
                              await showGenericDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                                helpText: 'Selecciona una fecha',
                                cancelText: 'Cancelar',
                                confirmText: 'OK',
                                locale: const Locale('es', 'ES'),
                              );

                          if (pickedDate == null) return;

                          final TimeOfDay? pickedTime =
                              await showGenericTimePicker(
                                context: context,
                                helpText: 'Selecciona una hora',
                                cancelText: 'Cancelar',
                                confirmText: 'OK',
                              );

                          if (pickedTime == null) return;

                          final DateTime? combinedDateTime = combineDateAndTime(
                            pickedDate,
                            pickedTime,
                          );
                          context.read<InfoFelicitupBloc>().add(
                            InfoFelicitupEvent.updateDateFelicitup(
                              felicitup.id,
                              combinedDateTime!,
                            ),
                          );
                        },
                        backgroundColor: context.colors.orange,
                        label: Row(
                          children: [
                            Icon(Icons.edit, color: context.colors.white),
                            SizedBox(width: context.sp(5)),
                            Text(
                              'Editar',
                              style: context.styles.smallText.copyWith(
                                color: context.colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                if (felicitup.createdBy == currentUser.id)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FloatingActionButton.extended(
                        onPressed:
                            () => showConfirmModal(
                              title:
                                  'Estás seguro de querer enviar la felicitup?',
                              onAccept: () async {
                                context.read<InfoFelicitupBloc>().add(
                                  InfoFelicitupEvent.sendFelicitup(
                                    felicitup.id,
                                  ),
                                );
                                context.go(RouterPaths.felicitupsDashboard);
                              },
                            ),
                        backgroundColor: context.colors.orange,
                        label: Row(
                          children: [
                            Icon(Icons.send, color: context.colors.white),
                            SizedBox(width: context.sp(5)),
                            Text(
                              'Enviar',
                              style: context.styles.smallText.copyWith(
                                color: context.colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            );
          },
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
          BlocBuilder<
            DetailsFelicitupDashboardBloc,
            DetailsFelicitupDashboardState
          >(
            buildWhen:
                (previous, current) =>
                    previous.felicitup!.owner != current.felicitup!.owner,
            builder: (_, state) {
              final thisFelicitup = state.felicitup;
              return DetailsRow(
                onTap: () {
                  customModal(
                    title: 'Felicitados',
                    child: SizedBox(
                      height: context.sp(150),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ...List.generate(
                              thisFelicitup?.owner.length ?? 0,
                              (index) => ListTile(
                                title: Text(
                                  thisFelicitup?.owner[index].name ?? '',
                                  style: context.styles.subtitle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                  thisFelicitup?.owner.length.toString() ?? '',
                  style: context.styles.smallText.copyWith(
                    color: context.colors.text,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: context.sp(15)),
          BlocBuilder<
            DetailsFelicitupDashboardBloc,
            DetailsFelicitupDashboardState
          >(
            buildWhen:
                (previous, current) =>
                    previous.felicitup!.owner != current.felicitup!.owner,
            builder: (_, state) {
              final felicitup = state.felicitup;
              return DetailsRow(
                onTap: () {
                  customModal(
                    title: 'Participantes',
                    child: SizedBox(
                      height: context.sp(150),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ...List.generate(
                              felicitup?.invitedUserDetails.length ?? 0,
                              (index) => ListTile(
                                title: Text(
                                  felicitup?.invitedUserDetails[index].name ??
                                      '',
                                  style: context.styles.subtitle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                  felicitup?.invitedUsers.length.toString() ?? '',
                  style: context.styles.smallText.copyWith(
                    color: context.colors.text,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: context.sp(15)),
          BlocBuilder<
            DetailsFelicitupDashboardBloc,
            DetailsFelicitupDashboardState
          >(
            buildWhen:
                (previous, current) =>
                    previous.felicitup!.owner != current.felicitup!.owner,
            builder: (_, state) {
              final felicitup = state.felicitup;
              return DetailsRow(
                onTap: () {
                  customModal(
                    title: 'Información',
                    child: Column(
                      children: [
                        ListTile(
                          title: Text('Fecha', style: context.styles.subtitle),
                          subtitle: Text(
                            DateFormat(
                              'dd·MM·yyyy',
                            ).format(felicitup?.date ?? DateTime.now()),
                            style: context.styles.smallText,
                          ),
                        ),
                        ListTile(
                          title: Text('Hora', style: context.styles.subtitle),
                          subtitle: Text(
                            DateFormat(
                              'HH:ss',
                            ).format(felicitup?.date ?? DateTime.now()),
                            style: context.styles.smallText,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                prefixChild: Text(
                  'Información',
                  style: context.styles.smallText.copyWith(
                    color: context.colors.text,
                  ),
                ),
                sufixChild: SizedBox(),
              );
            },
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
          BlocBuilder<
            DetailsFelicitupDashboardBloc,
            DetailsFelicitupDashboardState
          >(
            buildWhen:
                (previous, current) =>
                    previous.felicitup!.owner != current.felicitup!.owner,
            builder: (_, state) {
              final felicitup = state.felicitup;
              return Visibility(
                visible: felicitup?.hasVideo ?? false,
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
              );
            },
          ),
          BlocBuilder<
            DetailsFelicitupDashboardBloc,
            DetailsFelicitupDashboardState
          >(
            buildWhen:
                (previous, current) =>
                    previous.felicitup!.owner != current.felicitup!.owner,
            builder: (_, state) {
              final felicitup = state.felicitup;
              return Visibility(
                visible: felicitup?.hasBote ?? false,
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
                        '${felicitup?.boteQuantity}€',
                        style: context.styles.smallText.copyWith(
                          color: context.colors.text,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
