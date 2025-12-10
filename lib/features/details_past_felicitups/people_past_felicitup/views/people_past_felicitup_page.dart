import 'package:collection/collection.dart';
import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/details_past_felicitups/details_past_felicitups.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PeoplePastFelicitupPage extends StatefulWidget {
  const PeoplePastFelicitupPage({super.key});

  @override
  State<PeoplePastFelicitupPage> createState() =>
      _PeoplePastFelicitupPageState();
}

class _PeoplePastFelicitupPageState extends State<PeoplePastFelicitupPage> {
  @override
  void initState() {
    super.initState();
    final felicitup = context
        .read<DetailsPastFelicitupDashboardBloc>()
        .state
        .felicitup;
    if (felicitup != null) {
      context.read<PeoplePastFelicitupBloc>()
        ..add(PeoplePastFelicitupEvent.loadFriendsData(felicitup.invitedUsers))
        ..add(PeoplePastFelicitupEvent.startListening(felicitup.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      DetailsPastFelicitupDashboardBloc,
      DetailsPastFelicitupDashboardState
    >(
      builder: (_, state) {
        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              context.go(RouterPaths.felicitupsDashboard);
            }
          },
          child: Scaffold(
            backgroundColor: context.colors.background,
            body: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: context.sp(40),
                    width: context.sp(113),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(context.sp(20)),
                      color: context.colors.white,
                    ),
                    child: Text(
                      'Participantes',
                      style: context.styles.smallText.copyWith(
                        color: context.colors.softOrange,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: context.sp(22)),
                BlocBuilder<PeoplePastFelicitupBloc, PeoplePastFelicitupState>(
                  buildWhen: (previous, current) =>
                      previous.invitedUsers != current.invitedUsers ||
                      previous.friendList != current.friendList,
                  builder: (_, state) {
                    final invitedUsers = state.invitedUsers;
                    final friendList = state.friendList;

                    return Expanded(
                      child: ListView.builder(
                        itemCount: invitedUsers?.length ?? 0,
                        itemBuilder: (_, index) => Column(
                          children: [
                            BlocBuilder<AppBloc, AppState>(
                              buildWhen: (previous, current) =>
                                  previous.currentUser != current.currentUser,
                              builder: (_, state) {
                                final currentUser = state.currentUser;

                                if (currentUser == null) {
                                  return SizedBox.shrink();
                                }
                                final invitedUser = invitedUsers![index];
                                final user = friendList?.firstWhereOrNull(
                                  (user) => user.id == invitedUser.id,
                                );

                                final displayName =
                                    user?.getDisplayName(currentUser) ??
                                    invitedUser.name;
                                final userImage =
                                    user?.userImg ??
                                    invitedUser.userImage ??
                                    '';

                                return DetailsRow(
                                  prefixChild: Row(
                                    children: [
                                      Container(
                                        height: context.sp(23),
                                        width: context.sp(23),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: context.colors.lightGrey,
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadiusGeometry.circular(
                                                context.sp(100),
                                              ),
                                          child: CommonNetworkImage(
                                            imageUrl: userImage,
                                            errorWidget: Center(
                                              child: Text(
                                                (displayName?.isNotEmpty ??
                                                        false)
                                                    ? (displayName ?? '')[0]
                                                          .toUpperCase()
                                                    : '',
                                                style: context.styles.subtitle,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: context.sp(14)),
                                      Text(
                                        displayName ?? '',
                                        style: context.styles.smallText
                                            .copyWith(
                                              color:
                                                  invitedUsers[index]
                                                          .assistanceStatus ==
                                                      enumToStringAssistance(
                                                        AssistanceStatus
                                                            .pending,
                                                      )
                                                  ? context.colors.text
                                                  : context.colors.orange,
                                            ),
                                      ),
                                    ],
                                  ),
                                  sufixChild: SizedBox(),
                                );
                              },
                            ),
                            SizedBox(height: context.sp(12)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
