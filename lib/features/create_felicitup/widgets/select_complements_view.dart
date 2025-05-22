import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/create_felicitup/bloc/create_felicitup_bloc.dart';
import 'package:felicitup_app/features/create_felicitup/widgets/widgets.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class SelectComplementsView extends StatefulWidget {
  const SelectComplementsView({super.key});

  @override
  State<SelectComplementsView> createState() => _SelectComplementsViewState();
}

class _SelectComplementsViewState extends State<SelectComplementsView> {
  void showBoteQuantity() {
    showDialog(
      context: context,
      builder: (_) {
        final controller = TextEditingController();

        return AlertDialog(
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: context.sp(600),
              maxWidth: context.sp(200),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.sp(20),
                vertical: context.sp(10),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text('Bote de regalo', style: context.styles.header2),
                    SizedBox(height: context.sp(12)),
                    Text(
                      'Selecciona la cantidad deseada para el bote regalo.',
                      textAlign: TextAlign.center,
                      style: context.styles.smallText,
                    ),
                    SizedBox(height: context.sp(12)),
                    SizedBox(
                      height: context.sp(250),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ...List.generate(
                              20,
                              (index) => GestureDetector(
                                onTap: () {
                                  context.read<CreateFelicitupBloc>().add(
                                    CreateFelicitupEvent.changeBoteQuantity(
                                      5 * (index + 1),
                                    ),
                                  );
                                  context.pop();
                                },
                                child: Container(
                                  width: context.sp(320),
                                  margin: EdgeInsets.only(
                                    bottom: context.sp(10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: context.sp(10),
                                  ),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: context.colors.orange,
                                    borderRadius: BorderRadius.circular(
                                      context.sp(10),
                                    ),
                                  ),
                                  child: Text(
                                    '${5 * (index + 1)}€',
                                    style: context.styles.subtitle.copyWith(
                                      color: context.colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: context.sp(12)),
                    SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: context.sp(130),
                            child: InputCommon(
                              controller: controller,
                              hintText: '0.00 €',
                              titleText: 'Cantidad personalizada',
                              isPrice: true,
                              onchangeEditing: (value) {},
                            ),
                          ),
                          Column(
                            children: [
                              SizedBox(height: context.sp(5)),
                              GestureDetector(
                                onTap: () {
                                  context.read<CreateFelicitupBloc>().add(
                                    CreateFelicitupEvent.changeBoteQuantity(
                                      int.parse(
                                        controller.text.isNotEmpty
                                            ? controller.text
                                            : '0',
                                      ),
                                    ),
                                  );
                                  context.pop();
                                },
                                child: Icon(
                                  Icons.check_box_outlined,
                                  color: context.colors.orange,
                                  size: context.sp(30),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.sp(20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BlocBuilder<CreateFelicitupBloc, CreateFelicitupState>(
                builder: (_, state) {
                  final listOwner = state.felicitupOwner;
                  return listOwner.isEmpty || listOwner[0].userImg == ''
                      ? SizedBox(
                        width: context.sp(120),
                        child: SvgPicture.asset(
                          Assets.icons.personIcon,
                          height: context.sp(76),
                          width: context.sp(76),
                          colorFilter: ColorFilter.mode(
                            Color(0xFFDADADA),
                            BlendMode.srcIn,
                          ),
                        ),
                      )
                      : Container(
                        height: context.sp(76),
                        width: context.sp(76),
                        margin: EdgeInsets.only(
                          left: context.sp(25),
                          right: context.sp(25),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(context.sp(100)),
                          child: Image.network(
                            listOwner[0].userImg ?? '',
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                },
              ),
              SizedBox(
                width: context.sp(150),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('| Paso 04', style: context.styles.menu),
                    SizedBox(height: context.sp(8)),
                    Text('¿Qué hacemos?', style: context.styles.subtitle),
                    SizedBox(height: context.sp(8)),
                    Text(
                      'Elige los elementos que tendrá tu Felicitup.',
                      style: context.styles.paragraph,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.sp(12)),
        BlocBuilder<CreateFelicitupBloc, CreateFelicitupState>(
          builder: (_, state) {
            final hasBote = state.hasBote;
            final hasVideo = state.hasVideo;
            final boteQuantity = state.boteQuantity ?? 0;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: context.sp(20)),
              child: Column(
                children: [
                  ActivityCard(
                    activity: 'Videogrupo',
                    onTap:
                        () => context.read<CreateFelicitupBloc>().add(
                          CreateFelicitupEvent.toggleHasVideo(),
                        ),
                    isActive: hasVideo,
                  ),
                  ActivityCard(
                    activity: 'Bote Regalo',
                    onTap:
                        () => context.read<CreateFelicitupBloc>().add(
                          CreateFelicitupEvent.toggleHasBote(),
                        ),
                    isActive: hasBote,
                  ),
                  Visibility(
                    visible: hasBote,
                    child: GestureDetector(
                      onTap: () => showBoteQuantity(),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.sp(35),
                          vertical: context.sp(18),
                        ),
                        margin: EdgeInsets.only(bottom: context.sp(10)),
                        width: context.fullWidth,
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F6F6),
                          borderRadius: BorderRadius.circular(context.sp(10)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Cantidad del bote',
                              style: context.styles.subtitle,
                            ),
                            Spacer(),
                            Text(
                              '$boteQuantity€',
                              style: context.styles.subtitle,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
