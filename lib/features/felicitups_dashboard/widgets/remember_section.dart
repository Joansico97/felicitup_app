import 'package:animate_do/animate_do.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/felicitups_dashboard/widgets/widgets.dart';
import 'package:felicitup_app/features/home/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RememberSection extends StatelessWidget {
  const RememberSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDownBig(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: context.sp(192),
          minHeight: context.sp(50),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: context.sp(26),
          vertical: context.sp(22),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.sp(20)),
          color: Colors.white.withAlpha((.4 * 255).toInt()),
          border: Border.all(
            color: Colors.white,
            width: context.sp(2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: context.sp(28),
              width: context.sp(119),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.sp(20)),
                color: Colors.white,
              ),
              child: Text(
                'Cumpleaños',
                style: context.styles.smallText.copyWith(
                  color: context.colors.softOrange,
                ),
              ),
            ),
            SizedBox(height: context.sp(8)),
            ...List.generate(
              1,
              // currentUser?.birthdateAlerts?.length ?? 0,
              (index) {
                // final data = currentUser?.birthdateAlerts?[index];

                return RememberCard(
                  // name: data.friendName ?? '',
                  name: 'Jorge Silva',
                  date: DateTime.now(),
                  onTap: () {
                    customModal(
                      title: 'Qué acción deseas realizar?',
                      isColapsed: true,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              context.read<HomeBloc>().add(HomeEvent.changeCreate());
                              // ref.read(homeEventsProvider.notifier).getUserInfoForFelicitup(
                              //     userId: data.friendId ?? 'lU0xFuUmIjQzkXwMPkpCrlg3oNg2');
                              context.pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colors.orange,
                              disabledBackgroundColor: context.colors.lightGrey,
                              elevation: 0,
                            ),
                            child: Text(
                              'Crear felicitup para este usuario',
                              style: context.styles.paragraph.copyWith(
                                color: context.colors.grey,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              // await ref.read(homeEventsProvider.notifier).createSingleChat(
                              //       userId: data.friendId ?? 'lU0xFuUmIjQzkXwMPkpCrlg3oNg2',
                              //       userName: data.friendName ?? 'Jorge Silva',
                              // );
                              context.pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colors.orange,
                              disabledBackgroundColor: context.colors.lightGrey,
                              elevation: 0,
                            ),
                            child: Text(
                              'Enviar mensaje directo',
                              style: context.styles.paragraph.copyWith(
                                color: context.colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
