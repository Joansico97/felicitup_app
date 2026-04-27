import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void commoBottomModal({
  required BuildContext context,
  required Widget body,
  bool hasSearch = true,
  bool hasBottomButton = false,
  bool changeClose = false,
  bool moreSpace = false,
  bool noSpace = false,
  void Function()? onTap,
}) {
  showModalBottomSheet(
    context: context,
    barrierColor: context.colors.black.valueOpacity(.2),
    constraints: BoxConstraints(
      maxHeight: noSpace
          ? kIsWeb
                ? 200
                : context.sp(200)
          : moreSpace
          ? kIsWeb
                ? 750
                : context.sp(750)
          : kIsWeb
          ? 500
          : context.sp(500),
      minHeight: kIsWeb ? 10 : context.sp(10),
    ),
    enableDrag: false,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.colors.backgroundModal,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(kIsWeb ? 25 : context.sp(25)),
        topRight: Radius.circular(kIsWeb ? 25 : context.sp(25)),
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
            left: kIsWeb ? 20 : context.sp(20),
            right: kIsWeb ? 20 : context.sp(20),
          ),
          child: Column(
            children: [
              SizedBox(height: kIsWeb ? 10 : context.sp(10)),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () {
                    context.pop();
                  },
                  icon: Container(
                    padding: EdgeInsets.all(kIsWeb ? 1 : context.sp(1)),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.orange,
                    ),
                    child: Icon(
                      changeClose ? Icons.navigate_next_rounded : Icons.close,
                      color: context.colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(child: SingleChildScrollView(child: body)),
              Visibility(
                visible: hasBottomButton,
                child: Column(
                  children: [
                    SizedBox(height: kIsWeb ? 12 : context.sp(12)),
                    SizedBox(
                      height: kIsWeb ? 50 : context.sp(50),
                      width: kIsWeb ? 350 : context.sp(350),
                      child: PrimaryButton(
                        onTap: onTap ?? () {},
                        label: 'Aceptar',
                        isActive: true,
                      ),
                    ),
                    SizedBox(height: kIsWeb ? 24 : context.sp(24)),
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
