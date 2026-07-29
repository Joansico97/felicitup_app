import 'package:animate_do/animate_do.dart';
import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/wish_list/bloc/wish_list_bloc.dart';
import 'package:felicitup_app/features/wish_list/views/wish_list_page.dart';
import 'package:felicitup_app/features/wish_list/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class WishListMobilePage extends StatelessWidget {
  const WishListMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            BlocBuilder<WishListBloc, WishListState>(
              builder: (_, state) {
                return CollapsedHeader(
                  title: 'Lista de deseos',
                  onPressed: () {
                    if (state.isEdit) {
                      context.read<WishListBloc>().add(
                            const WishListEvent.editGiftItem(),
                          );
                    } else {
                      context.go(RouterPaths.felicitupsDashboard);
                    }
                  },
                );
              },
            ),
            SizedBox(height: context.sp(12)),
            BlocBuilder<WishListBloc, WishListState>(
              builder: (_, state) {
                final listGiftcard = state.listGiftcard;
                return Expanded(
                  child: state.isEdit
                      ? FadeInUp(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.sp(20),
                            ),
                            child: const CreateWishListItem(),
                          ),
                        )
                      : FadeInUp(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.sp(20),
                            ),
                            child: Column(
                              children: [
                                ...List.generate(
                                  listGiftcard?.length ?? 0,
                                  (index) => WishListItem(
                                    giftcard: listGiftcard![index],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                );
              },
            ),
            SizedBox(height: context.sp(12)),
            BlocBuilder<WishListBloc, WishListState>(
              builder: (_, state) {
                return SizedBox(
                  width: context.sp(300),
                  child: PrimaryButton(
                    onTap: () {
                      if (state.isEdit) {
                        context.read<WishListBloc>().add(
                              const WishListEvent.createGiftItemInfo(),
                            );
                        context.read<AppBloc>().add(const AppEvent.loadUserData());
                        context.read<WishListBloc>().add(
                              const WishListEvent.editGiftItem(),
                            );
                      } else {
                        context.read<WishListBloc>().add(
                              const WishListEvent.editGiftItem(),
                            );
                      }
                    },
                    label: state.isEdit ? 'Guardar' : 'Añadir regalo',
                    isActive: true,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
