import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/features/details_felicitup/details_felicitup_dashboard/bloc/details_felicitup_dashboard_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DetailsHeader extends StatelessWidget {
  const DetailsHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
              ),
              onPressed: () async {
                if (context.mounted) {
                  context
                      .read<DetailsFelicitupDashboardBloc>()
                      .add(DetailsFelicitupDashboardEvent.asignCurrentChat(''));
                  context.go(RouterPaths.felicitupsDashboard);
                }
              },
            ),
          ),
          Container(
            width: context.sp(300),
            padding: EdgeInsets.symmetric(
              horizontal: context.sp(12),
            ),
            child: Row(
              children: [
                BlocBuilder<DetailsFelicitupDashboardBloc, DetailsFelicitupDashboardState>(
                  buildWhen: (previous, current) => previous.felicitup != current.felicitup,
                  builder: (_, state) {
                    final felicitup = state.felicitup;
                    return Container(
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
                      child: felicitup == null
                          ? SizedBox()
                          : felicitup.owner[0].userImg != null && (felicitup.owner[0].userImg?.isNotEmpty ?? false)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(context.sp(50)),
                                  child: Image.network(
                                    felicitup.owner[0].userImg ?? '',
                                    fit: BoxFit.cover,
                                    loadingBuilder: (_, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      }
                                      return CircularProgressIndicator();
                                    },
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    felicitup.owner[0].name.split(' ')[0].substring(0, 1).toUpperCase(),
                                    style: context.styles.header2.copyWith(
                                      color: context.colors.orange,
                                    ),
                                  ),
                                ),
                    );
                  },
                ),
                SizedBox(width: context.sp(12)),
                BlocBuilder<DetailsFelicitupDashboardBloc, DetailsFelicitupDashboardState>(
                  buildWhen: (previous, current) => previous.felicitup != current.felicitup,
                  builder: (_, state) {
                    final felicitup = state.felicitup;
                    return felicitup == null
                        ? SizedBox()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: context.sp(190),
                                child: Text(
                                  felicitup.owner.length > 2
                                      ? '${felicitup.reason} de ${felicitup.owner.first.name.split(' ')[0]} y ${felicitup.owner.length - 1} más'
                                      : felicitup.owner.length == 2
                                          ? '${felicitup.reason} de ${felicitup.owner.first.name.split(' ')[0]} y ${felicitup.owner.last.name.split(' ')[0]}'
                                          : '${felicitup.reason} de ${felicitup.owner.first.name.split(' ')[0]}',
                                  textAlign: TextAlign.left,
                                  maxLines: 2,
                                  style: context.styles.subtitle.copyWith(
                                    color: context.colors.orange,
                                    // fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                'Fecha: ${DateFormat('dd·MM·yyyy').format(felicitup.date)}',
                                style: context.styles.smallText.copyWith(
                                  color: context.colors.text,
                                ),
                              ),
                            ],
                          );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
