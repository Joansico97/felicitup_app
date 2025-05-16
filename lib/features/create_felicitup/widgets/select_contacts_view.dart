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
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.sp(20)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BlocBuilder<CreateFelicitupBloc, CreateFelicitupState>(
                  builder: (_, state) {
                    final listOwner = state.felicitupOwner;
                    return listOwner.isEmpty || listOwner[0].userImg == ''
                        ? SizedBox(
                          width: context.sp(120),
                          child: SvgPicture.asset(
                            Assets.icons.personIcon,
                            height: context.sp(76),
                            width: context.sp(76),
                            colorFilter: ColorFilter.mode(
                              Color(0xFFDADADA),
                              BlendMode.srcIn,
                            ),
                          ),
                        )
                        : Container(
                          height: context.sp(76),
                          width: context.sp(76),
                          margin: EdgeInsets.only(
                            left: context.sp(25),
                            right: context.sp(25),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              context.sp(100),
                            ),
                            child: Image.network(
                              listOwner[0].userImg ?? '',
                              fit: BoxFit.cover,
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
            builder: (_, state) {
              final listOwner = state.felicitupOwner;

              return SizedBox(
                width: context.sp(170),
                child: PrimarySmallButton(
                  onTap:
                      () => commoBottomModal(
                        context: context,
                        body: BlocBuilder<
                          CreateFelicitupBloc,
                          CreateFelicitupState
                        >(
                          builder: (_, state) {
                            List<UserModel> friendList = [...state.friendList];
                            friendList.sort(
                              (a, b) => (a.fullName ?? '').compareTo(
                                b.fullName ?? '',
                              ),
                            );
                            return friendList.isEmpty
                                ? Center(
                                  child: Text(
                                    'No tienes contactos',
                                    style: context.styles.paragraph,
                                  ),
                                )
                                : Column(
                                  children: [
                                    ...List.generate(
                                      friendList.length,
                                      (index) => GestureDetector(
                                        onTap: () {
                                          final owner = OwnerModel(
                                            id: friendList[index].id ?? '',
                                            name:
                                                friendList[index].fullName ??
                                                'Usuario sin nombre',
                                            date:
                                                friendList[index].birthDate ??
                                                DateTime.now(),
                                            userImg:
                                                friendList[index].userImg ?? '',
                                          );
                                          context.read<CreateFelicitupBloc>().add(
                                            CreateFelicitupEvent.changeFelicitupOwner(
                                              owner,
                                            ),
                                          );
                                        },
                                        child: ContactCardRow(
                                          contact: friendList[index],
                                          isSelected: state.felicitupOwner.any(
                                            (owner) =>
                                                owner.id ==
                                                friendList[index].id,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                          },
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
            builder: (_, state) {
              final felicitupDate = state.selectedDate;
              return SizedBox(
                width: context.sp(170),
                child: PrimarySmallButton(
                  onTap: () async {
                    final DateTime? pickedDate = await showGenericDatePicker(
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

                    final TimeOfDay? pickedTime = await showGenericTimePicker(
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

                    context.read<CreateFelicitupBloc>().add(
                      CreateFelicitupEvent.changeFelicitupDate(
                        combinedDateTime!,
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
