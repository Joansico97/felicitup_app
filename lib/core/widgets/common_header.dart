import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/features/home/bloc/home_bloc.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CommonHeader extends StatelessWidget {
  const CommonHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.fullWidth,
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(20),
      ),
      margin: EdgeInsets.only(
        bottom: context.sp(20),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Container(
                  height: context.sp(48),
                  width: context.sp(48),
                  margin: EdgeInsets.only(
                    left: context.sp(13),
                    top: context.sp(15),
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.colors.ligthOrange,
                      width: context.sp(1),
                    ),
                  ),
                  child: BlocBuilder<AppBloc, AppState>(
                    builder: (_, state) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(context.sp(24)),
                        child: Image.network(
                          state.currentUser?.userImg ?? '',
                          width: context.sp(48),
                          height: context.sp(48),
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return CircularProgressIndicator();
                          },
                          errorBuilder: (_, error, stackTrace) => Text(
                            state.currentUser?.firstName?.substring(0, 1).toUpperCase() ?? '',
                            style: context.styles.header2.copyWith(
                              color: context.colors.orange,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const Spacer(),
              Container(
                margin: EdgeInsets.only(
                  top: context.sp(15),
                  right: context.sp(13),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.push(RouterPaths.notifications),
                      icon: Icon(
                        Icons.notifications,
                        color: context.colors.darkGrey,
                        size: context.sp(28),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.search,
                        color: context.colors.darkGrey,
                        size: context.sp(28),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Center(
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (_, state) {
                return InkWell(
                  onTap: () {
                    if (state.create) {
                      context.go(RouterPaths.createFelicitup);
                    } else {
                      context.go(RouterPaths.felicitupsDashboard);
                    }
                  },
                  child: Column(
                    children: [
                      SizedBox(height: context.sp(23)),
                      Image.asset(
                        Assets.images.logoLetter.path,
                        width: context.sp(116),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
