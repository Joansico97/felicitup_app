import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/features/felicitups_dashboard/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DrawerApp extends StatefulWidget {
  const DrawerApp({super.key});

  @override
  State<DrawerApp> createState() => _DrawerAppState();
}

class _DrawerAppState extends State<DrawerApp> {
  String _appVersion = 'Cargando...';

  @override
  void initState() {
    super.initState();
    _loadVersionInfo(); // Llama a la función para cargar la versión
  }

  Future<void> _loadVersionInfo() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = 'v${packageInfo.version}+${packageInfo.buildNumber}';
      });
    } catch (e) {
      logger.info("Error al obtener la versión: $e");
      setState(() {
        _appVersion = 'Error al obtener versión';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.sp(260),
      color: context.colors.lightGrey,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SettingsButton(
              onTap: () {
                context.go(RouterPaths.profile);
                Scaffold.of(context).closeDrawer();
              },
              label: 'Perfil',
              icon: Icons.person,
            ),
            SettingsButton(
              onTap: () {
                context.go(RouterPaths.wishList);
                Scaffold.of(context).closeDrawer();
              },
              label: 'Lista de deseos',
              icon: Icons.card_giftcard_outlined,
            ),
            SettingsButton(
              onTap: () {
                context.go(RouterPaths.listSingleChat);
                Scaffold.of(context).closeDrawer();
              },
              label: 'Mensajes directos',
              icon: Icons.mail_outline,
            ),
            SettingsButton(
              onTap: () {
                context.go(RouterPaths.contacts);
                Scaffold.of(context).closeDrawer();
              },
              label: 'Contactos',
              icon: Icons.contacts_outlined,
            ),
            SettingsButton(
              onTap: () {
                context.go(RouterPaths.reminders);
                Scaffold.of(context).closeDrawer();
              },
              label: 'Recordatorios',
              icon: Icons.calendar_month_outlined,
            ),
            SettingsButton(
              onTap: () {
                context.go(RouterPaths.notificationsSettings);
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
            Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.sp(20)),
              child: Text(_appVersion, style: context.styles.smallText),
            ),
          ],
        ),
      ),
    );
  }
}
