import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';

Future<DateTime?> showGenericDatePicker({
  required BuildContext context,
  DateTime? initialDate, // Fecha inicial (opcional).
  DateTime? firstDate, // Primera fecha seleccionable (opcional).
  DateTime? lastDate, // Última fecha seleccionable (opcional).
  DatePickerMode initialDatePickerMode = DatePickerMode.day, // Modo inicial (día/año).
  SelectableDayPredicate? selectableDayPredicate, // Predicado para días seleccionables (opcional).
  String? helpText,
  String? cancelText,
  String? confirmText,
  Locale? locale,
  String? fieldHintText, //Nuevo
  String? fieldLabelText, //Nuevo
}) async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: initialDate ?? DateTime.now(), // Si no se proporciona, usa la fecha actual.
    firstDate: firstDate ?? DateTime(2000), // Fecha mínima predeterminada.
    lastDate: lastDate ?? DateTime(2101), // Fecha máxima predeterminada.
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
          colorScheme: ColorScheme.light(
            primary: context.colors.orange,
          ),
        ),
        child: child!,
      );
    },
  );

  return pickedDate; // Devuelve la fecha seleccionada (o null si se cancela).
}

// Función genérica para showTimePicker.
Future<TimeOfDay?> showGenericTimePicker(
    {required BuildContext context,
    TimeOfDay? initialTime, // Hora inicial (opcional).
    bool useRootNavigator = true, //Usar el root navigator
    String? cancelText, //Texto del botón cancelar
    String? confirmText, //Texto del botón confirmar
    String? helpText, //Texto de ayuda
    TimePickerEntryMode initialEntryMode = TimePickerEntryMode.dial, //Ver el reloj o el input
    String? errorInvalidText //Error de texto invalido
    }) async {
  final TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    initialTime: initialTime ?? TimeOfDay.now(), // Si no se proporciona, usa la hora actual.

    useRootNavigator: useRootNavigator,
    cancelText: cancelText,
    confirmText: confirmText,
    helpText: helpText,
    initialEntryMode: initialEntryMode,
    errorInvalidText: errorInvalidText,
    builder: (_, child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: context.colors.orange,
          ),
        ),
        child: child!,
      );
    },
  );

  return pickedTime; // Devuelve la hora seleccionada (o null si se cancela).
}

DateTime? combineDateAndTime(DateTime? date, TimeOfDay? time) {
  if (date == null || time == null) {
    return null; // Si alguno es nulo, devuelve nulo.
  }

  return DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
}
