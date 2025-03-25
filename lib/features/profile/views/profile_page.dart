import 'dart:async';
import 'dart:io';

import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/profile/bloc/profile_bloc.dart';
import 'package:felicitup_app/features/profile/widgets/widgets.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? imageFile;
  String? avatarUrl;
  bool canSave = false;

  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AppBloc>().state.currentUser;

    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) => previous.isLoading != current.isLoading || previous.status != current.status,
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
          SizedBox(
            width: context.sp(300),
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (_, state) {
                return PrimaryButton(
                  onTap: () {
                    if (imageFile != null) {
                      // await ref.read(userEventsProvider.notifier).updateUserImage(imageFile!);
                    }
                    if (avatarUrl != null) {
                      context.read<ProfileBloc>().add(ProfileEvent.updateUserImageFromUrl(avatarUrl!));
                    }
                    if (context.mounted) {
                      setState(() {
                        imageFile = null;
                        canSave = false;
                      });
                    }
                  },
                  label: 'Guardar cambios',
                  isActive: true,
                );
              },
            ),
          ),
        ],
        extendBody: true,
        body: SafeArea(
          child: Column(
            children: [
              CollapsedHeader(
                title: 'Perfil',
                onPressed: () async => context.go(RouterPaths.felicitupsDashboard),
              ),
              Expanded(
                child: Column(
                  children: [
                    SizedBox(height: context.sp(12)),
                    GestureDetector(
                      onTap: () {
                        customModal(
                          title: 'Seleccionar una fuente para la imagen',
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  imageFile = await pickImageFromGallery();
                                  setState(() {
                                    if (imageFile != null) {
                                      canSave = true;
                                    }
                                  });
                                  context.pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context.colors.orange,
                                  disabledBackgroundColor: context.colors.lightGrey,
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
                                  setState(() {
                                    if (imageFile != null) {
                                      canSave = true;
                                    }
                                  });
                                  context.pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context.colors.orange,
                                  disabledBackgroundColor: context.colors.lightGrey,
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
                                          avataresList.length,
                                          (index) => GestureDetector(
                                            onTap: () => setState(() {
                                              imageFile = null;
                                              avatarUrl = avataresList[index];
                                              canSave = true;
                                              Navigator.of(rootNavigatorKey.currentContext!).pop();
                                            }),
                                            child: ChipTheme(
                                              data: ChipThemeData(
                                                deleteIconBoxConstraints: BoxConstraints(
                                                  minWidth: context.sp(0),
                                                ),
                                              ),
                                              child: Chip(
                                                backgroundColor: Colors.transparent,
                                                side: BorderSide.none,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(context.sp(100)),
                                                ),
                                                label: SizedBox(
                                                  height: context.sp(60),
                                                  width: context.sp(60),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(context.sp(100)),
                                                    child: Image.network(
                                                      avataresList[index],
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
                                  disabledBackgroundColor: context.colors.lightGrey,
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
                        child: avatarUrl != null
                            ? SizedBox(
                                height: context.sp(200),
                                width: context.sp(200),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(context.sp(100)),
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
                                      borderRadius: BorderRadius.circular(context.sp(100)),
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
                                          borderRadius: BorderRadius.circular(context.sp(100)),
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
                    Container(
                      height: context.sp(20),
                      width: context.sp(300),
                      decoration: BoxDecoration(
                        color: context.colors.lightGrey,
                        borderRadius: BorderRadius.circular(context.sp(4)),
                      ),
                    ),
                    // SizedBox(height: context.sp(12)),
                    // EditInputField(
                    //   controller: nameController,
                    //   hintText: currentUser?.firstName ?? '',
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
