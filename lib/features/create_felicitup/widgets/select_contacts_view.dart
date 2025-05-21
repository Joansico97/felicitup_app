import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/felicitup_models/felicitup_models.dart';
import 'package:felicitup_app/data/models/user_models/user_models.dart';
import 'package:felicitup_app/features/create_felicitup/bloc/create_felicitup_bloc.dart';
import 'package:felicitup_app/features/create_felicitup/widgets/widgets.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class ContactSearchList extends StatefulWidget {
  final List<UserModel> initialFriendList;
  final List<OwnerModel> selectedOwners;
  final Function(OwnerModel) onContactSelected;
  final CreateFelicitupBloc felicitupBloc;

  const ContactSearchList({
    super.key,
    required this.initialFriendList,
    required this.selectedOwners,
    required this.onContactSelected,
    required this.felicitupBloc,
  });

  @override
  State<ContactSearchList> createState() => _ContactSearchListState();
}

class _ContactSearchListState extends State<ContactSearchList> {
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
          child: Text('No tienes contactos', style: context.styles.paragraph),
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
              hintText: 'Buscar contacto...',
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
              final bool isSelected = widget.selectedOwners.any(
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
                  widget.felicitupBloc.add(
                    CreateFelicitupEvent.changeFelicitupOwner(owner),
                  );
                  widget.onContactSelected(owner);
                },
                child: ContactCardRow(contact: contact, isSelected: isSelected),
              );
            },
          ),
      ],
    );
  }
}

class SelectContactsView extends StatelessWidget {
  const SelectContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: context.sp(100),
        maxHeight: context.sp(200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
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
                            borderRadius: BorderRadius.circular(
                              context.sp(100),
                            ),
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
                        '| Paso 01',
                        style: context.styles.menu.copyWith(
                          fontSize: context.sp(9),
                        ),
                      ),
                      SizedBox(height: context.sp(8)),
                      BlocBuilder<CreateFelicitupBloc, CreateFelicitupState>(
                        builder: (_, state) {
                          final listOwner = state.felicitupOwner;
                          return Text(
                            listOwner.length > 2
                                ? 'Felicitas a ${listOwner[0].name}, a ${listOwner[1].name} y a ${listOwner.length - 2} más'
                                : listOwner.length == 2
                                ? 'Felicitas a ${listOwner[0].name} y a ${listOwner[1].name}'
                                : listOwner.length == 1
                                ? 'Felicitas a ${listOwner[0].name}'
                                : '¿A quién felicitas?',
                            style: context.styles.smallText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                      SizedBox(height: context.sp(8)),
                      BlocBuilder<CreateFelicitupBloc, CreateFelicitupState>(
                        builder: (_, state) {
                          final listOwner = state.felicitupOwner;
                          final selectedDate = state.selectedDate;

                          return Text(
                            selectedDate != null
                                ? 'Fecha envío felicitUp:\n${DateFormat('dd·MM·yyyy').format(selectedDate)} - ${DateFormat('HH:mm').format(selectedDate)}'
                                : listOwner.isNotEmpty
                                ? 'Fecha envío felicitUp:\n${DateFormat('dd·MM·yyyy').format(listOwner[0].date)} - ${DateFormat('HH:mm').format(listOwner[0].date)}'
                                : 'Selecciona la persona a la que irá destinada la Felicitup.',
                            style: context.styles.smallText.copyWith(
                              fontSize: context.sp(10),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.sp(8)),
          BlocBuilder<CreateFelicitupBloc, CreateFelicitupState>(
            builder: (buttonContext, state) {
              final listOwner = state.felicitupOwner;
              final felicitupBlocInstance =
                  buttonContext.read<CreateFelicitupBloc>();

              return SizedBox(
                width: context.sp(170),
                child: PrimarySmallButton(
                  onTap:
                      () => commoBottomModal(
                        context: buttonContext,
                        body: ContactSearchList(
                          initialFriendList: [...state.friendList],
                          selectedOwners: state.felicitupOwner,
                          felicitupBloc: felicitupBlocInstance,
                          onContactSelected: (selectedOwner) {},
                        ),
                      ),
                  label:
                      listOwner.isNotEmpty
                          ? 'Modificar contacto'
                          : 'Buscar contacto',
                  isActive: true,
                  isCollapsed: true,
                ),
              );
            },
          ),
          SizedBox(height: context.sp(8)),
          BlocBuilder<CreateFelicitupBloc, CreateFelicitupState>(
            builder: (buttonContext, state) {
              final felicitupDate = state.selectedDate;
              final felicitupBlocInstance =
                  buttonContext.read<CreateFelicitupBloc>();

              return SizedBox(
                width: context.sp(170),
                child: PrimarySmallButton(
                  onTap: () async {
                    final DateTime? pickedDate = await showGenericDatePicker(
                      context: buttonContext,
                      initialDate: felicitupDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(Duration(days: 365)),
                      lastDate: DateTime(2101),
                      helpText: 'Selecciona una fecha',
                      cancelText: 'Cancelar',
                      confirmText: 'OK',
                      locale: const Locale('es', 'ES'),
                    );

                    if (pickedDate == null) return;

                    final TimeOfDay? pickedTime = await showGenericTimePicker(
                      context: buttonContext,
                      initialTime:
                          felicitupDate != null
                              ? TimeOfDay.fromDateTime(felicitupDate)
                              : TimeOfDay.now(),
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

                    felicitupBlocInstance.add(
                      CreateFelicitupEvent.changeFelicitupDate(
                        combinedDateTime,
                      ),
                    );
                  },
                  label:
                      felicitupDate != null
                          ? 'Cambiar Fecha'
                          : 'Seleccionar fecha',
                  isActive: true,
                  isCollapsed: true,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
