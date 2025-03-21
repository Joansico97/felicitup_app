import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PersonCard extends StatelessWidget {
  const PersonCard({
    super.key,
    required this.imageNetwork,
    required this.nameParticipant,
  });

  final String imageNetwork;
  final String nameParticipant;

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: context.sp(24),

      margin: EdgeInsets.symmetric(
        horizontal: context.sp(4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            height: context.sp(60),
            width: context.sp(60),
            decoration: BoxDecoration(shape: BoxShape.circle, color: context.colors.lightGrey),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(context.sp(30)),
              child: imageNetwork.isEmpty
                  ? SvgPicture.asset(
                      Assets.icons.personIcon,
                    )
                  : Image.network(
                      imageNetwork,
                    ),
            ),
          ),
          // Transform.scale(
          //   scale: 1.5,
          //   child: CircleAvatar(
          //     child: ClipRRect(
          //       borderRadius: BorderRadius.circular(context.sp(20)),
          //       child: imageNetwork.isEmpty
          //           ? SvgPicture.asset(
          //               Assets.icons.personIcon,
          //             )
          //           : Image.network(
          //               imageNetwork,
          //             ),
          //     ),
          //   ),
          // ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.sp(4),
            ),
            child: Text(
              nameParticipant,
              overflow: TextOverflow.ellipsis,
              style: context.styles.smallText,
            ),
          ),
        ],
      ),
    );
  }
}
