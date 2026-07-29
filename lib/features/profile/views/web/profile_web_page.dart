import 'dart:io';

import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/constants/constants.dart';
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

class ProfileWebPage extends StatefulWidget {
  const ProfileWebPage({super.key});

  @override
  State<ProfileWebPage> createState() => _ProfileWebPageState();
}

class _ProfileWebPageState extends State<ProfileWebPage> {
  File? imageFile;
  String? avatarUrl;
  bool canSave = false;
  late List<String> listAvatares;

  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  DateTime? editedBirthdate;

  @override
  void initState() {
    super.initState();
    listAvatares = [Env.avatar1, Env.avatar2, Env.avatar3, Env.avatar4];
  }

  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AppBloc>().state.currentUser;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.sp(20),
            vertical: context.sp(40),
          ),
          child: SizedBox(
            width: context.sp(500),
            child: Container(
              padding: EdgeInsets.all(context.sp(24)),
              decoration: BoxDecoration(
                color: context.colors.backgroundModal,
                borderRadius: BorderRadius.circular(context.sp(24)),
                border: Border.all(color: context.colors.lightGrey),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CollapsedHeader(
                    title: context.locale.profile_title,
                    onPressed: () async =>
                        context.go(RouterPaths.felicitupsDashboard),
                    secondaryAction: GestureDetector(
                      onTap: () => context.go(RouterPaths.deleteAccount),
                      child: Container(
                        width: context.sp(30),
                        height: context.sp(30),
                        margin: EdgeInsets.only(right: context.sp(8)),
                        decoration: BoxDecoration(
                          color: context.colors.lightGrey,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person_off, size: context.sp(18)),
                      ),
                    ),
                  ),
                  SizedBox(height: context.sp(20)),
                  GestureDetector(
                    onTap: () {
                      customModal(
                        title: context.locale.select_image_source,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                context.locale.gallery,
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
                                context.locale.camera,
                                style: context.styles.paragraph.copyWith(
                                  color: context.colors.white,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                context.pop();
                                customModal(
                                  title: context.locale.select_avatar,
                                  child: Wrap(
                                    spacing: context.sp(12),
                                    runSpacing: context.sp(12),
                                    children: [
                                      ...List.generate(
                                        listAvatares.length,
                                        (index) => GestureDetector(
                                          onTap: () => setState(() {
                                            imageFile = null;
                                            avatarUrl = listAvatares[index];
                                            context.read<ProfileBloc>().add(
                                                  ProfileEvent
                                                      .updateUserImageFromUrl(
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
                                                minWidth: context.sp(0),
                                              ),
                                            ),
                                            child: Chip(
                                              backgroundColor:
                                                  context.colors.background,
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
                                                  child: CommonNetworkImage(
                                                    imageUrl:
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
                                context.locale.avatars,
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
                      height: context.sp(140),
                      width: context.sp(140),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.colors.lightGrey,
                      ),
                      child: avatarUrl != null
                          ? SizedBox(
                              height: context.sp(140),
                              width: context.sp(140),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  context.sp(70),
                                ),
                                child: CommonNetworkImage(
                                  imageUrl: avatarUrl!,
                                ),
                              ),
                            )
                          : imageFile != null
                              ? SizedBox(
                                  height: context.sp(140),
                                  width: context.sp(140),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      context.sp(70),
                                    ),
                                    child: Image.file(
                                      imageFile!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : currentUser?.userImg != ''
                                  ? SizedBox(
                                      height: context.sp(140),
                                      width: context.sp(140),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          context.sp(70),
                                        ),
                                        child: CommonNetworkImage(
                                          imageUrl: currentUser?.userImg ?? '',
                                        ),
                                      ),
                                    )
                                  : Text(
                                      currentUser?.fullName![0] ?? '',
                                      style: context.styles.header1,
                                    ),
                    ),
                  ),
                  SizedBox(height: context.sp(24)),
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
                  GestureDetector(
                    onTap: () async {
                      DateTime? birthDate;
                      await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(
                            context.locale.birthday_modal_question_title,
                            style: context.styles.header2,
                          ),
                          content: DatePickerWidget(
                            onSelectNewDate: (date) {
                              birthDate = date;
                            },
                            initialDate:
                                currentUser?.birthDate ?? DateTime.now(),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  editedBirthdate = birthDate;
                                });
                                context.pop();
                              },
                              child: Text(
                                context.locale.accept,
                                style: context.styles.buttons,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: InfoCard(
                      label: currentUser?.birthDate == null
                          ? context.locale.enter_birthdate
                          : DateFormat(
                              AppConstants.birthDateFormat,
                              'es',
                            ).format(
                              editedBirthdate ??
                                  currentUser?.birthDate ??
                                  DateTime.now(),
                            ),
                      icon: Icons.edit,
                    ),
                  ),
                  SizedBox(height: context.sp(24)),
                  SizedBox(
                    width: context.sp(300),
                    height: context.sp(50),
                    child: BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (_, state) {
                        return PrimaryButton(
                          onTap: () {
                            context.read<ProfileBloc>().add(
                                  ProfileEvent.updateUserInfo(
                                    UserModel(
                                      id: currentUser?.id,
                                      firstName: nameController.text.isNotEmpty
                                          ? nameController.text
                                          : currentUser?.firstName,
                                      lastName:
                                          lastNameController.text.isNotEmpty
                                              ? lastNameController.text
                                              : currentUser?.lastName,
                                      fullName:
                                          nameController.text.isNotEmpty &&
                                                  lastNameController
                                                      .text.isNotEmpty
                                              ? '${nameController.text} ${lastNameController.text}'
                                              : currentUser?.fullName,
                                      email: currentUser?.email,
                                      isoCode: currentUser?.isoCode,
                                      phone: currentUser?.phone,
                                      userImg: currentUser?.userImg,
                                      fcmToken: currentUser?.fcmToken,
                                      currentChat: currentUser?.currentChat,
                                      friendList: currentUser?.friendList,
                                      birthdateAlerts:
                                          currentUser?.birthdateAlerts,
                                      matchList: currentUser?.matchList,
                                      friendsPhoneList:
                                          currentUser?.friendsPhoneList,
                                      giftcardList: currentUser?.giftcardList,
                                      notifications:
                                          currentUser?.notifications,
                                      singleChats: currentUser?.singleChats,
                                      birthDate: editedBirthdate ??
                                          currentUser?.birthDate,
                                      birthDay: editedBirthdate?.day ??
                                          currentUser?.birthDay,
                                      birthMonth: editedBirthdate?.month ??
                                          currentUser?.birthMonth,
                                      registerDate: currentUser?.registerDate,
                                    ),
                                  ),
                                );
                          },
                          label: context.locale.save_changes,
                          isActive: true,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
