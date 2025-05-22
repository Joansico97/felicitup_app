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

class PeoplePageModalSearchList extends StatefulWidget {
  final List<UserModel> initialFriendList;
  final PeopleFelicitupBloc peopleFelicitupBloc;
  const PeoplePageModalSearchList({
    super.key,
    required this.initialFriendList,

    required this.peopleFelicitupBloc,
  });

  @override
  State<PeoplePageModalSearchList> createState() =>
      _PeoplePageModalSearchListState();
}

class _PeoplePageModalSearchListState extends State<PeoplePageModalSearchList> {
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
            'No hay más contactos para agregar como participantes.',
            style: context.styles.paragraph,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return BlocBuilder<PeopleFelicitupBloc, PeopleFelicitupState>(
      bloc: widget.peopleFelicitupBloc,

      builder: (context, peopleState) {
        final currentSelectedParticipantsFromBloc = peopleState.invitedContacts;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(
                bottom: context.sp(12),
                left: context.sp(12),
                right: context.sp(12),
                top: context.sp(12),
              ),
              child: TextField(
                controller: _searchController,
                style: context.styles.paragraph,
                decoration: InputDecoration(
                  fillColor: context.colors.white,
                  filled: true,
                  hintText: 'Buscar participante...',
                  hintStyle: context.styles.paragraph.copyWith(
                    color: context.colors.darkGrey,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: context.colors.darkGrey,
                  ),
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
                  style: context.styles.paragraph.copyWith(
                    color: Colors.grey[700],
                  ),
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

                  final bool isSelected = currentSelectedParticipantsFromBloc
                      .any((participant) => participant.id == contact.id);
                  return GestureDetector(
                    onTap: () {
                      final participant = InvitedModel(
                        id: contact.id ?? '',
                        name: contact.fullName ?? 'Usuario sin nombre',
                        userImage: contact.userImg ?? '',
                        assistanceStatus: enumToStringAssistance(
                          AssistanceStatus.pending,
                        ),
                        paid: enumToStringPayment(PaymentStatus.pending),
                        videoData: VideoDataModel(
                          videoUrl: '',
                          videoThumbnail: '',
                        ),
                        idInformation: '',
                      );

                      widget.peopleFelicitupBloc.add(
                        PeopleFelicitupEvent.addParticipant(participant),
                      );
                    },
                    child: ContactCardRow(
                      contact: contact,
                      isSelected: isSelected,
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class PeopleFelicitupPage extends StatefulWidget {
  const PeopleFelicitupPage({super.key});

  @override
  State<PeopleFelicitupPage> createState() => _PeopleFelicitupPageState();
}

class _PeopleFelicitupPageState extends State<PeopleFelicitupPage> {
  List<bool> isSelected = [];
  @override
  void initState() {
    super.initState();
    detailsFelicitupNavigatorKey.currentContext!
        .read<DetailsFelicitupDashboardBloc>()
        .add(DetailsFelicitupDashboardEvent.changeCurrentIndex(2));
    final felicitup =
        context.read<DetailsFelicitupDashboardBloc>().state.felicitup;
    context.read<PeopleFelicitupBloc>().add(
      PeopleFelicitupEvent.startListening(felicitup?.id ?? ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      DetailsFelicitupDashboardBloc,
      DetailsFelicitupDashboardState
    >(
      buildWhen: (previous, current) => previous.felicitup != current.felicitup,
      builder: (_, state) {
        final felicitup = state.felicitup;
        final currentUser = context.read<AppBloc>().state.currentUser;

        return Scaffold(
          backgroundColor: context.colors.background,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.sp(60)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (felicitup!.createdBy == currentUser!.id)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      BlocBuilder<PeopleFelicitupBloc, PeopleFelicitupState>(
                        buildWhen:
                            (previous, current) =>
                                previous.invitedContacts !=
                                current.invitedContacts,
                        builder: (_, state) {
                          final bloc = context.read<PeopleFelicitupBloc>();
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
                          isSelected = List.generate(
                            friendList.length,
                            (index) => false,
                          );

                          return FloatingActionButton.extended(
                            onPressed: () {
                              commoBottomModal(
                                context: rootNavigatorKey.currentContext!,
                                hasBottomButton: true,
                                onTap: () {
                                  context.read<PeopleFelicitupBloc>().add(
                                    PeopleFelicitupEvent.updateParticipantsList(
                                      felicitup.id,
                                    ),
                                  );
                                  context.pop();
                                },
                                body: BlocProvider.value(
                                  value: context.read<PeopleFelicitupBloc>(),
                                  child: PeoplePageModalSearchList(
                                    initialFriendList: friendList,
                                    peopleFelicitupBloc: bloc,
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
                                SizedBox(width: context.sp(6)),
                                Text(
                                  'Agregar',
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
                if (felicitup.createdBy != currentUser.id)
                  BlocBuilder<PeopleFelicitupBloc, PeopleFelicitupState>(
                    builder: (_, state) {
                      final invitedUsers = state.invitedUsers;
                      final currentInvitedUser = invitedUsers?.firstWhere(
                        (user) => user.id == currentUser.id,
                      );

                      if (currentInvitedUser?.assistanceStatus ==
                          enumToStringAssistance(AssistanceStatus.accepted)) {
                        return Container();
                      }

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FloatingActionButton.extended(
                            onPressed: () {
                              // Find the invitedUser object for the current user

                              showConfirDoublemModal(
                                title: 'Participarás en la felicitup?',
                                label1: 'Confirmar',
                                isDestructive: true,
                                onAction1:
                                    currentInvitedUser != null &&
                                            currentInvitedUser
                                                    .assistanceStatus ==
                                                enumToStringAssistance(
                                                  AssistanceStatus.accepted,
                                                )
                                        ? () async {
                                          context.pop();
                                        }
                                        : () async => context
                                            .read<PeopleFelicitupBloc>()
                                            .add(
                                              PeopleFelicitupEvent.informParticipation(
                                                felicitupId: felicitup.id,
                                                felicitupOwnerId:
                                                    felicitup.createdBy,
                                                newStatus:
                                                    enumToStringAssistance(
                                                      AssistanceStatus.accepted,
                                                    ),
                                                name:
                                                    currentUser.firstName ?? '',
                                              ),
                                            ),
                                label2: 'Denegar',
                                onAction2: () async {
                                  context.read<PeopleFelicitupBloc>().add(
                                    PeopleFelicitupEvent.informParticipation(
                                      felicitupId: felicitup.id,
                                      felicitupOwnerId: felicitup.createdBy,
                                      newStatus: enumToStringAssistance(
                                        AssistanceStatus.rejected,
                                      ),
                                      name: currentUser.firstName ?? '',
                                    ),
                                  );
                                  context.go(RouterPaths.felicitupsDashboard);
                                },
                              );
                            },
                            backgroundColor: context.colors.orange,
                            label: Row(
                              children: [
                                Icon(Icons.info, color: context.colors.white),
                                SizedBox(width: context.sp(6)),
                                Text(
                                  'Informar participación',
                                  style: context.styles.smallText.copyWith(
                                    color: context.colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
          body: BlocBuilder<PeopleFelicitupBloc, PeopleFelicitupState>(
            builder: (_, state) {
              final invitedUsers = state.invitedUsers;

              return Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: context.sp(40),
                      width: context.sp(113),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(context.sp(20)),
                        color: context.colors.white,
                      ),
                      child: Text(
                        'Participantes',
                        style: context.styles.smallText.copyWith(
                          color: context.colors.softOrange,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.sp(22)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: invitedUsers?.length ?? 0,
                      itemBuilder:
                          (_, index) => Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (invitedUsers?[index].id ==
                                          currentUser.id &&
                                      felicitup.createdBy != currentUser.id) {
                                    showConfirDoublemModal(
                                      title: 'Participarás en la felicitup?',
                                      label1: 'Confirmar',
                                      isDestructive: true,
                                      onAction1:
                                          invitedUsers?[index]
                                                      .assistanceStatus ==
                                                  enumToStringAssistance(
                                                    AssistanceStatus.accepted,
                                                  )
                                              ? () async {
                                                context.pop();
                                              }
                                              : () async => context
                                                  .read<PeopleFelicitupBloc>()
                                                  .add(
                                                    PeopleFelicitupEvent.informParticipation(
                                                      felicitupId: felicitup.id,
                                                      felicitupOwnerId:
                                                          felicitup.createdBy,
                                                      newStatus:
                                                          enumToStringAssistance(
                                                            AssistanceStatus
                                                                .accepted,
                                                          ),
                                                      name:
                                                          currentUser
                                                              .firstName ??
                                                          '',
                                                    ),
                                                  ),
                                      label2: 'Denegar',
                                      onAction2: () async {
                                        context.read<PeopleFelicitupBloc>().add(
                                          PeopleFelicitupEvent.informParticipation(
                                            felicitupId: felicitup.id,
                                            felicitupOwnerId:
                                                felicitup.createdBy,
                                            newStatus: enumToStringAssistance(
                                              AssistanceStatus.rejected,
                                            ),
                                            name: currentUser.firstName ?? '',
                                          ),
                                        );
                                        context.go(
                                          RouterPaths.felicitupsDashboard,
                                        );
                                      },
                                    );
                                  }
                                },
                                onLongPress: () {
                                  if (felicitup.createdBy == currentUser.id &&
                                      invitedUsers?[index].id !=
                                          currentUser.id) {
                                    showConfirDoublemModal(
                                      title: 'Eliminar participante?',
                                      label1: 'Eliminar',
                                      isDestructive: true,
                                      onAction1: () async {
                                        context.read<PeopleFelicitupBloc>().add(
                                          PeopleFelicitupEvent.deleteParticipant(
                                            felicitup.id,
                                            invitedUsers?[index].id ?? '',
                                          ),
                                        );
                                      },
                                      label2: 'Cancelar',
                                      onAction2: () async {
                                        context.pop();
                                      },
                                    );
                                  }
                                },
                                child: DetailsRow(
                                  prefixChild: Row(
                                    children: [
                                      Container(
                                        height: context.sp(23),
                                        width: context.sp(23),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: context.colors.lightGrey,
                                        ),
                                        child: Text(
                                          invitedUsers?[index].name![0]
                                                  .toUpperCase() ??
                                              'Usuario sin nombre',
                                          style: context.styles.subtitle,
                                        ),
                                      ),
                                      SizedBox(width: context.sp(14)),
                                      Text(
                                        invitedUsers?[index].name ?? '',
                                        style: context.styles.smallText.copyWith(
                                          color:
                                              invitedUsers?[index]
                                                          .assistanceStatus ==
                                                      enumToStringAssistance(
                                                        AssistanceStatus
                                                            .pending,
                                                      )
                                                  ? context.colors.text
                                                  : context.colors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  sufixChild: Container(
                                    padding: EdgeInsets.all(context.sp(5)),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          invitedUsers?[index]
                                                      .assistanceStatus ==
                                                  enumToStringAssistance(
                                                    AssistanceStatus.accepted,
                                                  )
                                              ? context.colors.softOrange
                                              : context.colors.otherGrey,
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      color:
                                          invitedUsers?[index]
                                                      .assistanceStatus ==
                                                  enumToStringAssistance(
                                                    AssistanceStatus.accepted,
                                                  )
                                              ? context.colors.white
                                              : context.colors.otherGrey,
                                      size: 11,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: context.sp(12)),
                            ],
                          ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
