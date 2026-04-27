import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';

Future<DateTime?> showGenericDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  DatePickerMode initialDatePickerMode = DatePickerMode.day,
  SelectableDayPredicate? selectableDayPredicate,
  String? helpText,
  String? cancelText,
  String? confirmText,
  Locale? locale,
  String? fieldHintText,
  String? fieldLabelText,
}) async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: initialDate ?? DateTime.now(),
    firstDate: firstDate ?? DateTime(2000),
    lastDate: lastDate ?? DateTime(2101),
    initialDatePickerMode: initialDatePickerMode,
    selectableDayPredicate: selectableDayPredicate,
    helpText: helpText,
    cancelText: cancelText,
    confirmText: confirmText,
    locale: locale,
    fieldHintText: fieldHintText,
    fieldLabelText: fieldLabelText,
    builder: (_, child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(primary: context.colors.orange),
          inputDecorationTheme: InputDecorationTheme(
            hintStyle: context.styles.paragraph,
          ),
        ),
        child: child!,
      );
    },
  );

  return pickedDate;
}

Future<TimeOfDay?> showGenericTimePicker({
  required BuildContext context,
  TimeOfDay? initialTime,
  bool useRootNavigator = true,
  String? cancelText,
  String? confirmText,
  String? helpText,
  TimePickerEntryMode initialEntryMode = TimePickerEntryMode.dial,
  String? errorInvalidText,
}) async {
  final TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    initialTime: initialTime ?? TimeOfDay.now(),

    useRootNavigator: useRootNavigator,
    cancelText: cancelText,
    confirmText: confirmText,
    helpText: helpText,
    initialEntryMode: initialEntryMode,
    errorInvalidText: errorInvalidText,
    builder: (_, child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(primary: context.colors.orange),
        ),
        child: child!,
      );
    },
  );

  return pickedTime;
}

DateTime? combineDateAndTime(DateTime? date, TimeOfDay? time) {
  if (date == null || time == null) {
    return null;
  }

  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}
