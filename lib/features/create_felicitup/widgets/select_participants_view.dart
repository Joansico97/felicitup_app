import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/create_felicitup/bloc/create_felicitup_bloc.dart';
import 'package:felicitup_app/features/create_felicitup/widgets/widgets.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class SelectParticipantsView extends StatefulWidget {
  const SelectParticipantsView({
    super.key,
  });

  @override
  State<SelectParticipantsView> createState() => _SelectParticipantsViewState();
}

class _SelectParticipantsViewState extends State<SelectParticipantsView> {
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
                      '| Paso 03',
                      style: context.styles.menu.copyWith(
                        fontSize: context.sp(9),
                      ),
                    ),
                    SizedBox(height: context.sp(8)),
                    Text(
                      '¿Quién participa?',
                      style: context.styles.smallText,
                    ),
                    SizedBox(height: context.sp(8)),
                    Text(
                      'Selecciona los participantes de la Felicitup.',
                      style: context.styles.smallText.copyWith(
                        fontSize: context.sp(10),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.sp(12)),
        PrimarySmallButton(
          onTap: () {
            commoBottomModal(
              context: context,
              body: BlocBuilder<CreateFelicitupBloc, CreateFelicitupState>(
                builder: (_, state) {
                  final listOwner = state.felicitupOwner;
                  List<UserModel> friendList = [...state.friendList];
                  friendList.removeWhere((element) => listOwner.any((owner) => owner.id == element.id));
                  friendList.sort((a, b) => a.fullName!.compareTo(b.fullName!));
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
                                  final participant = InvitedModel(
                                    id: friendList[index].id,
                                    name: friendList[index].fullName,
                                    userImage: friendList[index].userImg,
                                    assistanceStatus: enumToStringAssistance(AssistanceStatus.pending),
                                    videoData: VideoDataModel(
                                      videoUrl: '',
                                      videoThumbnail: '',
                                    ),
                                    paid: enumToStringPayment(PaymentStatus.pending),
                                    idInformation: '',
                                  );
                                  context.read<CreateFelicitupBloc>().add(
                                        CreateFelicitupEvent.addParticipant(participant),
                                      );
                                },
                                child: ContactCardRow(
                                  contact: friendList[index],
                                  isSelected: state.invitedContacts
                                      .any((participant) => participant.id == friendList[index].id),
                                ),
                              ),
                            ),
                          ],
                        );
                },
              ),
            );
          },
          label: 'Buscar contactos',
          isActive: true,
          isCollapsed: true,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.sp(20),
          ),
          child: BlocBuilder<CreateFelicitupBloc, CreateFelicitupState>(
            builder: (_, state) {
              final listParticipants = state.invitedContacts;

              return Visibility(
                visible: listParticipants.isNotEmpty,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: context.sp(300),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: context.sp(12)),
                        ...List.generate(
                          listParticipants.length,
                          (index) => OnlyViewCardRow(
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
      ],
    );
  }
}
