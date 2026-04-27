import 'package:collection/collection.dart';
import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/constants/constants.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/details_felicitup/details_felicitup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DetailsHeader extends StatelessWidget {
  const DetailsHeader({super.key});

  String _getOwnerFirstName(
    BuildContext context,
    OwnerModel owner,
    List<UserModel> friendList,
  ) {
    final currentUser = context.read<AppBloc>().state.currentUser;
    final user = friendList.firstWhereOrNull((u) => u.id == owner.id);
    if (user != null) {
      return user.getDisplayName(currentUser).split(' ')[0];
    }
    return owner.name.split(' ')[0];
  }

  String _generateTitle(
    BuildContext context,
    FelicitupModel felicitup,
    List<UserModel> friendList,
  ) {
    final reason = felicitup.reason.capitalize();
    final owners = felicitup.owner;

    if (owners.length > 2) {
      return '$reason de ${_getOwnerFirstName(context, owners.first, friendList)} y ${owners.length - 1} más';
    } else if (owners.length == 2) {
      return '$reason de ${_getOwnerFirstName(context, owners.first, friendList)} y ${_getOwnerFirstName(context, owners.last, friendList)}';
    } else {
      return '$reason de ${_getOwnerFirstName(context, owners.first, friendList)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final friendList = context.watch<InfoFelicitupBloc>().state.friendList;
    return Container(
      width: context.fullWidth,
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(12),
        vertical: context.sp(32),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: context.fullWidth,
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: context.colors.text),
              onPressed: () {
                context.read<DetailsFelicitupDashboardBloc>().add(
                  const DetailsFelicitupDashboardEvent.asignCurrentChat(''),
                );
                context.go(RouterPaths.felicitupsDashboard);
              },
            ),
          ),
          BlocBuilder<
            DetailsFelicitupDashboardBloc,
            DetailsFelicitupDashboardState
          >(
            buildWhen: (previous, current) =>
                previous.felicitup != current.felicitup,
            builder: (_, state) {
              final felicitup = state.felicitup;
              if (felicitup == null) {
                return const SizedBox.shrink();
              }
              final owner = felicitup.owner.first;
              final ownerFirstName = _getOwnerFirstName(
                context,
                owner,
                friendList,
              );

              return Container(
                width: context.sp(300),
                padding: EdgeInsets.symmetric(horizontal: context.sp(12)),
                child: Row(
                  children: [
                    Container(
                      height: context.sp(60),
                      width: context.sp(60),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.colors.lightGrey,
                        border: Border.all(
                          color: context.colors.white,
                          width: 2,
                        ),
                      ),
                      child: (owner.userImg?.isNotEmpty ?? false)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(
                                context.sp(50),
                              ),
                              child: CommonNetworkImage(
                                imageUrl: owner.userImg!,
                              ),
                            )
                          : Center(
                              child: Text(
                                ownerFirstName.substring(0, 1).toUpperCase(),
                                style: context.styles.header2.copyWith(
                                  color: context.colors.orange,
                                ),
                              ),
                            ),
                    ),
                    SizedBox(width: context.sp(12)),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _generateTitle(context, felicitup, friendList),
                            textAlign: TextAlign.left,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.styles.subtitle.copyWith(
                              color: context.colors.orange,
                            ),
                          ),
                          Text(
                            'Fecha: ${DateFormat(AppConstants.birthDateFormat, 'es_ES').format(felicitup.date).capitalize()}',
                            style: context.styles.smallText.copyWith(
                              color: context.colors.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
