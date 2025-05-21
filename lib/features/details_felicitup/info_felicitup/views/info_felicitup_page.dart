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

class OwnerSearchListInInfo extends StatefulWidget {
  final List<UserModel> initialFriendList;
  final List<OwnerModel> currentSelectedOwners;
  final InfoFelicitupBloc infoFelicitupBloc;

  const OwnerSearchListInInfo({
    super.key,
    required this.initialFriendList,
    required this.currentSelectedOwners,
    required this.infoFelicitupBloc,
  });

  @override
  State<OwnerSearchListInInfo> createState() => _OwnerSearchListInInfoState();
}

class _OwnerSearchListInInfoState extends State<OwnerSearchListInInfo> {
  String _searchQuery = '';
  List<UserModel> _filteredFriendList = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    widget.initialFriendList.sort(
      (a, b) => (a.fullName ?? '').toLowerCase().compareTo(
        (b.fullName ?? '').toLowerCase(),
      ),
    );
    _filteredFriendList = List.from(widget.initialFriendList);

    _searchController.addListener(() {
      _filterContacts(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterContacts(String query) {
    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      _searchQuery = lowerCaseQuery;
      if (_searchQuery.isEmpty) {
        _filteredFriendList = List.from(widget.initialFriendList);
      } else {
        _filteredFriendList =
            widget.initialFriendList
                .where(
                  (contact) => (contact.fullName ?? '').toLowerCase().contains(
                    lowerCaseQuery,
                  ),
                )
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.initialFriendList.isEmpty && _searchQuery.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(context.sp(16)),
          child: Text(
            'No hay más contactos para agregar como felicitados.',
            style: context.styles.paragraph,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: context.sp(12)),
          child: TextField(
            controller: _searchController,
            style: context.styles.paragraph,
            decoration: InputDecoration(
              fillColor: context.colors.white,
              filled: true,
              hintText: 'Buscar contacto...',
              hintStyle: context.styles.paragraph.copyWith(
                color: context.colors.darkGrey,
              ),
              prefixIcon: Icon(Icons.search, color: context.colors.darkGrey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.sp(10)),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.sp(10)),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.sp(10)),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: context.sp(10),
                horizontal: context.sp(15),
              ),
            ),
            onChanged: _filterContacts,
          ),
        ),
        if (_filteredFriendList.isEmpty && _searchQuery.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.sp(20)),
            child: Text(
              'No se encontraron contactos para "$_searchQuery"',
              style: context.styles.paragraph.copyWith(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredFriendList.length,
            itemBuilder: (context, index) {
              final contact = _filteredFriendList[index];

              final bool isSelected = widget.currentSelectedOwners.any(
                (owner) => owner.id == contact.id,
              );
              return GestureDetector(
                onTap: () {
                  final owner = OwnerModel(
                    id: contact.id ?? '',
                    name: contact.fullName ?? 'Usuario sin nombre',
                    date: contact.birthDate ?? DateTime.now(),
                    userImg: contact.userImg ?? '',
                  );

                  widget.infoFelicitupBloc.add(
                    InfoFelicitupEvent.addToOwnerList(owner),
                  );
                },
                child: ContactCardRow(contact: contact, isSelected: isSelected),
              );
            },
          ),
      ],
    );
  }
}

class InfoFelicitupPage extends StatefulWidget {
  const InfoFelicitupPage({super.key});

  @override
  State<InfoFelicitupPage> createState() => _InfoFelicitupPageState();
}

class _InfoFelicitupPageState extends State<InfoFelicitupPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (detailsFelicitupNavigatorKey.currentContext != null && mounted) {
        detailsFelicitupNavigatorKey.currentContext!
            .read<DetailsFelicitupDashboardBloc>()
            .add(DetailsFelicitupDashboardEvent.changeCurrentIndex(0));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AppBloc>().state.currentUser;

    if (currentUser == null) {
      return Scaffold(
        backgroundColor: context.colors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.sp(12)),
        child: BlocBuilder<
          DetailsFelicitupDashboardBloc,
          DetailsFelicitupDashboardState
        >(
          builder: (dashboardContext, dashboardState) {
            final felicitup = dashboardState.felicitup;
            if (felicitup == null) {
              return const SizedBox.shrink();
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (felicitup.createdBy == currentUser.id)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      BlocBuilder<InfoFelicitupBloc, InfoFelicitupState>(
                        builder: (infoBlocContext, infoState) {
                          return FloatingActionButton.extended(
                            heroTag: 'fab_add_owner_info',
                            onPressed: () {
                              List<UserModel> friendListForModal = [
                                ...infoState.friendList,
                              ];

                              friendListForModal.removeWhere(
                                (friend) => felicitup.owner.any(
                                  (owner) => owner.id == friend.id,
                                ),
                              );

                              friendListForModal.removeWhere(
                                (friend) => felicitup.invitedUsers.any(
                                  (invitedUserId) => invitedUserId == friend.id,
                                ),
                              );

                              friendListForModal.removeWhere(
                                (friend) => infoState.ownersList.any(
                                  (tempOwner) => tempOwner.id == friend.id,
                                ),
                              );

                              commoBottomModal(
                                context: rootNavigatorKey.currentContext!,
                                hasBottomButton: true,
                                onTap: () async {
                                  infoBlocContext.read<InfoFelicitupBloc>().add(
                                    InfoFelicitupEvent.updateFelicitupOwners(
                                      felicitup.id,
                                    ),
                                  );
                                  if (rootNavigatorKey.currentContext != null &&
                                      Navigator.canPop(
                                        rootNavigatorKey.currentContext!,
                                      )) {
                                    GoRouter.of(
                                      rootNavigatorKey.currentContext!,
                                    ).pop();
                                  }
                                },
                                body: BlocProvider.value(
                                  value:
                                      infoBlocContext.read<InfoFelicitupBloc>(),
                                  child: OwnerSearchListInInfo(
                                    initialFriendList: friendListForModal,
                                    currentSelectedOwners: infoState.ownersList,
                                    infoFelicitupBloc:
                                        infoBlocContext
                                            .read<InfoFelicitupBloc>(),
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
                        heroTag: 'fab_edit_date_info',
                        onPressed: () async {
                          final DateTime? pickedDate =
                              await showGenericDatePicker(
                                context: context,
                                initialDate: felicitup.date,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                                helpText: 'Selecciona una fecha',
                                cancelText: 'Cancelar',
                                confirmText: 'OK',
                                locale: const Locale('es', 'ES'),
                              );

                          if (pickedDate == null) return;

                          final TimeOfDay? pickedTime =
                              await showGenericTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(
                                  felicitup.date,
                                ),
                                helpText: 'Selecciona una hora',
                                cancelText: 'Cancelar',
                                confirmText: 'OK',
                              );

                          if (pickedTime == null) return;

                          final DateTime combinedDateTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );

                          context.read<InfoFelicitupBloc>().add(
                            InfoFelicitupEvent.updateDateFelicitup(
                              felicitup.id,
                              combinedDateTime,
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
                        heroTag: 'fab_send_felicitup_info',
                        onPressed:
                            () => showConfirmModal(
                              title:
                                  '¿Estás seguro de querer enviar la felicitup?',
                              onAccept: () async {
                                context.read<InfoFelicitupBloc>().add(
                                  InfoFelicitupEvent.sendFelicitup(
                                    felicitup.id,
                                  ),
                                );

                                if (mounted &&
                                    rootNavigatorKey.currentContext != null) {
                                  GoRouter.of(
                                    rootNavigatorKey.currentContext!,
                                  ).go(RouterPaths.felicitupsDashboard);
                                }
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
      body: BlocBuilder<
        DetailsFelicitupDashboardBloc,
        DetailsFelicitupDashboardState
      >(
        builder: (context, dashboardState) {
          final felicitup = dashboardState.felicitup;
          if (felicitup == null) {
            return Center(child: Text("Cargando detalles del Felicitup..."));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: context.sp(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      child: SizedBox(
                        height: context.sp(150),
                        child: ListView.builder(
                          itemCount: felicitup.owner.length,
                          itemBuilder:
                              (ctx, index) => ListTile(
                                title: Text(
                                  felicitup.owner[index].name,
                                  style: context.styles.subtitle,
                                ),
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
                      child: SizedBox(
                        height: context.sp(150),
                        child: ListView.builder(
                          itemCount: felicitup.invitedUserDetails.length,
                          itemBuilder:
                              (ctx, index) => ListTile(
                                title: Text(
                                  felicitup.invitedUserDetails[index].name ??
                                      '',
                                  style: context.styles.subtitle,
                                ),
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
                    felicitup.invitedUsers.length.toString(),
                    style: context.styles.smallText.copyWith(
                      color: context.colors.text,
                    ),
                  ),
                ),
                SizedBox(height: context.sp(15)),
                DetailsRow(
                  onTap: () {
                    customModal(
                      title: 'Información',
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text(
                              'Fecha',
                              style: context.styles.subtitle,
                            ),
                            subtitle: Text(
                              DateFormat('dd·MM·yyyy').format(felicitup.date),
                              style: context.styles.smallText,
                            ),
                          ),
                          ListTile(
                            title: Text('Hora', style: context.styles.subtitle),
                            subtitle: Text(
                              DateFormat('HH:mm').format(felicitup.date),
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
                if (felicitup.hasVideo)
                  Column(
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
                if (felicitup.hasBote)
                  Column(
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
                          '${felicitup.boteQuantity.toStringAsFixed(2)}€',
                          style: context.styles.smallText.copyWith(
                            color: context.colors.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: context.sp(80)),
              ],
            ),
          );
        },
      ),
    );
  }
}
