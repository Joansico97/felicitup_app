import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/create_felicitup/widgets/widgets.dart';
import 'package:flutter/material.dart';
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
    final DateTime date = contact.birthDate ?? DateTime.now();
    final String name = contact.fullName ?? '';
    final String userImg = contact.userImg ?? '';

    return StatefulBuilder(
      builder: (_, setState) {
        return Container(
          padding: EdgeInsets.all(context.sp(15)),
          margin: EdgeInsets.only(
            bottom: context.sp(10),
          ),
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
                          child: Image.network(
                            userImg,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Text(
                        name[0].toUpperCase(),
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
                  SizedBox(height: context.sp(5)),
                  Text(
                    DateFormat('dd·MM·yyyy').format(date),
                    style: context.styles.smallText,
                  ),
                ],
              ),
              const Spacer(),
              CirclePicker(
                isActive: isSelected,
              ),
            ],
          ),
        );
      },
    );
  }
}
