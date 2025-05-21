import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/create_felicitup/bloc/create_felicitup_bloc.dart';
import 'package:felicitup_app/features/create_felicitup/widgets/widgets.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class ParticipantSearchList extends StatefulWidget {
  final List<UserModel>
  initialFriendList; // Lista de amigos disponibles para ser participantes
  final List<InvitedModel>
  selectedParticipants; // Lista de participantes ya invitados
  final Function(InvitedModel) onParticipantSelected;
  final CreateFelicitupBloc felicitupBloc;

  const ParticipantSearchList({
    super.key,
    required this.initialFriendList,
    required this.selectedParticipants,
    required this.onParticipantSelected,
    required this.felicitupBloc,
  });

  @override
  State<ParticipantSearchList> createState() => _ParticipantSearchListState();
}

class _ParticipantSearchListState extends State<ParticipantSearchList> {
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: context.sp(12)),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar participante...',
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.sp(25)),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding: EdgeInsets.symmetric(
                vertical: context.sp(10),
                horizontal: context.sp(15),
              ),
            ),
            style: context.styles.smallText.copyWith(color: Colors.black87),
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
              final bool isSelected = widget.selectedParticipants.any(
                (participant) => participant.id == contact.id,
              );
              return GestureDetector(
                onTap: () {
                  final participant = InvitedModel(
                    id:
                        contact
                            .id, // Asumiendo que UserModel.id no es nullable o se maneja
                    name: contact.fullName,
                    userImage: contact.userImg,
                    assistanceStatus: enumToStringAssistance(
                      AssistanceStatus.pending,
                    ),
                    videoData: VideoDataModel(
                      // Asegúrate que VideoDataModel esté definido
                      videoUrl: '',
                      videoThumbnail: '',
                    ),
                    paid: enumToStringPayment(PaymentStatus.pending),
                    idInformation: '', // O algún valor por defecto/lógica
                  );
                  widget.felicitupBloc.add(
                    CreateFelicitupEvent.addParticipant(participant),
                  );
                  widget.onParticipantSelected(participant);
                },
                child: ContactCardRow(
                  // Asumiendo que ContactCardRow está definido
                  contact: contact,
                  isSelected: isSelected,
                ),
              );
            },
          ),
      ],
    );
  }
}
// --- Fin del Nuevo Widget ---

class SelectParticipantsView extends StatefulWidget {
  const SelectParticipantsView({super.key});

  @override
  State<SelectParticipantsView> createState() => _SelectParticipantsViewState();
}

class _SelectParticipantsViewState extends State<SelectParticipantsView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.sp(20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BlocBuilder<CreateFelicitupBloc, CreateFelicitupState>(
                builder: (_, state) {
                  final listOwner = state.felicitupOwner;
                  return listOwner.isEmpty ||
                          (listOwner[0].userImg ?? '').isEmpty
                      ? SizedBox(
                        width: context.sp(120),
                        child: SvgPicture.asset(
                          Assets.icons.personIcon,
                          height: context.sp(76),
                          width: context.sp(76),
                          colorFilter: const ColorFilter.mode(
                            Color(0xFFDADADA),
                            BlendMode.srcIn,
                          ),
                        ),
                      )
                      : Container(
                        height: context.sp(76),
                        width: context.sp(76),
                        margin: EdgeInsets.symmetric(
                          horizontal: context.sp(22),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(context.sp(100)),
                          child: Image.network(
                            listOwner[0].userImg!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return SvgPicture.asset(
                                Assets.icons.personIcon,
                                height: context.sp(76),
                                width: context.sp(76),
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFFDADADA),
                                  BlendMode.srcIn,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                },
              ),
              SizedBox(
                width: context.sp(150),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '| Paso 03',
                      style: context.styles.menu.copyWith(
                        fontSize: context.sp(9),
                      ),
                    ),
                    SizedBox(height: context.sp(8)),
                    Text('¿Quién participa?', style: context.styles.smallText),
                    SizedBox(height: context.sp(8)),
                    Text(
                      'Selecciona los participantes de la Felicitup.',
                      style: context.styles.smallText.copyWith(
                        fontSize: context.sp(10),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.sp(12)),
        BlocBuilder<CreateFelicitupBloc, CreateFelicitupState>(
          builder: (buttonModalContext, state) {
            // Renombrar context
            final felicitupBlocInstance =
                buttonModalContext.read<CreateFelicitupBloc>();
            final listOwner = state.felicitupOwner;

            // Filtrar la friendList para excluir a los dueños del Felicitup
            List<UserModel> availableFriendsForParticipation = [
              ...state.friendList,
            ];
            availableFriendsForParticipation.removeWhere(
              (friend) => listOwner.any((owner) => owner.id == friend.id),
            );

            return PrimarySmallButton(
              onTap: () {
                commoBottomModal(
                  // Asumo que commoBottomModal está definido
                  context:
                      buttonModalContext, // Usar el context del BlocBuilder del botón
                  body: ParticipantSearchList(
                    initialFriendList: availableFriendsForParticipation,
                    selectedParticipants: state.invitedContacts,
                    felicitupBloc: felicitupBlocInstance,
                    onParticipantSelected: (selectedParticipant) {
                      // Opcional: cerrar el modal
                      // Navigator.of(buttonModalContext).pop();
                    },
                  ),
                );
              },
              label:
                  'Buscar participantes', // Cambiado el label para más claridad
              isActive: true,
              isCollapsed: true,
            );
          },
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.sp(20)),
          child: BlocBuilder<CreateFelicitupBloc, CreateFelicitupState>(
            builder: (_, state) {
              final listParticipants = state.invitedContacts;

              return Visibility(
                visible: listParticipants.isNotEmpty,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: context.sp(300)),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: context.sp(12)),
                        ...List.generate(
                          listParticipants.length,
                          (index) => OnlyViewCardRow(
                            // Asumo que OnlyViewCardRow está definido
                            contactName: listParticipants[index].name ?? '',
                            userImg: listParticipants[index].userImage ?? '',
                            stepOne: false,
                            stepTwo: false,
                            isSelected: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: context.sp(20)),
      ],
    );
  }
}
