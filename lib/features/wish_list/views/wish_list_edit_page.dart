import 'dart:async';

import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/wish_list/bloc/wish_list_bloc.dart';
import 'package:felicitup_app/features/wish_list/views/mobile/wish_list_edit_mobile_page.dart';
import 'package:felicitup_app/features/wish_list/views/web/wish_list_edit_web_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WishListEditPage extends StatelessWidget {
  const WishListEditPage({super.key, required this.wishListItem});

  final GiftcarModel wishListItem;

  @override
  Widget build(BuildContext context) {
    return BlocListener<WishListBloc, WishListState>(
      listenWhen: (previous, current) =>
          previous.isLoading != current.isLoading,
      listener: (_, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 1024) {
            return WishListEditWebPage(wishListItem: wishListItem);
          }

          return WishListEditMobilePage(wishListItem: wishListItem);
        },
      ),
    );
  }
}
