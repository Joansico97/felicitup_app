import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/wish_list/bloc/wish_list_bloc.dart';
import 'package:felicitup_app/features/wish_list/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class WishListEditMobilePage extends StatelessWidget {
  const WishListEditMobilePage({super.key, required this.wishListItem});

  final GiftcarModel wishListItem;

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
                  title: state.isCreate ? 'Lista de deseos' : 'Tu deseo',
                  onPressed: () {
                    if (state.isCreate) {
                      context.read<WishListBloc>().add(
                            const WishListEvent.createGiftItem(),
                          );
                    } else {
                      context.pop();
                    }
                  },
                );
              },
            ),
            SizedBox(height: context.sp(12)),
            BlocBuilder<WishListBloc, WishListState>(
              builder: (_, state) {
                return Expanded(
                  child: state.isCreate
                      ? EditWishListItemView(wishListItem: wishListItem)
                      : InfoWishListItemView(wishListItem: wishListItem),
                );
              },
            ),
            SizedBox(height: context.sp(12)),
            BlocBuilder<WishListBloc, WishListState>(
              builder: (_, state) {
                return SizedBox(
                  width: context.sp(300),
                  child: state.isCreate
                      ? PrimaryButton(
                          onTap: () {
                            if (state.isCreate) {
                              context.read<WishListBloc>().add(
                                    WishListEvent.editGiftItemInfo(wishListItem),
                                  );
                              context.go(RouterPaths.wishList);
                            } else {
                              context.read<WishListBloc>().add(
                                    const WishListEvent.createGiftItem(),
                                  );
                            }
                          },
                          label: state.isCreate ? 'Guardar' : 'Editar regalo',
                          isActive: true,
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: PrimaryButton(
                                onTap: () => context.read<WishListBloc>().add(
                                      const WishListEvent.createGiftItem(),
                                    ),
                                label: 'Editar',
                                isActive: true,
                              ),
                            ),
                            SizedBox(width: context.sp(8)),
                            Expanded(
                              child: PrimaryButton(
                                onTap: () => showConfirmModal(
                                  title: 'Deseas eliminar tu deseo?',
                                  onAccept: () async {
                                    context.read<WishListBloc>().add(
                                          WishListEvent.deleteGiftItemInfo(
                                            wishListItem.id ?? '',
                                          ),
                                        );
                                    context.read<WishListBloc>().add(
                                          const WishListEvent.createGiftItem(),
                                        );
                                    context.read<AppBloc>().add(
                                          const AppEvent.loadUserData(),
                                        );
                                    context.pop();
                                  },
                                ),
                                label: 'Eliminiar',
                                isActive: true,
                              ),
                            ),
                          ],
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
