import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatSpace extends StatelessWidget {
  const ChatSpace({
    super.key,
    required this.isMine,
    required this.date,
    required this.textContent,
    required this.id,
    required this.name,
    this.userImg,
  });

  final bool isMine;
  final String id;
  final DateTime date;
  final String textContent;
  final String name;
  final String? userImg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.sp(10)),
      child: isMine
          ? SizedBox(
              width: context.sp(400),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                          top: context.sp(24),
                          left: context.sp(24),
                          right: context.sp(24),
                        ),
                        width: context.sp(260),
                        decoration: BoxDecoration(
                          color: context.colors.lightBlue,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(context.sp(24)),
                            topRight: Radius.circular(context.sp(24)),
                            bottomLeft: Radius.circular(context.sp(24)),
                          ),
                          border: Border.all(
                            color: context.colors.ligthOrange,
                            width: context.sp(2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                textContent,
                                style: context.styles.paragraph,
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: date.day == DateTime.now().day
                                  ? Text(
                                      DateFormat.Hm().format(date),
                                      style: context.styles.smallText.copyWith(
                                        color: context.colors.text,
                                      ),
                                    )
                                  : Text(
                                      '${DateFormat.Md().format(date)} - ${DateFormat('hh:mm').format(date)}',
                                      style: context.styles.smallText.copyWith(
                                        color: context.colors.text,
                                      ),
                                    ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: context.sp(12)),
                  Container(
                    height: context.sp(40),
                    width: context.sp(40),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.lightGrey,
                      border: Border.all(
                        color: context.colors.ligthOrange,
                        width: context.sp(2),
                      ),
                    ),
                    child: userImg != null
                        ? SizedBox(
                            height: context.sp(40),
                            width: context.sp(40),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(context.sp(40)),
                              child: Image.network(
                                userImg!,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) => loadingProgress == null
                                    ? child
                                    : Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                errorBuilder: (context, error, stackTrace) => Text(
                                  name[0].toUpperCase(),
                                  style: context.styles.paragraph,
                                ),
                              ),
                            ),
                          )
                        : Text(
                            name[0].toUpperCase(),
                            style: context.styles.paragraph,
                          ),
                  )
                ],
              ),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: context.sp(40),
                  width: context.sp(40),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.lightGrey,
                  ),
                  child: userImg != null
                      ? SizedBox(
                          height: context.sp(40),
                          width: context.sp(40),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(context.sp(40)),
                            child: Image.network(
                              userImg!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) => loadingProgress == null
                                  ? child
                                  : Center(
                                      child: CircularProgressIndicator(),
                                    ),
                              errorBuilder: (context, error, stackTrace) => Text(
                                name[0].toUpperCase(),
                                style: context.styles.paragraph,
                              ),
                            ),
                          ),
                        )
                      : Text(
                          name[0].toUpperCase(),
                          style: context.styles.paragraph,
                        ),
                ),
                SizedBox(width: context.sp(18)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        top: context.sp(24),
                        left: context.sp(24),
                        right: context.sp(24),
                      ),
                      width: context.sp(260),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(context.sp(24)),
                          topRight: Radius.circular(context.sp(24)),
                          bottomRight: Radius.circular(context.sp(24)),
                        ),
                        border: Border.all(
                          color: context.colors.ligthOrange,
                          width: context.sp(2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: context.styles.paragraph.copyWith(
                              fontWeight: FontWeight.w600,
                              color: generateColorForUser(id),
                              // color: theme.colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: context.sp(8)),
                          Text(
                            textContent,
                            style: context.styles.paragraph,
                          ),
                          SizedBox(height: context.sp(8)),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: date.day == DateTime.now().day
                                ? Text(
                                    DateFormat.Hm().format(date),
                                    style: context.styles.smallText.copyWith(
                                      color: context.colors.text,
                                    ),
                                  )
                                : Text(
                                    '${DateFormat.Md().format(date)} - ${DateFormat('hh:mm').format(date)}',
                                    style: context.styles.smallText.copyWith(
                                      color: context.colors.text,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
    );
  }
}
