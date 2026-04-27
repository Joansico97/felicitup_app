import 'package:felicitup_app/core/constants/constants.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FelicitupCard extends StatelessWidget {
  const FelicitupCard({super.key, required this.felicitup});

  final FelicitupModel felicitup;

  @override
  Widget build(BuildContext context) {
    final nameOwner = felicitup.owner.map((e) => e.name).toList();

    return SizedBox(
      child: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            height: kIsWeb ? 120 : context.sp(120),
            width: context.fullWidth,
            // width: context.sp(310),
            padding: EdgeInsets.only(
              top: kIsWeb ? 15 : context.sp(15),
              bottom: kIsWeb ? 15 : context.sp(15),
              left: kIsWeb ? 20 : context.sp(20),
            ),
            margin: EdgeInsets.only(
              bottom: kIsWeb ? 12 : context.sp(12),
              left: kIsWeb ? 40 : context.sp(40),
              right: kIsWeb ? 40 : context.sp(40),
            ),
            decoration: BoxDecoration(
              color: context.colors.ligthOrange.valueOpacity(.6),
              borderRadius: BorderRadius.circular(kIsWeb ? 10 : context.sp(10)),
              border: Border.all(
                color: context.colors.ligthOrange,
                width: kIsWeb ? 2 : context.sp(2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: kIsWeb ? 60 : context.sp(60),
                  width: kIsWeb ? 60 : context.sp(60),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.lightGrey,
                    border: Border.all(
                      color: context.colors.ligthOrange,
                      width: context.sp(2),
                    ),
                  ),
                  child:
                      felicitup.owner.length == 1 &&
                          (felicitup.owner[0].userImg?.isNotEmpty ?? false)
                      ? SizedBox(
                          height: kIsWeb ? 65 : context.sp(65),
                          width: kIsWeb ? 65 : context.sp(65),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CommonNetworkImage(
                              imageUrl: felicitup.owner[0].userImg!,
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
                SizedBox(width: kIsWeb ? 10 : context.sp(10)),
                Container(
                  width: kIsWeb ? 140 : context.sp(140),
                  padding: EdgeInsets.all(kIsWeb ? 5 : context.sp(5)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: kIsWeb ? 140 : context.sp(140),
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
                            CircleIcon(color: context.colors.ligthOrange),
                            Row(
                              children: [
                                SizedBox(width: kIsWeb ? 10 : context.sp(10)),
                                CircleIcon(color: context.colors.ligthOrange),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(width: kIsWeb ? 20 : context.sp(20)),
                                CircleIcon(color: context.colors.ligthOrange),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(width: kIsWeb ? 30 : context.sp(30)),
                                CircleIcon(color: context.colors.ligthOrange),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        DateFormat(
                          AppConstants.birthDateFormat,
                          'ES_es',
                        ).format(felicitup.date).capitalize(),
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
                SizedBox(height: kIsWeb ? 15 : context.sp(15)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Container(
                      // height: context.sp(70),
                      width: kIsWeb ? 60 : context.sp(60),
                      padding: EdgeInsets.symmetric(
                        vertical: kIsWeb ? 15 : context.sp(15),
                      ),
                      // height: size.width(.2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          kIsWeb ? 10 : context.sp(10),
                        ),
                        color: context.colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          felicitup.hasVideo
                              ? Column(
                                  children: [
                                    IconInfo(icon: Icons.play_arrow),
                                    SizedBox(
                                      height: kIsWeb ? 5 : context.sp(5),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          felicitup.hasBote
                              ? Column(
                                  children: [
                                    IconInfo(icon: Icons.euro),
                                    SizedBox(
                                      height: kIsWeb ? 5 : context.sp(5),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          IconInfo(icon: Icons.people_outline),
                        ],
                      ),
                    ),
                    SizedBox(width: kIsWeb ? 15 : context.sp(15)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CircleIcon extends StatelessWidget {
  const CircleIcon({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kIsWeb ? 25 : context.sp(25),
      width: kIsWeb ? 25 : context.sp(25),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.lightGrey,
        border: Border.all(color: context.colors.ligthOrange, width: 2),
      ),
      child: Icon(
        Icons.people_outline,
        color: context.colors.primary,
        size: kIsWeb ? 15 : context.sp(15),
      ),
    );
  }
}

class IconInfo extends StatelessWidget {
  const IconInfo({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kIsWeb ? 17 : context.sp(17),
      width: kIsWeb ? 17 : context.sp(17),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.colors.primary, width: 1),
      ),
      child: Icon(
        icon,
        color: context.colors.primary,
        size: kIsWeb ? 10 : context.sp(10),
      ),
    );
  }
}
