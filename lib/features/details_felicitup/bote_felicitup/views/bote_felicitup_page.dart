import 'package:collection/collection.dart';
import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/details_felicitup/details_felicitup.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class BoteFelicitupPage extends StatefulWidget {
  const BoteFelicitupPage({super.key});

  @override
  State<BoteFelicitupPage> createState() => _BoteFelicitupPageState();
}

class _BoteFelicitupPageState extends State<BoteFelicitupPage> {
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
                                  context.read<BoteFelicitupBloc>().add(
                                    BoteFelicitupEvent.setBoteQuantity(
                                      5 * (index + 1),
                                    ),
                                  );
                                  final felicitup = context
                                      .read<DetailsFelicitupDashboardBloc>()
                                      .state
                                      .felicitup;
                                  context.read<BoteFelicitupBloc>().add(
                                    BoteFelicitupEvent.updateFelicitupBote(
                                      felicitup?.id ?? '',
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
                                  context.read<BoteFelicitupBloc>().add(
                                    BoteFelicitupEvent.setBoteQuantity(
                                      int.parse(controller.text),
                                    ),
                                  );
                                  final felicitup = context
                                      .read<DetailsFelicitupDashboardBloc>()
                                      .state
                                      .felicitup;
                                  context.read<BoteFelicitupBloc>().add(
                                    BoteFelicitupEvent.updateFelicitupBote(
                                      felicitup?.id ?? '',
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
  void initState() {
    super.initState();
    detailsFelicitupNavigatorKey.currentContext!
        .read<DetailsFelicitupDashboardBloc>()
        .add(DetailsFelicitupDashboardEvent.changeCurrentIndex(4));

    final felicitup = context
        .read<DetailsFelicitupDashboardBloc>()
        .state
        .felicitup;
    context.read<BoteFelicitupBloc>().add(
      BoteFelicitupEvent.startListening(felicitup?.id ?? ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
          BlocBuilder<
            DetailsFelicitupDashboardBloc,
            DetailsFelicitupDashboardState
          >(
            buildWhen: (previous, current) =>
                previous.felicitup != current.felicitup,
            builder: (_, state) {
              final felicitup = state.felicitup;

              if (felicitup == null) {
                return SizedBox.shrink();
              }

              return BlocBuilder<AppBloc, AppState>(
                buildWhen: (previous, current) =>
                    previous.currentUser != current.currentUser,
                builder: (_, state) {
                  final currentUser = state.currentUser;
                  if (currentUser == null) {
                    return SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.sp(20)),
                    child:
                        felicitup.createdBy != currentUser.id &&
                            felicitup.invitedUserDetails
                                .where(
                                  (e) =>
                                      e.id == currentUser.id &&
                                      e.paid ==
                                          enumToStringPayment(
                                            PaymentStatus.pending,
                                          ),
                                )
                                .isNotEmpty
                        ? FloatingActionButton.extended(
                            onPressed: () {
                              context.go(
                                RouterPaths.payment,
                                extra: {
                                  'isVerify': false,
                                  'felicitup': felicitup,
                                },
                              );
                            },
                            backgroundColor: context.colors.orange,
                            label: Row(
                              children: [
                                Icon(Icons.check, color: context.colors.white),
                                SizedBox(width: context.sp(6)),
                                Text(
                                  'Pagar bote',
                                  style: context.styles.smallText.copyWith(
                                    color: context.colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : null,
                  );
                },
              );
            },
          ),
      body: Column(
        children: [
          Row(
            children: [
              Container(
                height: context.sp(40),
                width: context.sp(113),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(context.sp(20)),
                  color: context.colors.white,
                ),
                child: Text(
                  'Bote regalo',
                  style: context.styles.smallText.copyWith(
                    color: context.colors.softOrange,
                  ),
                ),
              ),
              Spacer(),
              BlocBuilder<
                DetailsFelicitupDashboardBloc,
                DetailsFelicitupDashboardState
              >(
                builder: (_, state) {
                  final felicitup = state.felicitup;

                  if (felicitup == null) {
                    return SizedBox.shrink();
                  }

                  return BlocBuilder<BoteFelicitupBloc, BoteFelicitupState>(
                    buildWhen: (previous, current) =>
                        previous.boteQuantity != current.boteQuantity,
                    builder: (_, state) {
                      return BlocBuilder<AppBloc, AppState>(
                        buildWhen: (previous, current) =>
                            previous.currentUser != current.currentUser,
                        builder: (_, appState) {
                          final currentUser = appState.currentUser;

                          if (currentUser == null) {
                            return SizedBox.shrink();
                          }

                          return GestureDetector(
                            onTap: felicitup.createdBy == currentUser.id
                                ? () {
                                    showBoteQuantity();
                                  }
                                : null,
                            child: Container(
                              height: context.sp(40),
                              width: context.sp(55),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  context.sp(20),
                                ),
                                color: Colors.white,
                              ),
                              child: Text(
                                state.boteQuantity != null
                                    ? '${state.boteQuantity}€'
                                    : '${felicitup.boteQuantity}€',
                                style: context.styles.smallText.copyWith(
                                  color: context.colors.softOrange,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
          SizedBox(height: context.sp(22)),
          BlocBuilder<BoteFelicitupBloc, BoteFelicitupState>(
            builder: (_, state) {
              final invitedUsers = state.invitedUsers;
              final friendList = context
                  .watch<InfoFelicitupBloc>()
                  .state
                  .friendList;

              return Expanded(
                child: ListView.builder(
                  itemCount: invitedUsers?.length ?? 0,
                  itemBuilder: (_, index) => Column(
                    children: [
                      BlocBuilder<AppBloc, AppState>(
                        buildWhen: (previous, current) =>
                            previous.currentUser != current.currentUser,
                        builder: (_, appState) {
                          final currentUser = appState.currentUser;
                          if (currentUser == null) {
                            return SizedBox.shrink();
                          }

                          return BlocBuilder<
                            DetailsFelicitupDashboardBloc,
                            DetailsFelicitupDashboardState
                          >(
                            buildWhen: (previous, current) =>
                                previous.felicitup != current.felicitup,
                            builder: (_, state) {
                              final felicitup = state.felicitup;

                              if (felicitup == null) {
                                return SizedBox.shrink();
                              }

                              final invitedUser = invitedUsers![index];
                              final user = friendList.firstWhereOrNull(
                                (user) => user.id == invitedUser.id,
                              );
                              final displayName =
                                  user?.getDisplayName(currentUser) ??
                                  invitedUser.name;
                              final userImage =
                                  user?.userImg ?? invitedUser.userImage ?? '';

                              return GestureDetector(
                                onTap: () {
                                  if (invitedUser.paid ==
                                          enumToStringPayment(
                                            PaymentStatus.pending,
                                          ) &&
                                      invitedUser.id == currentUser.id) {
                                    context.go(
                                      RouterPaths.payment,
                                      extra: {
                                        'isVerify': false,
                                        'felicitup': felicitup,
                                      },
                                    );
                                  }
                                  if (invitedUser.paid ==
                                          enumToStringPayment(
                                            PaymentStatus.waiting,
                                          ) &&
                                      felicitup.createdBy == currentUser.id) {
                                    context.go(
                                      RouterPaths.payment,
                                      extra: {
                                        'isVerify': true,
                                        'felicitup': felicitup,
                                        'userId': invitedUser.idInformation,
                                      },
                                    );
                                  }
                                },
                                child: DetailsRow(
                                  prefixChild: Row(
                                    children: [
                                      Container(
                                        height: context.sp(23),
                                        width: context.sp(23),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: context.colors.lightGrey,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            context.sp(100),
                                          ),
                                          child: CommonNetworkImage(
                                            imageUrl: userImage,
                                            errorWidget: Center(
                                              child: Text(
                                                (displayName?.isNotEmpty ??
                                                        false)
                                                    ? (displayName ?? '')[0]
                                                          .toUpperCase()
                                                    : '',
                                                style: context.styles.subtitle,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: context.sp(14)),
                                      Text(
                                        displayName ?? '',
                                        style: context.styles.smallText
                                            .copyWith(
                                              color:
                                                  invitedUser.paid ==
                                                      enumToStringPayment(
                                                        PaymentStatus.pending,
                                                      )
                                                  ? context.colors.text
                                                  : context.colors.primary,
                                            ),
                                      ),
                                    ],
                                  ),
                                  sufixChild: Container(
                                    padding: EdgeInsets.all(context.sp(5)),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          invitedUser.paid ==
                                              enumToStringPayment(
                                                PaymentStatus.paid,
                                              )
                                          ? Colors.lightGreen
                                          : invitedUser.paid ==
                                                enumToStringPayment(
                                                  PaymentStatus.waiting,
                                                )
                                          ? context.colors.softOrange
                                          : context.colors.otherGrey,
                                    ),
                                    child: Icon(
                                      Icons.euro,
                                      color:
                                          invitedUser.paid ==
                                                  enumToStringPayment(
                                                    PaymentStatus.paid,
                                                  ) ||
                                              invitedUser.paid ==
                                                  enumToStringPayment(
                                                    PaymentStatus.waiting,
                                                  )
                                          ? Colors.white
                                          : context.colors.darkGrey,
                                      size: context.sp(11),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      SizedBox(height: context.sp(12)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
