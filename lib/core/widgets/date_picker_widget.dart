import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/common/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerWidget extends StatefulWidget {
  const DatePickerWidget({
    super.key,
    required this.onSelectNewDate,
    this.initialDate,
  });

  final Function(DateTime date) onSelectNewDate;
  final DateTime? initialDate;

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  DateTime? birthDate;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        FocusScope.of(context).unfocus();
        final DateTime? pickedDate = await showGenericDatePicker(
          context: context,
          initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
          firstDate: DateTime(1939),
          lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
          helpText: 'Selecciona una fecha',
          cancelText: 'Cancelar',
          confirmText: 'OK',
          locale: const Locale('es', 'ES'),
        );

        if (pickedDate == null) return;

        setState(() {
          birthDate = pickedDate;
        });

        widget.onSelectNewDate(birthDate!);
      },
      child: Container(
        height: context.sp(45),
        padding: EdgeInsets.symmetric(horizontal: context.sp(12)),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: context.sp(1),
              color: context.colors.darkGrey,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              birthDate == null
                  ? DateFormat(
                      'dd MMM, yyyy',
                    ).format(widget.initialDate ?? DateTime.now())
                  : DateFormat('dd MMM, yyyy').format(birthDate!),
              style: context.styles.paragraph.copyWith(
                color: birthDate == null
                    ? context.colors.darkGrey
                    : context.colors.black,
              ),
            ),
            Icon(Icons.calendar_month_rounded, color: context.colors.orange),
          ],
        ),
      ),
    );
  }
}
