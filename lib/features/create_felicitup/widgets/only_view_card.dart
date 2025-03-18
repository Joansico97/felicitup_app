import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/features/create_felicitup/bloc/create_felicitup_bloc.dart';
import 'package:felicitup_app/features/create_felicitup/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnlyViewCardRow extends StatelessWidget {
  const OnlyViewCardRow({
    super.key,
    required this.contactName,
    required this.date,
    required this.userImg,
    required this.stepOne,
    required this.stepTwo,
    required this.isSelected,
  });

  final String contactName;
  final String userImg;
  final DateTime date;
  final bool stepOne;
  final bool stepTwo;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.sp(10)),
      margin: EdgeInsets.only(
        bottom: context.sp(10),
      ),
      width: context.fullWidth,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(context.sp(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            height: context.sp(50),
            width: context.sp(50),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: userImg.isNotEmpty
                ? SizedBox(
                    height: context.sp(50),
                    width: context.sp(50),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(context.sp(55)),
                      child: Image.network(
                        userImg,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : Text(
                    contactName[0].toUpperCase(),
                    style: context.styles.menu,
                  ),
          ),
          SizedBox(width: context.sp(12)),
          BlocBuilder<CreateFelicitupBloc, CreateFelicitupState>(
            builder: (_, state) {
              final reason = state.eventReason;

              return SizedBox(
                width: context.sp(180),
                child: Text(
                  reason != '' && stepTwo
                      ? '$reason $contactName'
                      : stepOne
                          ? 'Felicitas a $contactName'
                          : contactName,
                  style: context.styles.menu,
                ),
              );
            },
          ),
          const Spacer(),
          CirclePicker(
            isActive: isSelected,
          ),
        ],
      ),
    );
  }
}
