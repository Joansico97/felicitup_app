import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/data/resources/resources.dart';
import 'package:felicitup_app/injection/injection_container.dart' as injection;
import 'package:felicitup_app/core/constants/constants.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/theme/theme.dart';
import 'package:felicitup_app/gen/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class FelicitupApp extends StatelessWidget {
  const FelicitupApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = CustomRouter().router;
    final appBloc = injection.di<AppBloc>();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => injection.di<AuthRepository>(),
        ),
        RepositoryProvider<UserRepository>(
          create: (_) => injection.di<UserRepository>(),
        ),
        RepositoryProvider<FelicitupRepository>(
          create: (_) => injection.di<FelicitupFirebaseResource>(),
        ),
        RepositoryProvider<ChatRepository>(
          create: (_) => injection.di<ChatFirebaseResource>(),
        ),
      ],
      child: BlocProvider<AppBloc>(
        create: (_) => appBloc,
        child: BlocBuilder<AppBloc, AppState>(
          builder: (_, state) {
            return MaterialApp.router(
              title: AppConstants.appTitle,
              localizationsDelegates: const [
                IntlTrans.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: IntlTrans.delegate.supportedLocales,
              theme: AppTheme().getTheme(),
              routerConfig: router,
            );
          },
        ),
      ),
    );
  }
}
