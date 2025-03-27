import 'dart:async';
import 'dart:io';

import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/payment/bloc/payment_bloc.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConfirmPayment extends StatefulWidget {
  const ConfirmPayment({
    super.key,
    required this.felicitup,
  });

  final FelicitupModel felicitup;

  @override
  State<ConfirmPayment> createState() => _ConfirmPaymentState();
}

class _ConfirmPaymentState extends State<ConfirmPayment> {
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
                  width: context.sp(300),
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
                              DataMessageModel(
                                type: enumToPushMessageType(PushMessageType.payment),
                                felicitupId: widget.felicitup.id,
                                chatId: '',
                                name: '',
                              ),
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
