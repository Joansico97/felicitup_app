import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void commoBottomModal({
  required BuildContext context,
  required Widget body,
  bool hasSearch = true,
  bool hasBottomButton = false,
  void Function()? onTap,
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
                    context.pop();
                  },
                  icon: Container(
                    padding: EdgeInsets.all(context.sp(1)),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.orange,
                    ),
                    child: Icon(Icons.close, color: context.colors.white),
                  ),
                ),
              ),
              Expanded(child: SingleChildScrollView(child: body)),
              Visibility(
                visible: hasBottomButton,
                child: Column(
                  children: [
                    SizedBox(height: context.sp(12)),
                    SizedBox(
                      height: context.sp(50),
                      width: context.sp(350),
                      child: PrimaryButton(
                        onTap: onTap ?? () {},
                        label: 'Aceptar',
                        isActive: true,
                      ),
                    ),
                    SizedBox(height: context.sp(24)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
