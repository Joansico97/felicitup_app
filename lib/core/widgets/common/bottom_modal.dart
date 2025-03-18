import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void commoBottomModal({
  required BuildContext context,
  required VoidCallback onTap,
  bool hasSearch = true,
  required Widget body,
}) {
  showModalBottomSheet(
    context: context,
    barrierColor: context.colors.black.valueOpacity(.2),
    constraints: BoxConstraints(
      maxHeight: context.sp(500),
      minHeight: context.sp(10),
    ),
    enableDrag: false,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.colors.backgroundModal,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(context.sp(25)),
        topRight: Radius.circular(context.sp(25)),
      ),
    ),
    builder: (_) {
      return Material(
        color: Colors.transparent,
        shadowColor: context.colors.black.valueOpacity(0.5),
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).viewInsets.top,
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: context.sp(20),
            right: context.sp(20),
          ),
          child: Column(
            children: [
              SizedBox(height: context.sp(10)),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () {
                    onTap();
                    context.pop();
                  },
                  icon: Container(
                    padding: EdgeInsets.all(context.sp(1)),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.orange,
                    ),
                    child: Icon(
                      Icons.close,
                      color: context.colors.white,
                    ),
                  ),
                ),
              ),
              hasSearch
                  ? TextFormField(
                      style: context.styles.paragraph,
                      decoration: InputDecoration(
                        fillColor: context.colors.white,
                        filled: true,
                        hintText: 'Buscar',
                        hintStyle: context.styles.paragraph.copyWith(
                          color: context.colors.darkGrey,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: context.colors.darkGrey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            context.sp(10),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            context.sp(10),
                          ),
                        ),
                      ),
                      onEditingComplete: () {
                        FocusScope.of(context).unfocus();
                      },
                      onChanged: (value) {
                        // if (value.isEmpty) {
                        //   firendsLocal = [...state.filledFriendList];
                        // }
                        // final listProv = firendsLocal.where((element) {
                        //   return element.fullName!.toLowerCase().contains(value.toLowerCase());
                        // }).toList();

                        // firendsLocal = listProv;
                      },
                    )
                  : SizedBox(),
              SizedBox(height: context.sp(12)),
              Expanded(
                child: SingleChildScrollView(
                  child: body,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
