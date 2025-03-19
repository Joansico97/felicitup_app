import 'dart:async';

import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/wish_list/bloc/wish_list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class WishListEditPage extends StatelessWidget {
  const WishListEditPage({
    super.key,
    required this.wishListItem,
  });

  final GiftcarModel wishListItem;

  @override
  Widget build(BuildContext context) {
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
                    title: state.isCreate ? 'Lista de deseos' : 'Tu deseo',
                    onPressed: () {
                      if (state.isCreate) {
                        context.read<WishListBloc>().add(
                              WishListEvent.createGiftItem(),
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
                        ? EditWishListItemView(
                            wishListItem: wishListItem,
                          )
                        : InfoWishListItemView(
                            wishListItem: wishListItem,
                          ),
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
                            onTap: () => context.read<WishListBloc>().add(
                                  WishListEvent.createGiftItem(),
                                ),
                            label: state.isCreate ? 'Guardar' : 'Editar regalo',
                            isActive: true,
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: PrimaryButton(
                                  onTap: () => context.read<WishListBloc>().add(
                                        WishListEvent.createGiftItem(),
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
                                      context.read<AppBloc>().add(AppEvent.loadUserData());
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
      ),
    );
  }
}

class EditWishListItemView extends StatefulWidget {
  const EditWishListItemView({
    super.key,
    required this.wishListItem,
  });

  final GiftcarModel wishListItem;

  @override
  State<EditWishListItemView> createState() => _EditWishListItemViewState();
}

class _EditWishListItemViewState extends State<EditWishListItemView> {
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
  void initState() {
    super.initState();
    nameController.text = widget.wishListItem.productName ?? '';
    priceController.text = widget.wishListItem.productValue.toString();
    descriptionController.text = widget.wishListItem.productDescription ?? '';
    links = widget.wishListItem.links ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(40),
      ),
      child: GestureDetector(
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
      ),
    );
  }
}

class InfoWishListItemView extends StatelessWidget {
  const InfoWishListItemView({
    super.key,
    required this.wishListItem,
  });

  final GiftcarModel wishListItem;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(40),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: context.sp(24)),
          Text(
            'Deseo:',
            style: context.styles.subtitle.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: context.sp(12)),
          Text(
            wishListItem.productName ?? '',
            style: context.styles.subtitle,
            textAlign: TextAlign.left,
          ),
          SizedBox(height: context.sp(24)),
          Text(
            'Precio:',
            style: context.styles.subtitle.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: context.sp(12)),
          Text(
            '${wishListItem.productValue} €',
            style: context.styles.subtitle,
            textAlign: TextAlign.left,
          ),
          SizedBox(height: context.sp(24)),
          Text(
            'Descripción corta:',
            style: context.styles.subtitle.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: context.sp(12)),
          Text(
            '${wishListItem.productDescription}',
            style: context.styles.paragraph,
          ),
          SizedBox(height: context.sp(24)),
          Text(
            'Links:',
            style: context.styles.subtitle.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: context.sp(12)),
          if (wishListItem.links != null)
            for (final link in wishListItem.links!)
              Row(
                children: [
                  Icon(
                    Icons.link,
                    color: context.colors.orange,
                  ),
                  SizedBox(width: context.sp(8)),
                  GestureDetector(
                    onTap: () async {
                      final Uri url = Uri.parse(link);
                      await launchUrl(
                        url,
                        mode: LaunchMode.inAppBrowserView,
                      );
                    },
                    child: SizedBox(
                      width: context.sp(250),
                      child: Text(
                        link,
                        overflow: TextOverflow.ellipsis,
                        style: context.styles.paragraph,
                      ),
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }
}
