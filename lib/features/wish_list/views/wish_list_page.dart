import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/wish_list/bloc/wish_list_bloc.dart';
import 'package:felicitup_app/features/wish_list/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class WishListPage extends StatelessWidget {
  const WishListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AppBloc>().state.currentUser;

    return BlocListener<WishListBloc, WishListState>(
      listenWhen: (previous, current) => previous.isLoading != current.isLoading,
      listener: (_, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              BlocBuilder<WishListBloc, WishListState>(
                builder: (_, state) {
                  return CollapsedHeader(
                    title: 'Lista de deseos',
                    onPressed: () {
                      if (state.isCreate) {
                        context.go(RouterPaths.wishList);
                      } else {
                        context.read<WishListBloc>().add(
                              WishListEvent.editGiftItem(),
                            );
                      }
                    },
                  );
                },
              ),
              SizedBox(height: context.sp(12)),
              BlocBuilder<WishListBloc, WishListState>(
                builder: (_, state) {
                  return Expanded(
                    child: state.isEdit
                        ? FadeInUp(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.symmetric(
                                horizontal: context.sp(20),
                              ),
                              child: CreateWishListItem(),
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
                                    currentUser?.giftcardList?.length ?? 0,
                                    (index) => WishListItem(
                                      giftcard: currentUser!.giftcardList![index],
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
                      onTap: () => context.read<WishListBloc>().add(
                            WishListEvent.editGiftItem(),
                          ),
                      label: state.isEdit ? 'Guardar' : 'Añadir regalo',
                      isActive: true,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateWishListItem extends StatefulWidget {
  const CreateWishListItem({
    super.key,
  });

  @override
  State<CreateWishListItem> createState() => _CreateWishListItemState();
}

class _CreateWishListItemState extends State<CreateWishListItem> {
  bool disabled = true;
  bool showLink = false;
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkController = TextEditingController();
  List<String> links = [];
  final _focusNode = FocusNode();
  final _focusNode1 = FocusNode();
  final _focusNode2 = FocusNode();
  final _focusNode3 = FocusNode();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
        _focusNode1.unfocus();
        _focusNode2.unfocus();
        _focusNode3.unfocus();
      },
      child: Column(
        children: [
          SizedBox(height: context.sp(32)),
          InputCommon(
            focusNode: _focusNode,
            controller: nameController,
            hintText: 'Ingresa el nombre del producto',
            titleText: 'Nombre del producto',
          ),
          SizedBox(height: context.sp(16)),
          InputCommon(
            focusNode: _focusNode1,
            controller: priceController,
            hintText: 'Ingresa el precio del producto',
            titleText: 'Precio del producto',
            isPrice: true,
          ),
          SizedBox(height: context.sp(16)),
          InputCommon(
            focusNode: _focusNode2,
            controller: descriptionController,
            hintText: 'Ingresa la descripción del producto',
            titleText: 'Descripción del producto',
          ),
          SizedBox(height: context.sp(16)),
          Text(
            'Links',
            style: context.styles.subtitle.copyWith(
              fontSize: context.sp(10),
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          SizedBox(height: context.sp(links.isEmpty ? 8 : 16)),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...List.generate(
                  links.length,
                  (index) => Row(
                    children: [
                      SizedBox(
                        width: context.sp(200),
                        child: Text(
                          links[index],
                          overflow: TextOverflow.ellipsis,
                          style: context.styles.paragraph,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            links.removeAt(index);
                          });
                        },
                        icon: Icon(
                          Icons.delete_forever_outlined,
                          color: context.colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.sp(links.isEmpty ? 8 : 16)),
          Align(
            alignment: Alignment.center,
            child: PrimaryButton(
              label: 'Añadir link',
              onTap: () {
                setState(() {
                  showLink = true;
                  _focusNode2.unfocus();
                  _focusNode3.requestFocus();
                });
              },
              isActive: true,
              isCollapsed: true,
            ),
          ),
        ],
      ),
    );
  }
}
