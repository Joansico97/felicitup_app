import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FelicitupCard extends StatelessWidget {
  const FelicitupCard({
    super.key,
    required this.felicitup,
  });

  final FelicitupModel felicitup;

  @override
  Widget build(BuildContext context) {
    final nameOwner = felicitup.owner.map((e) => e.name).toList();

    return SizedBox(
      child: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            height: context.sp(120),
            width: context.fullWidth,
            // width: context.sp(310),
            padding: EdgeInsets.only(
              top: context.sp(15),
              bottom: context.sp(15),
              left: context.sp(19),
            ),
            margin: EdgeInsets.only(
              bottom: context.sp(12),
              left: context.sp(40),
              right: context.sp(40),
            ),
            decoration: BoxDecoration(
              color: context.colors.ligthOrange.valueOpacity(.6),
              borderRadius: BorderRadius.circular(context.sp(10)),
              border: Border.all(
                color: context.colors.ligthOrange,
                width: context.sp(2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: context.sp(60),
                  width: context.sp(60),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.lightGrey,
                    border: Border.all(
                      color: context.colors.ligthOrange,
                      width: context.sp(2),
                    ),
                  ),
                  child: felicitup.owner.length == 1 && (felicitup.owner[0].userImg?.isNotEmpty ?? false)
                      ? SizedBox(
                          height: context.sp(65),
                          width: context.sp(65),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.network(
                              felicitup.owner[0].userImg ?? '',
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Text(
                          nameOwner.length >= 2
                              ? '${nameOwner[0][0].toUpperCase()} ${nameOwner[1][0].toUpperCase()}'
                              : nameOwner[0][0].toUpperCase(),
                          style: context.styles.header2.copyWith(
                            color: context.colors.primary,
                          ),
                        ),
                ),
                SizedBox(width: context.sp(10)),
                Container(
                  width: context.sp(140),
                  padding: EdgeInsets.all(context.sp(5)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: context.sp(300),
                        child: Text(
                          nameOwner.length > 1
                              ? '${felicitup.reason} de ${nameOwner.length} usuarios'
                              : '${felicitup.reason} ${nameOwner[0]}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.styles.smallText.copyWith(
                            color: context.colors.primary,
                            // fontSize: (12),
                          ),
                        ),
                      ),
                      SizedBox(
                        // width: context.sp(25),
                        child: Stack(
                          children: [
                            CircleIcon(
                              color: context.colors.ligthOrange,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: context.sp(10),
                                ),
                                CircleIcon(
                                  color: context.colors.ligthOrange,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: context.sp(20),
                                ),
                                CircleIcon(
                                  color: context.colors.ligthOrange,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: context.sp(30),
                                ),
                                CircleIcon(
                                  color: context.colors.ligthOrange,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        DateFormat('dd·MM·yyyy').format(felicitup.date),
                        style: context.styles.smallText.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: context.fullWidth,
            child: Column(
              children: [
                SizedBox(height: context.sp(15)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Container(
                      // height: context.sp(70),
                      width: context.sp(60),
                      padding: EdgeInsets.symmetric(
                        vertical: context.sp(15),
                      ),
                      // height: size.width(.2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(context.sp(10)),
                        color: context.colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          felicitup.hasVideo
                              ? Column(
                                  children: [
                                    IconInfo(
                                      icon: Icons.play_arrow,
                                    ),
                                    SizedBox(height: context.sp(5)),
                                  ],
                                )
                              : const SizedBox(),
                          felicitup.hasBote
                              ? Column(
                                  children: [
                                    IconInfo(
                                      icon: Icons.euro,
                                    ),
                                    SizedBox(height: context.sp(5)),
                                  ],
                                )
                              : const SizedBox(),
                          IconInfo(
                            icon: Icons.people_outline,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: context.sp(15)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class CircleIcon extends StatelessWidget {
  const CircleIcon({
    super.key,
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.sp(25),
      width: context.sp(25),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.lightGrey,
        border: Border.all(
          color: context.colors.ligthOrange,
          width: 2,
        ),
      ),
      child: Icon(
        Icons.people_outline,
        color: context.colors.primary,
        size: context.sp(15),
      ),
    );
  }
}

class IconInfo extends StatelessWidget {
  const IconInfo({
    super.key,
    required this.icon,
  });

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.sp(17),
      width: context.sp(17),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: context.colors.primary,
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        color: context.colors.primary,
        size: context.sp(10),
      ),
    );
  }
}
