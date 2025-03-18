import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/details_felicitup/details_felicitup_dashboard/bloc/details_felicitup_dashboard_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VideoFelicitupPage extends StatelessWidget {
  const VideoFelicitupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailsFelicitupDashboardBloc, DetailsFelicitupDashboardState>(
      builder: (_, state) {
        final felicitup = state.felicitup;
        final currentUser = context.read<AppBloc>().state.currentUser;

        return Scaffold(
          backgroundColor: context.colors.background,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.sp(90)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (felicitup!.createdBy == currentUser!.id)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FloatingActionButton(
                        heroTag: '3',
                        onPressed: () => showConfirmModal(
                          title:
                              'Estás seguro de querer mixear los videos de ${felicitup.reason} de ${felicitup.owner.first.name}?',
                          onAccept: () async {},
                        ),
                        backgroundColor: context.colors.orange,
                        child: Icon(
                          Icons.cameraswitch_rounded,
                          color: context.colors.white,
                        ),
                      ),
                    ],
                  ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      heroTag: '4',
                      onPressed: felicitup.finalVideoUrl != null && felicitup.finalVideoUrl!.isNotEmpty ? () {} : null,
                      backgroundColor: felicitup.finalVideoUrl != null && felicitup.finalVideoUrl!.isNotEmpty
                          ? context.colors.orange
                          : context.colors.grey,
                      child: Icon(
                        Icons.play_arrow,
                        color: context.colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: Center(
            child: Text('Video Felicitup Page'),
          ),
        );
      },
    );
  }
}
