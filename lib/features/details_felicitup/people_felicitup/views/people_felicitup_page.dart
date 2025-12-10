import 'package:collection/collection.dart';
import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/create_felicitup/widgets/contact_card_row.dart';
import 'package:felicitup_app/features/details_felicitup/details_felicitup.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PeoplePageModalSearchList extends StatefulWidget {
  const PeoplePageModalSearchList({super.key, required this.ids});
  final List<String> ids;

  @override
  State<PeoplePageModalSearchList> createState() =>
      _PeoplePageModalSearchListState();
}

class _PeoplePageModalSearchListState extends State<PeoplePageModalSearchList> {
  String _searchQuery = '';
  List<UserModel> _filteredFriendList = [];
  List<UserModel> _originalFriendList = [];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _filterContacts(_searchController.text);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currentUser = context.read<AppBloc>().state.currentUser;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _filterContacts(String query) {
    final lowerCaseQuery = query.toLowerCase();

    setState(() {
      _searchQuery = lowerCaseQuery;
      if (_searchQuery.isEmpty) {
        _filteredFriendList = List.from(_originalFriendList);
      } else {
        _filteredFriendList = _originalFriendList
            .where(
              (contact) => (contact.getDisplayName(
                currentUser,
              )).toLowerCase().contains(lowerCaseQuery),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PeopleFelicitupBloc, PeopleFelicitupState>(
      listenWhen: (previous, current) =>
          previous.friendList != current.friendList,
      listener: (_, state) {
        final newFriendList = List<UserModel>.from(state.friendList);

        newFriendList.removeWhere((friend) => widget.ids.contains(friend.id));

        newFriendList.sort(
          (a, b) => (a.getDisplayName(currentUser)).toLowerCase().compareTo(
            (b.getDisplayName(currentUser)).toLowerCase(),
          ),
        );

        setState(() {
          _originalFriendList = newFriendList;
          _filterContacts(_searchQuery);
        });
      },
      child: BlocBuilder<PeopleFelicitupBloc, PeopleFelicitupState>(
        builder: (_, peopleState) {
          final currentSelectedParticipantsFromBloc =
              peopleState.invitedContacts;

          return SingleChildScrollView(
            // ← Envuelve todo en SingleChildScrollView
            child: Column(
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
                    focusNode: _searchFocusNode, // ← Usa el FocusNode
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
                    shrinkWrap: true, // ← Importante
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredFriendList.length,
                    itemBuilder: (context, index) {
                      final contact = _filteredFriendList[index];
                      final bool isSelected =
                          currentSelectedParticipantsFromBloc.any(
                            (participant) => participant.id == contact.id,
                          );

                      return GestureDetector(
                        onTap: () {
                          final participant = InvitedModel(
                            id: contact.id ?? '',
                            name: contact.getDisplayName(currentUser),
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

                          context.read<PeopleFelicitupBloc>().add(
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
            ),
          );
        },
      ),
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
    final felicitup = context
        .read<DetailsFelicitupDashboardBloc>()
        .state
        .felicitup;

    if (felicitup != null) {
      context.read<PeopleFelicitupBloc>().add(
        PeopleFelicitupEvent.loadFriendsData(felicitup.invitedUsers),
      );
      context.read<PeopleFelicitupBloc>().add(
        PeopleFelicitupEvent.startListening(felicitup.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
          BlocBuilder<
            DetailsFelicitupDashboardBloc,
            DetailsFelicitupDashboardState
          >(
            buildWhen: (previous, current) =>
                previous.felicitup != current.felicitup ||
                current.felicitup != null,
            builder: (_, state) {
              final felicitup = state.felicitup;

              if (felicitup == null) {
                return Center(
                  child: Text(
                    'Error obteniendo datos de la felicitup',
                    textAlign: TextAlign.center,
                    style: context.styles.header2,
                  ),
                );
              }

              return BlocBuilder<AppBloc, AppState>(
                buildWhen: (previous, current) =>
                    previous.currentUser != current.currentUser,
                builder: (_, state) {
                  final currentUser = state.currentUser;

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.sp(60)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (felicitup.createdBy == currentUser?.id)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              BlocBuilder<
                                PeopleFelicitupBloc,
                                PeopleFelicitupState
                              >(
                                buildWhen: (previous, current) =>
                                    previous.invitedContacts !=
                                    current.invitedContacts,
                                builder: (_, state) {
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
                                      context.read<PeopleFelicitupBloc>().add(
                                        PeopleFelicitupEvent.loadFriendsData(
                                          currentUser?.matchList ?? [],
                                        ),
                                      );

                                      final combinedIds = [
                                        ...felicitup.owner.map((o) => o.id),
                                        ...felicitup.invitedUsers,
                                      ];

                                      commoBottomModal(
                                        context:
                                            rootNavigatorKey.currentContext!,
                                        hasBottomButton: true,
                                        onTap: () {
                                          context.read<PeopleFelicitupBloc>().add(
                                            PeopleFelicitupEvent.updateParticipantsList(
                                              felicitup.id,
                                            ),
                                          );
                                          context.pop();
                                        },
                                        moreSpace: true,
                                        body: BlocProvider.value(
                                          value: context
                                              .read<PeopleFelicitupBloc>(),
                                          child: PeoplePageModalSearchList(
                                            ids: combinedIds,
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
                                          style: context.styles.smallText
                                              .copyWith(
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
                        if (felicitup.createdBy != currentUser?.id)
                          BlocBuilder<
                            PeopleFelicitupBloc,
                            PeopleFelicitupState
                          >(
                            buildWhen: (previous, current) =>
                                previous.invitedUsers != current.invitedUsers,
                            builder: (_, state) {
                              final invitedUsers = state.invitedUsers;
                              final currentInvitedUser = invitedUsers
                                  ?.firstWhere(
                                    (user) => user.id == currentUser?.id,
                                  );

                              if (currentUser == null) {
                                return Center(child: SizedBox.shrink());
                              }

                              if (currentInvitedUser?.assistanceStatus ==
                                  enumToStringAssistance(
                                    AssistanceStatus.accepted,
                                  )) {
                                return Container();
                              }

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  FloatingActionButton.extended(
                                    onPressed: () {
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
                                    },
                                    backgroundColor: context.colors.orange,
                                    label: Row(
                                      children: [
                                        Icon(
                                          Icons.info,
                                          color: context.colors.white,
                                        ),
                                        SizedBox(width: context.sp(6)),
                                        Text(
                                          'Informar participación',
                                          style: context.styles.smallText
                                              .copyWith(
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
                  );
                },
              );
            },
          ),
      body: BlocBuilder<PeopleFelicitupBloc, PeopleFelicitupState>(
        buildWhen: (previous, current) =>
            previous.invitedUsers != current.invitedUsers ||
            previous.friendList != current.friendList,
        builder: (_, state) {
          final invitedUsers = state.invitedUsers;
          final friendList = state.friendList;

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
                  itemBuilder: (_, index) =>
                      BlocBuilder<
                        DetailsFelicitupDashboardBloc,
                        DetailsFelicitupDashboardState
                      >(
                        buildWhen: (previous, current) =>
                            previous.felicitup != current.felicitup,
                        builder: (_, state) {
                          final felicitup = state.felicitup;

                          if (felicitup == null) {
                            return Center(
                              child: Text(
                                'Error obteniendo datos de la felicitup',
                                textAlign: TextAlign.center,
                                style: context.styles.header2,
                              ),
                            );
                          }

                          return BlocBuilder<AppBloc, AppState>(
                            buildWhen: (previous, current) =>
                                previous.currentUser != current.currentUser,
                            builder: (_, state) {
                              final currentUser = state.currentUser;

                              if (currentUser == null) {
                                return SizedBox.shrink();
                              }
                              final invitedUser = invitedUsers![index];
                              final user = friendList.firstWhereOrNull(
                                (user) => user.id == invitedUser.id,
                              );

                              final displayName =
                                  user?.getDisplayName(currentUser) ??
                                  invitedUser.name;
                              final userImage =
                                  user?.userImg ?? invitedUser.userImage ?? '';

                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (invitedUsers[index].id ==
                                              currentUser.id &&
                                          felicitup.createdBy !=
                                              currentUser.id) {
                                        showConfirDoublemModal(
                                          title:
                                              'Participarás en la felicitup?',
                                          label1: 'Confirmar',
                                          isDestructive: true,
                                          onAction1:
                                              invitedUsers[index]
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
                                                        felicitupId:
                                                            felicitup.id,
                                                        felicitupOwnerId:
                                                            felicitup.createdBy,
                                                        newStatus:
                                                            enumToStringAssistance(
                                                              AssistanceStatus
                                                                  .accepted,
                                                            ),
                                                        name: user!
                                                            .getDisplayName(
                                                              currentUser,
                                                            ),
                                                      ),
                                                    ),
                                          label2: 'Denegar',
                                          onAction2: () async {
                                            context.read<PeopleFelicitupBloc>().add(
                                              PeopleFelicitupEvent.informParticipation(
                                                felicitupId: felicitup.id,
                                                felicitupOwnerId:
                                                    felicitup.createdBy,
                                                newStatus:
                                                    enumToStringAssistance(
                                                      AssistanceStatus.rejected,
                                                    ),
                                                name: user!.getDisplayName(
                                                  currentUser,
                                                ),
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
                                      if (felicitup.createdBy ==
                                              currentUser.id &&
                                          invitedUsers[index].id !=
                                              currentUser.id) {
                                        showConfirDoublemModal(
                                          title: 'Eliminar participante?',
                                          label1: 'Eliminar',
                                          isDestructive: true,
                                          onAction1: () async {
                                            context.read<PeopleFelicitupBloc>().add(
                                              PeopleFelicitupEvent.deleteParticipant(
                                                felicitup.id,
                                                invitedUsers[index].id ?? '',
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
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadiusGeometry.circular(
                                                    context.sp(100),
                                                  ),
                                              child: CommonNetworkImage(
                                                imageUrl: userImage,
                                                errorWidget: Center(
                                                  child: Text(
                                                    (displayName?.isNotEmpty ??
                                                            false)
                                                        ? (displayName ?? '')[0]
                                                              .toUpperCase()
                                                        : '',
                                                    style:
                                                        context.styles.subtitle,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: context.sp(14)),
                                          Text(
                                            displayName ?? '',
                                            style: context.styles.smallText
                                                .copyWith(
                                                  color:
                                                      invitedUsers[index]
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
                                              invitedUsers[index]
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
                                              invitedUsers[index]
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
                              );
                            },
                          );
                        },
                      ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
