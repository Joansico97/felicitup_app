import 'dart:async';
import 'dart:io';

import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/contacts/bloc/contacts_bloc.dart';
import 'package:felicitup_app/features/contacts/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContactsBloc, ContactsState>(
      listenWhen: (previous, current) =>
          previous.isLoading != current.isLoading ||
          previous.reloadContacts != current.reloadContacts,
      listener: (_, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }
        if (state.reloadContacts) {
          context.read<AppBloc>()
            ..add(AppEvent.loadUserData())
            ..add(AppEvent.loadContacts());
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              final currentUser = context.read<AppBloc>().state.currentUser;

              if (currentUser != null) {
                context.read<AppBloc>().add(AppEvent.loadContacts());
              }
            },
            child: Column(
              children: [
                CollapsedHeader(
                  title: 'Contactos',
                  onPressed: () async =>
                      context.go(RouterPaths.felicitupsDashboard),
                  secondaryAction:
                      context.read<AppBloc>().state.contactsPermissionStatus ==
                          PermissionStatus.limited
                      ? IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => Material(
                                color: Colors.transparent,
                                child: AlertDialog(
                                  backgroundColor: context.colors.white,
                                  title: Row(
                                    children: [
                                      Text(
                                        'Ingresar contacto manualmente',
                                        style: context.styles.paragraph
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      SizedBox(width: context.sp(12)),
                                      GestureDetector(
                                        onTap: () {
                                          nameController.clear();
                                          numberController.clear();
                                          context.pop();
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(
                                            context.sp(4),
                                          ),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: context.colors.orange,
                                          ),
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.close,
                                            color: context.colors.white,
                                            size: context.sp(20),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InputCommon(
                                        controller: nameController,
                                        hintText: 'Nombre del contacto',
                                        titleText: 'Nombre',
                                      ),
                                      SizedBox(height: context.sp(12)),
                                      InputCommon(
                                        controller: numberController,
                                        hintText: 'Número del contacto',
                                        titleText: 'Número',
                                      ),
                                      SizedBox(height: context.sp(12)),
                                      PrimaryButton(
                                        label: 'Agregar contacto',
                                        onTap: () async {
                                          context.read<ContactsBloc>().add(
                                            ContactsEvent.addManualContact(
                                              user: {
                                                'name': nameController.text,
                                                'phone': numberController.text,
                                              },
                                              isoCode:
                                                  context
                                                      .read<AppBloc>()
                                                      .state
                                                      .currentUser
                                                      ?.isoCode ??
                                                  '',
                                            ),
                                          );
                                          nameController.clear();
                                          numberController.clear();
                                          context.pop();
                                        },
                                        isCollapsed: true,
                                        isActive: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          icon: Icon(Icons.add, color: Colors.black),
                        )
                      : null,
                ),
                SizedBox(height: context.sp(12)),
                Expanded(
                  child: BlocBuilder<AppBloc, AppState>(
                    buildWhen: (previous, current) =>
                        previous.dataList != current.dataList ||
                        previous.isLoadingContacts != current.isLoadingContacts,
                    builder: (_, state) {
                      final listData = state.dataList;

                      if (state.isLoadingContacts) {
                        return Center(child: CircularProgressIndicator());
                      }

                      return ListView.builder(
                        itemCount: listData?.length ?? 0,
                        itemBuilder: (_, index) => ElementCardRow(
                          contact: listData?[index]['contact'] as ContactModel,
                          isRegistered:
                              listData?[index]['isRegistered'] as bool,
                          giftcars: null,
                        ),
                      );
                    },
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
