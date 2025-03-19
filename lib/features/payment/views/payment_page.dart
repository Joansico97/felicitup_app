import 'dart:async';
import 'dart:io';

import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/payment/bloc/payment_bloc.dart';
import 'package:felicitup_app/helpers/helpers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({
    super.key,
    required this.isVerify,
    required this.felicitup,
    required this.userId,
  });

  final bool isVerify;
  final FelicitupModel felicitup;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listenWhen: (previous, current) =>
          previous.isLoading != current.isLoading || previous.updateStatus != current.updateStatus,
      listener: (_, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }

        if (state.updateStatus == UpdateStatus.success) {
          context.go(
            RouterPaths.boteFelicitup,
            extra: felicitup.id,
          );
        } else if (state.updateStatus == UpdateStatus.error) {
          await showErrorModal(state.errorMessage);
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: context.sp(50),
                  width: context.fullWidth,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.sp(12),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: context.fullWidth,
                        child: Text(
                          '${felicitup.reason} de ${felicitup.owner[0].name.split(' ')[0]}',
                          textAlign: TextAlign.center,
                          style: context.styles.subtitle,
                        ),
                      ),
                      Container(
                        width: context.fullWidth,
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.black,
                          ),
                          onPressed: () async {
                            // await ref.read(userAuthProvider).updateCurrentChat(chatId: '');
                            if (context.mounted) {
                              context.go(
                                RouterPaths.boteFelicitup,
                                extra: felicitup.id,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.sp(12)),
                isVerify
                    ? VerifyPayment(
                        felicitup: felicitup,
                        userId: userId,
                      )
                    : ConfirmView(felicitup: felicitup),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VerifyPayment extends StatefulWidget {
  const VerifyPayment({
    super.key,
    required this.felicitup,
    required this.userId,
  });

  final FelicitupModel felicitup;
  final String userId;

  @override
  State<VerifyPayment> createState() => _VerifyPaymentState();
}

class _VerifyPaymentState extends State<VerifyPayment> {
  @override
  void initState() {
    super.initState();
    context.read<PaymentBloc>().add(PaymentEvent.getUserInformation(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(24),
      ),
      child: Column(
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
              Container(
                height: context.sp(40),
                width: context.sp(55),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(context.sp(20)),
                  color: context.colors.white,
                ),
                child: Text(
                  '${widget.felicitup.boteQuantity}€',
                  style: context.styles.smallText.copyWith(
                    color: context.colors.softOrange,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.sp(24)),
          Container(
            padding: EdgeInsets.all(context.sp(24)),
            decoration: BoxDecoration(
              color: context.colors.white,
              borderRadius: BorderRadius.circular(context.sp(20)),
            ),
            child: Column(
              children: [
                Container(
                  height: context.sp(40),
                  width: context.fullWidth,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.sp(10),
                    vertical: context.sp(8),
                  ),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(context.sp(30)),
                    border: Border.all(
                      color: context.colors.darkGrey,
                      width: context.sp(1),
                    ),
                    color: context.colors.white,
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: 'Estado de pago: ',
                      style: context.styles.paragraph.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: 'A la espera',
                          style: context.styles.paragraph,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: context.sp(14)),
                Container(
                  height: context.sp(40),
                  width: context.fullWidth,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.sp(10),
                    vertical: context.sp(8),
                  ),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(context.sp(30)),
                    border: Border.all(
                      color: context.colors.darkGrey,
                      width: context.sp(1),
                    ),
                    color: context.colors.white,
                  ),
                  child: BlocBuilder<PaymentBloc, PaymentState>(
                    builder: (_, state) {
                      return RichText(
                        text: TextSpan(
                          text: 'Fecha de pago: ',
                          style: context.styles.paragraph.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: DateFormat('dd/MM/yyyy').format(
                                state.userInvitedInformationModel?.paymentDate ?? DateTime.now(),
                              ),
                              style: context.styles.paragraph,
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: context.sp(14)),
                Container(
                  height: context.sp(40),
                  width: context.fullWidth,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.sp(10),
                    vertical: context.sp(8),
                  ),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(context.sp(30)),
                    border: Border.all(
                      color: context.colors.darkGrey,
                      width: context.sp(1),
                    ),
                    color: context.colors.white,
                  ),
                  child: BlocBuilder<PaymentBloc, PaymentState>(
                    builder: (_, state) {
                      return RichText(
                        text: TextSpan(
                          text: 'Medio de pago: ',
                          style: context.styles.paragraph.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: state.userInvitedInformationModel?.paymentMethod ?? 'No disponible',
                              style: context.styles.paragraph,
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: context.sp(14)),
                GestureDetector(
                  onTap: () => showImageModal(
                    context,
                    context.read<PaymentBloc>().state.userInvitedInformationModel?.photoUrl ?? '',
                  ),
                  child: Container(
                    height: context.sp(350),
                    width: context.fullWidth,
                    padding: EdgeInsets.all(context.sp(10)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(context.sp(30)),
                      border: Border.all(
                        color: context.colors.darkGrey,
                        width: context.sp(1),
                      ),
                      color: context.colors.white,
                    ),
                    child: BlocBuilder<PaymentBloc, PaymentState>(
                      builder: (_, state) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(context.sp(30)),
                          child: Image.network(
                            state.userInvitedInformationModel?.photoUrl ?? '',
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: context.sp(14)),
                SizedBox(
                  width: context.sp(200),
                  child: PrimaryButton(
                    onTap: () => context.read<PaymentBloc>().add(
                          PaymentEvent.confirmPaymentInfo(
                            widget.felicitup.id,
                            widget.felicitup.invitedUserDetails
                                    .where(
                                      (element) => element.idInformation == widget.userId,
                                    )
                                    .first
                                    .id ??
                                '',
                          ),
                        ),
                    label: 'Confirmar pago',
                    isActive: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ConfirmView extends StatefulWidget {
  const ConfirmView({
    super.key,
    required this.felicitup,
  });

  final FelicitupModel felicitup;

  @override
  State<ConfirmView> createState() => _ConfirmViewState();
}

class _ConfirmViewState extends State<ConfirmView> {
  String selectedPaymentStatus = 'Estado del pago';
  String selectedPaymentMethod = 'Medio de pago';
  DateTime? selectedDate;
  File? selectedImage;

  final List<String> paymentStatusList = [
    'Estado del pago',
    'Pagado',
  ];
  final List<String> paymentMethodList = [
    'Medio de pago',
    'Bizum',
    'Tarjeta de crédito',
    'PayPal',
    'Google Pay',
    'Apple Pay',
    'Otro',
  ];

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AppBloc>().state.currentUser;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(24),
      ),
      child: Column(
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
              Container(
                height: context.sp(40),
                width: context.sp(55),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(context.sp(20)),
                  color: context.colors.white,
                ),
                child: Text(
                  '${widget.felicitup.boteQuantity}€',
                  style: context.styles.smallText.copyWith(
                    color: context.colors.softOrange,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.sp(24)),
          Container(
            padding: EdgeInsets.all(context.sp(24)),
            decoration: BoxDecoration(
              color: context.colors.white,
              borderRadius: BorderRadius.circular(context.sp(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: context.sp(40),
                  width: context.fullWidth,
                  padding: EdgeInsets.all(context.sp(10)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(context.sp(30)),
                    border: Border.all(
                      color: context.colors.darkGrey,
                      width: context.sp(1),
                    ),
                    color: context.colors.white,
                  ),
                  child: DropdownButton<String>(
                    value: selectedPaymentStatus,
                    style: context.styles.paragraph,
                    isExpanded: true,
                    items: paymentStatusList.map<DropdownMenuItem<String>>(
                      (String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: context.styles.paragraph,
                          ),
                        );
                      },
                    ).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPaymentStatus = newValue!;
                      });
                    },
                  ),
                ),
                SizedBox(height: context.sp(14)),
                GestureDetector(
                  onTap: () async {
                    unawaited(startLoadingModal());
                    DateTime? date = await showGenericDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: widget.felicitup.createdAt,
                      lastDate: DateTime(2100),
                      helpText: 'Selecciona una fecha',
                      cancelText: 'Cancelar',
                      confirmText: 'OK',
                      locale: const Locale('es', 'ES'),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                    await stopLoadingModal();
                  },
                  child: Container(
                    height: context.sp(40),
                    width: context.fullWidth,
                    padding: EdgeInsets.symmetric(
                      horizontal: context.sp(10),
                      vertical: context.sp(8),
                    ),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(context.sp(30)),
                      border: Border.all(
                        color: context.colors.darkGrey,
                        width: context.sp(1),
                      ),
                      color: context.colors.white,
                    ),
                    child: Row(
                      children: [
                        Text(
                          selectedDate != null
                              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                              : 'Fecha de pago',
                          style: context.styles.paragraph,
                        ),
                        Spacer(),
                        Icon(
                          Icons.arrow_drop_down,
                          color: context.colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: context.sp(14)),
                Container(
                  height: context.sp(40),
                  width: context.fullWidth,
                  padding: EdgeInsets.all(context.sp(10)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(context.sp(30)),
                    border: Border.all(
                      color: context.colors.darkGrey,
                      width: context.sp(1),
                    ),
                    color: context.colors.white,
                  ),
                  child: DropdownButton<String>(
                    value: selectedPaymentMethod,
                    style: context.styles.paragraph,
                    isExpanded: true,
                    items: paymentMethodList.map<DropdownMenuItem<String>>(
                      (String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: context.styles.paragraph,
                          ),
                        );
                      },
                    ).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPaymentMethod = newValue!;
                      });
                      // ref.read(felicitupDetailsEventProvider.notifier).setPaymentStatus(newValue!);
                    },
                  ),
                ),
                SizedBox(height: context.sp(14)),
                GestureDetector(
                  onTap: () {
                    showConfirDoublemModal(
                      title: 'Selecciona una opción',
                      isDestructive: true,
                      onAction1: () async {
                        final File? response = await pickImageFromGallery();

                        if (response != null) {
                          setState(() {
                            selectedImage = File(response.path);
                          });
                          context.read<PaymentBloc>().add(PaymentEvent.uploadPaymenFile(selectedImage!));
                        }
                      },
                      onAction2: () async {
                        final File? response = await pickImageFromCamera();

                        if (response != null) {
                          setState(() {
                            selectedImage = File(response.path);
                          });
                          context.read<PaymentBloc>().add(PaymentEvent.uploadPaymenFile(selectedImage!));
                        }
                      },
                      label1: 'Galería',
                      label2: 'Cámara',
                    );
                  },
                  child: Container(
                    height: context.sp(350),
                    width: context.fullWidth,
                    padding: EdgeInsets.all(context.sp(10)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(context.sp(30)),
                      border: Border.all(
                        color: context.colors.darkGrey,
                        width: context.sp(1),
                      ),
                      color: context.colors.white,
                    ),
                    child: selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(context.sp(30)),
                            child: Image.file(
                              selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt_outlined,
                                color: context.colors.darkGrey,
                              ),
                              Text(
                                'Subir comprobante',
                                style: context.styles.paragraph.copyWith(
                                  color: context.colors.darkGrey,
                                ),
                              )
                            ],
                          ),
                  ),
                ),
                SizedBox(height: context.sp(14)),
                SizedBox(
                  width: context.sp(200),
                  child: PrimaryButton(
                    onTap: () {
                      context.read<PaymentBloc>().add(
                            PaymentEvent.updatePaymentInfo(
                              widget.felicitup.id,
                              selectedPaymentMethod,
                              selectedPaymentStatus,
                              selectedDate!,
                              '',
                            ),
                          );
                      context.read<PaymentBloc>().add(
                            PaymentEvent.sendNotification(
                              widget.felicitup.createdBy,
                              'Pago realizado',
                              '${currentUser?.firstName ?? ''} ha realizado el pago de la felicitup de ${widget.felicitup.owner.first.name.split(' ')[0]}',
                              '',
                              {
                                'felicitupId': widget.felicitup.id,
                                'chatId': '',
                                'isAssistance': 'pago',
                                'isPast': 'false',
                                'singleChatId': '',
                                'name': '',
                                'ids': [],
                              },
                            ),
                          );
                    },
                    label: 'Enviar Pago',
                    isActive: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
