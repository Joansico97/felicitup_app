import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/buttons/primary_button.dart';
import 'package:felicitup_app/core/widgets/common/input_common.dart';
import 'package:felicitup_app/data/models/user_models/giftcard_models/giftcard_model.dart';
import 'package:felicitup_app/features/wish_list/bloc/wish_list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
                          icon: Icon(
                            Icons.check_box_outlined,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              showLink = false;
                            });
                          },
                          icon: Icon(
                            Icons.cancel_outlined,
                          ),
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
      ),
    );
  }
}
