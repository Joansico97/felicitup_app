import 'dart:async';
import 'dart:io';

import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/utils/env.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/profile/bloc/profile_bloc.dart';
import 'package:felicitup_app/features/profile/widgets/widgets.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? imageFile;
  String? avatarUrl;
  bool canSave = false;
  String phone = '';
  String isoCode = '';
  String label = '';
  late List<String> listAvatares;

  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  String getLabel(String isoCode, String phone) {
    if (isoCode == '+1') {
      return phone.substring(2);
    } else {
      return phone.substring(3);
    }
  }

  @override
  void initState() {
    super.initState();
    listAvatares = [Env.avatar1, Env.avatar2, Env.avatar3, Env.avatar4];
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AppBloc>().state.currentUser;

    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen:
          (previous, current) =>
              previous.isLoading != current.isLoading ||
              previous.status != current.status,
      listener: (_, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }

        if (state.status == ProfileStatus.success) {
          context.read<AppBloc>().add(AppEvent.loadUserData());
          context.go(RouterPaths.felicitupsDashboard);
        }
      },
      child: Scaffold(
        persistentFooterAlignment: AlignmentDirectional.bottomCenter,
        persistentFooterButtons: [
          Column(
            children: [
              SizedBox(
                width: context.sp(300),
                child: PrimaryButton(
                  onTap: () => context.go(RouterPaths.deleteAccount),
                  label: 'Elimiar cuenta',
                  isActive: true,
                ),
              ),
              SizedBox(height: context.sp(12)),
              SizedBox(
                width: context.sp(300),
                child: BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (_, state) {
                    return PrimaryButton(
                      onTap: () {
                        context.read<ProfileBloc>().add(
                          ProfileEvent.updateUserInfo(
                            UserModel(
                              id: currentUser?.id,
                              firstName:
                                  nameController.text.isNotEmpty
                                      ? nameController.text
                                      : currentUser?.firstName,
                              lastName:
                                  lastNameController.text.isNotEmpty
                                      ? lastNameController.text
                                      : currentUser?.lastName,
                              fullName:
                                  nameController.text.isNotEmpty &&
                                          lastNameController.text.isNotEmpty
                                      ? '${nameController.text} ${lastNameController.text}'
                                      : currentUser?.fullName,
                              email: currentUser?.email,
                              isoCode:
                                  isoCode.isNotEmpty
                                      ? isoCode
                                      : currentUser?.isoCode,
                              phone:
                                  phone.isNotEmpty ? phone : currentUser?.phone,
                              userImg: currentUser?.userImg,
                              fcmToken: currentUser?.fcmToken,
                              currentChat: currentUser?.currentChat,
                              friendList: currentUser?.friendList,
                              birthdateAlerts: currentUser?.birthdateAlerts,
                              matchList: currentUser?.matchList,
                              friendsPhoneList: currentUser?.friendsPhoneList,
                              giftcardList: currentUser?.giftcardList,
                              notifications: currentUser?.notifications,
                              singleChats: currentUser?.singleChats,
                              birthDate: currentUser?.birthDate,
                              registerDate: currentUser?.registerDate,
                            ),
                          ),
                        );
                      },
                      label: 'Guardar cambios',
                      isActive: true,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
        extendBody: true,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: Column(
              children: [
                CollapsedHeader(
                  title: 'Perfil',
                  onPressed:
                      () async => context.go(RouterPaths.felicitupsDashboard),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: context.sp(12)),
                        GestureDetector(
                          onTap: () {
                            customModal(
                              title: 'Seleccionar una fuente para la imagen',
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      imageFile = await pickImageFromGallery();
                                      if (imageFile != null) {
                                        setState(() {
                                          canSave = true;
                                        });
                                        context.read<ProfileBloc>().add(
                                          ProfileEvent.updateUserImageFromFile(
                                            imageFile!,
                                          ),
                                        );
                                      }
                                      context.pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: context.colors.orange,
                                      disabledBackgroundColor:
                                          context.colors.lightGrey,
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      'Galería',
                                      style: context.styles.paragraph.copyWith(
                                        color: context.colors.white,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      imageFile = await pickImageFromCamera();
                                      if (imageFile != null) {
                                        setState(() {
                                          canSave = true;
                                        });
                                        context.read<ProfileBloc>().add(
                                          ProfileEvent.updateUserImageFromFile(
                                            imageFile!,
                                          ),
                                        );
                                      }
                                      context.pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: context.colors.orange,
                                      disabledBackgroundColor:
                                          context.colors.lightGrey,
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      'Cámara',
                                      style: context.styles.paragraph.copyWith(
                                        color: context.colors.white,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.pop();
                                      customModal(
                                        title: 'Seleccionar un avatar',
                                        child: Wrap(
                                          spacing: context.sp(12),
                                          runSpacing: context.sp(12),
                                          children: [
                                            ...List.generate(
                                              listAvatares.length,
                                              (index) => GestureDetector(
                                                onTap:
                                                    () => setState(() {
                                                      imageFile = null;
                                                      avatarUrl =
                                                          listAvatares[index];
                                                      context
                                                          .read<ProfileBloc>()
                                                          .add(
                                                            ProfileEvent.updateUserImageFromUrl(
                                                              avatarUrl!,
                                                            ),
                                                          );
                                                      canSave = true;
                                                      context.pop();
                                                    }),
                                                child: ChipTheme(
                                                  data: ChipThemeData(
                                                    deleteIconBoxConstraints:
                                                        BoxConstraints(
                                                          minWidth: context.sp(
                                                            0,
                                                          ),
                                                        ),
                                                  ),
                                                  child: Chip(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    side: BorderSide.none,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            context.sp(100),
                                                          ),
                                                    ),
                                                    label: SizedBox(
                                                      height: context.sp(60),
                                                      width: context.sp(60),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              context.sp(100),
                                                            ),
                                                        child: Image.network(
                                                          listAvatares[index],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: context.colors.orange,
                                      disabledBackgroundColor:
                                          context.colors.lightGrey,
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      'Avatares',
                                      style: context.styles.paragraph.copyWith(
                                        color: context.colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            height: context.sp(200),
                            width: context.sp(200),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.colors.lightGrey,
                            ),
                            child:
                                avatarUrl != null
                                    ? SizedBox(
                                      height: context.sp(200),
                                      width: context.sp(200),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          context.sp(100),
                                        ),
                                        child: Image.network(
                                          avatarUrl!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                    : imageFile != null
                                    ? SizedBox(
                                      height: context.sp(200),
                                      width: context.sp(200),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          context.sp(100),
                                        ),
                                        child: Image.file(
                                          imageFile!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                    : currentUser?.userImg != ''
                                    ? SizedBox(
                                      height: context.sp(200),
                                      width: context.sp(200),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          context.sp(100),
                                        ),
                                        child: Image.network(
                                          currentUser?.userImg ?? '',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                    : Text(
                                      currentUser?.fullName![0] ?? '',
                                      style: context.styles.header1,
                                    ),
                          ),
                        ),
                        SizedBox(height: context.sp(32)),
                        EditInputField(
                          controller: nameController,
                          hintText: currentUser?.firstName ?? '',
                        ),
                        SizedBox(height: context.sp(12)),
                        EditInputField(
                          controller: lastNameController,
                          hintText: currentUser?.lastName ?? '',
                        ),
                        SizedBox(height: context.sp(12)),
                        InfoCard(label: currentUser?.email ?? ''),
                        SizedBox(height: context.sp(12)),
                        InfoCard(
                          label: DateFormat(
                            'dd·MM·yyyy',
                          ).format(currentUser?.birthDate ?? DateTime.now()),
                        ),
                        SizedBox(height: context.sp(12)),
                        Container(
                          width: context.sp(300),
                          padding: EdgeInsets.symmetric(
                            horizontal: context.sp(16),
                            vertical: context.sp(16),
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.lightGrey,
                            borderRadius: BorderRadius.circular(context.sp(8)),
                          ),
                          child: IntlPhoneField(
                            languageCode: 'es',
                            decoration: InputDecoration(
                              labelText: getLabel(
                                currentUser?.isoCode ?? '',
                                currentUser?.phone ?? '',
                              ),
                              labelStyle: context.styles.smallText,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            initialCountryCode:
                                (currentUser?.isoCode ?? '') == '+34'
                                    ? 'ES'
                                    : 'CO',
                            onChanged: (value) {
                              setState(() {
                                phone = value.completeNumber;
                                isoCode = value.countryCode;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.sp(300),
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(16),
        vertical: context.sp(16),
      ),
      decoration: BoxDecoration(
        color: context.colors.lightGrey,
        borderRadius: BorderRadius.circular(context.sp(8)),
      ),
      child: Text(
        label,
        style: context.styles.paragraph.copyWith(
          color: context.colors.darkGrey,
        ),
      ),
    );
  }
}
