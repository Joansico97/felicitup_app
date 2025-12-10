import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/constants/app_constants.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/common/common.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/create_felicitup/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ContactCardRow extends StatelessWidget {
  const ContactCardRow({
    super.key,
    required this.contact,
    required this.isSelected,
  });

  final UserModel contact;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AppBloc>().state.currentUser;
    final String name = contact.getDisplayName(currentUser);
    final String userImg = contact.userImg ?? '';

    return StatefulBuilder(
      builder: (_, setState) {
        return Container(
          padding: EdgeInsets.all(context.sp(15)),
          margin: EdgeInsets.only(bottom: context.sp(10)),
          width: context.fullWidth,
          decoration: BoxDecoration(
            color: context.colors.white,
            borderRadius: BorderRadius.circular(context.sp(10)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                height: context.sp(55),
                width: context.sp(55),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.colors.lightGrey,
                  shape: BoxShape.circle,
                ),
                child: userImg.isNotEmpty
                    ? SizedBox(
                        height: context.sp(55),
                        width: context.sp(55),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(context.sp(55)),
                          child: CommonNetworkImage(imageUrl: userImg),
                        ),
                      )
                    : Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '',
                        style: context.styles.header2,
                      ),
              ),
              SizedBox(width: context.sp(24)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: context.sp(200),
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: context.styles.header2,
                    ),
                  ),
                  contact.birthDate != null
                      ? Column(
                          children: [
                            SizedBox(height: context.sp(5)),
                            Text(
                              DateFormat(
                                AppConstants.birthDateFormatWithoutYear,
                                'es_ES',
                              ).format(contact.birthDate!).capitalize(),
                              style: context.styles.smallText,
                            ),
                          ],
                        )
                      : SizedBox.shrink(),
                ],
              ),
              const Spacer(),
              CirclePicker(isActive: isSelected),
            ],
          ),
        );
      },
    );
  }
}
