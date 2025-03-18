import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/features/felicitups_dashboard/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DrawerApp extends StatelessWidget {
  const DrawerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.sp(230),
      color: context.colors.lightGrey,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SettingsButton(
              onTap: () {
                // UserModel currentUser = ref.read(appEventsProvider.select((state) => state.currentUser!));
                // context.push(
                //   RouterPaths.profile,
                //   extra: {
                //     'user': currentUser,
                //   },
                // );
                Scaffold.of(context).closeDrawer();
              },
              label: 'Perfil',
              icon: Icons.person,
            ),
            SettingsButton(
              onTap: () {
                context.push(RouterPaths.giftcard);
                Scaffold.of(context).closeDrawer();
              },
              label: 'Lista de deseos',
              icon: Icons.card_giftcard_outlined,
            ),
            SettingsButton(
              onTap: () {
                context.push(RouterPaths.listSingleChat);
                Scaffold.of(context).closeDrawer();
              },
              label: 'Mesnajes directos',
              icon: Icons.mail_outline,
            ),
            SettingsButton(
              onTap: () {
                context.push(RouterPaths.contacts);
                Scaffold.of(context).closeDrawer();
              },
              label: 'Contactos',
              icon: Icons.contacts_outlined,
            ),
            SettingsButton(
              onTap: () {
                context.push(RouterPaths.notificationsSettings);
                Scaffold.of(context).closeDrawer();
              },
              label: 'Configuración de notificaciones',
              icon: Icons.notifications_rounded,
            ),
            SettingsButton(
              onTap: () {
                context.read<AppBloc>().add(AppEvent.logout());
                context.go(RouterPaths.init);
                Scaffold.of(context).closeDrawer();
              },
              label: 'Cerrar sesión',
              icon: Icons.logout,
            ),
          ],
        ),
      ),
    );
  }
}
