import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RememberCard extends StatelessWidget {
  const RememberCard({
    super.key,
    required this.name,
    required this.date,
    required this.onTap,
    this.image,
  });

  final String name;
  final String? image;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: context.sp(50),
        width: context.sp(264),
        padding: EdgeInsets.symmetric(
          horizontal: context.sp(20),
        ),
        margin: EdgeInsets.only(
          bottom: context.sp(8),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            context.sp(28),
          ),
          color: context.colors.softOrange,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: context.sp(37),
                  width: context.sp(37),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.grey,
                  ),
                  child: image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(
                            context.sp(20),
                          ),
                          child: Image.network(
                            image!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          color: context.colors.white,
                          size: context.sp(20),
                        ),
                ),
                SizedBox(width: context.sp(10)),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: context.styles.smallText.copyWith(
                        color: context.colors.grey,
                        fontSize: context.sp(14),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Hoy, ${DateFormat('d MMMM').format(date)} · 28 años',
                      style: context.styles.smallText.copyWith(
                        color: context.colors.grey,
                        fontSize: context.sp(10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              height: context.sp(18),
              width: context.sp(18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.colors.grey,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.chat_bubble,
                color: context.colors.grey,
                size: context.sp(7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
