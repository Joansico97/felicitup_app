import 'dart:async';

import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/wish_list/bloc/wish_list_bloc.dart';
import 'package:felicitup_app/features/wish_list/views/mobile/wish_list_mobile_page.dart';
import 'package:felicitup_app/features/wish_list/views/web/wish_list_web_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WishListPage extends StatelessWidget {
  const WishListPage({super.key});

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
            return const WishListWebPage();
          }

          return const WishListMobilePage();
        },
      ),
    );
  }
}

class CreateWishListItem extends StatefulWidget {
  const CreateWishListItem({super.key});

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
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    linkController.dispose();
    _focusNode.dispose();
    _focusNode1.dispose();
    _focusNode2.dispose();
    _focusNode3.dispose();
    super.dispose();
  }

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
            onchangeEditing: (value) => context.read<WishListBloc>().add(
                  WishListEvent.setProductName(value),
                ),
          ),
          SizedBox(height: context.sp(16)),
          InputCommon(
            focusNode: _focusNode1,
            controller: priceController,
            hintText: 'Ingresa el precio del producto',
            titleText: 'Precio del producto',
            isPrice: true,
            onchangeEditing: (value) => context.read<WishListBloc>().add(
                  WishListEvent.setProductPrice(value),
                ),
          ),
          SizedBox(height: context.sp(16)),
          InputCommon(
            focusNode: _focusNode2,
            controller: descriptionController,
            hintText: 'Ingresa la descripción del producto',
            titleText: 'Descripción del producto',
            onchangeEditing: (value) => context.read<WishListBloc>().add(
                  WishListEvent.setProductDescription(value),
                ),
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
                      const Spacer(),
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
          Visibility(
            visible: showLink,
            child: Column(
              children: [
                SizedBox(height: context.sp(16)),
                InputCommon(
                  focusNode: _focusNode3,
                  controller: linkController,
                  hintText: 'Ingresa el link del producto',
                  titleText: 'Link del producto',
                ),
                SizedBox(
                  width: context.sp(100),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (linkController.text.isNotEmpty) {
                            context.read<WishListBloc>().add(
                                  WishListEvent.setLinks(links),
                                );
                            setState(() {
                              links.add(linkController.text);
                              linkController.clear();
                              showLink = false;
                            });
                          }
                        },
                        icon: const Icon(Icons.check_box_outlined),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            showLink = false;
                          });
                        },
                        icon: const Icon(Icons.cancel_outlined),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.sp(16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
