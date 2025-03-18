import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/create_felicitup/bloc/create_felicitup_bloc.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class SummaryView extends StatelessWidget {
  const SummaryView({
    super.key,
    required this.messageController,
  });

  final TextEditingController messageController;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: context.sp(200),
          maxHeight: context.sp(470),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.sp(20),
          ),
          child: Column(
            children: [
              SizedBox(height: context.sp(16)),
              BlocBuilder<CreateFelicitupBloc, CreateFelicitupState>(
                builder: (_, state) {
                  final listOwner = state.felicitupOwner;
                  final reason = state.eventReason;

                  return listOwner.length > 2
                      ? Column(
                          children: [
                            Text(
                              '$reason de',
                              style: context.styles.subtitle,
                            ),
                            Wrap(
                              children: [
                                ...List.generate(
                                  listOwner.length,
                                  (index) => index != listOwner.length - 1
                                      ? Text(
                                          '${listOwner[index]['name']} ',
                                          style: context.styles.subtitle,
                                        )
                                      : Text(
                                          'y ${listOwner[index]['name']} ',
                                          style: context.styles.subtitle,
                                        ),
                                )
                              ],
                            ),
                          ],
                        )
                      : Text(
                          '$reason de ${listOwner[0]['name']}',
                          style: context.styles.subtitle,
                        );
                },
              ),
              SizedBox(height: context.sp(12)),
              BlocBuilder<CreateFelicitupBloc, CreateFelicitupState>(
                builder: (_, state) {
                  final listOwner = state.felicitupOwner;
                  return listOwner.isEmpty || listOwner[0]['userImg'] == ''
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
                              listOwner[0]['userImg'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                },
              ),
              SizedBox(height: context.sp(12)),
              SizedBox(
                width: context.sp(150),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '| Paso 05',
                      style: context.styles.menu.copyWith(
                        fontSize: context.sp(9),
                      ),
                    ),
                    SizedBox(height: context.sp(8)),
                    Text(
                      'Resumen',
                      style: context.styles.subtitle.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: context.sp(8)),
                    Text(
                      'Ya casi estamos, revisa los datos de tu Felicitup.',
                      style: context.styles.menu,
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.sp(16)),
              BlocBuilder<CreateFelicitupBloc, CreateFelicitupState>(
                builder: (_, state) {
                  final listOwner = state.felicitupOwner;
                  final invitedList = state.invitedContacts;
                  final selectedDate = state.selectedDate;
                  final reason = state.eventReason;

                  return Column(
                    children: [
                      _ResumenCard(
                        label: selectedDate != null
                            ? 'Fecha: ${DateFormat('dd·MM·yyyy').format(selectedDate)}'
                            : 'Fecha: ${DateFormat('dd·MM·yyyy').format(listOwner[0]['date'])}',
                        onTap: () => context.read<CreateFelicitupBloc>().add(CreateFelicitupEvent.jumpToStep(0)),
                      ),
                      SizedBox(height: context.sp(8)),
                      _ResumenCard(
                        label: 'Motivo: $reason',
                        onTap: () => context.read<CreateFelicitupBloc>().add(CreateFelicitupEvent.jumpToStep(1)),
                      ),
                      SizedBox(height: context.sp(8)),
                      _ResumenCard(
                        label: 'Participantes: ${invitedList.length + 1}',
                        onTap: () => context.read<CreateFelicitupBloc>().add(CreateFelicitupEvent.jumpToStep(2)),
                      ),
                      SizedBox(height: context.sp(8)),
                      _ResumenCard(
                        label: selectedDate != null
                            ? 'Fecha: ${DateFormat('dd·MM·yyyy').format(selectedDate.subtract(Duration(days: 1)))}'
                            : 'Fecha: ${DateFormat('dd·MM·yyyy').format(listOwner[0]['date'].subtract(Duration(days: 1)))}',
                        onTap: () => context.read<CreateFelicitupBloc>().add(CreateFelicitupEvent.jumpToStep(0)),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: context.sp(12)),
              SizedBox(
                height: context.sp(100),
                width: context.sp(200),
                child: InputCommon(
                  controller: messageController,
                  hintText: 'Ingresa un mensaje',
                  titleText: 'Mesnaje para tu felicitup',
                  // onchangeEditing: (value) {
                  //   ref.read(CreateFelicitupEventsProvider.notifier).setMessage(value);
                  // },
                ),
              ),
              SizedBox(height: context.sp(12)),
              PrimarySmallButton(
                onTap: () => context.read<CreateFelicitupBloc>().add(
                      CreateFelicitupEvent.createFelicitup(messageController.text),
                    ),
                label: 'Crear felicitup',
                isActive: true,
                isCollapsed: true,
              ),
              Visibility(
                visible: true,
                child: SizedBox(
                  height: context.sp(200),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResumenCard extends StatelessWidget {
  const _ResumenCard({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: context.sp(30),
        width: context.sp(193),
        padding: EdgeInsets.symmetric(
          horizontal: context.sp(12),
        ),
        margin: EdgeInsets.only(
          bottom: context.sp(12),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.sp(5)),
          color: const Color(0xFFF4F2F2),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: context.styles.menu.copyWith(
                fontSize: context.sp(9),
              ),
            ),
            const Spacer(),
            Text(
              'Editar',
              style: context.styles.menu.copyWith(
                decoration: TextDecoration.underline,
                fontSize: context.sp(9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
