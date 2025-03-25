import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/create_felicitup/bloc/create_felicitup_bloc.dart';
import 'package:felicitup_app/features/create_felicitup/widgets/widgets.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SelectEventView extends StatefulWidget {
  const SelectEventView({
    super.key,
  });

  @override
  State<SelectEventView> createState() => _SelectEventViewState();
}

final List<String> eventsName = [
  'Cumpleaños',
  'Aniversario',
  'Bautizo',
  'Evento Familiar',
  'Evento de Empresa',
  'Otro',
];

class _SelectEventViewState extends State<SelectEventView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.sp(20),
          ),
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
                      '| Paso 02',
                      style: context.styles.menu.copyWith(
                        fontSize: context.sp(9),
                      ),
                    ),
                    SizedBox(height: context.sp(8)),
                    BlocBuilder<CreateFelicitupBloc, CreateFelicitupState>(
                      builder: (_, state) {
                        final listOwner = state.felicitupOwner;
                        final reason = state.eventReason;
                        final selectedDate = state.selectedDate ?? listOwner[0].date;

                        return RichText(
                          text: TextSpan(
                            text: reason.isEmpty
                                ? 'Selecciona un evento'
                                : listOwner.length > 2
                                    ? '$reason de ${listOwner[0].name}, de ${listOwner[1].name} y de ${listOwner.length - 2} más'
                                    : listOwner.length == 2
                                        ? '$reason de ${listOwner[0].name} y de ${listOwner[1].name}'
                                        : '$reason de ${listOwner[0].name}',
                            style: context.styles.smallText,
                            children: [
                              reason.isNotEmpty
                                  ? TextSpan(
                                      text:
                                          '\n\n${DateFormat('dd·MM·yyyy').format(selectedDate)} - ${DateFormat('HH:mm').format(selectedDate)}',
                                      style: context.styles.smallText.copyWith(
                                        fontSize: context.sp(10),
                                      ),
                                    )
                                  : TextSpan(),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: context.sp(8)),
                    BlocBuilder<CreateFelicitupBloc, CreateFelicitupState>(
                      builder: (_, state) {
                        final reason = state.eventReason;

                        return Visibility(
                          visible: reason.isEmpty,
                          child: Text(
                            'Selecciona el motivo del evento para la Felicitup.',
                            style: context.styles.smallText.copyWith(
                              fontSize: context.sp(10),
                            ),
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
        SizedBox(height: context.sp(12)),
        BlocBuilder<CreateFelicitupBloc, CreateFelicitupState>(
          builder: (_, state) {
            final reason = state.eventReason;

            return PrimarySmallButton(
              onTap: () {
                commoBottomModal(
                  context: context,
                  onTap: () {},
                  hasSearch: false,
                  body: BlocBuilder<CreateFelicitupBloc, CreateFelicitupState>(
                    builder: (_, state) {
                      final eventReason = state.eventReason;

                      return Column(
                        children: [
                          ...List.generate(
                            eventsName.length,
                            (index) => GestureDetector(
                              onTap: () {
                                context
                                    .read<CreateFelicitupBloc>()
                                    .add(CreateFelicitupEvent.changeEventReason(eventsName[index]));
                                context.pop();
                              },
                              child: EventCardRow(
                                eventName: eventsName[index],
                                isSelected: eventReason == eventsName[index],
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  ),
                );
              },
              // onTap: () => ref.read(appEventsProvider.notifier).showEventModal(eventsName),
              label: reason.isEmpty ? 'Seleccionar motivo' : 'Cambiar motivo',
              isActive: true,
              isCollapsed: true,
            );
          },
        ),
        SizedBox(height: context.sp(12)),
      ],
    );
  }
}
