String? validateText(value) {
  if (value == null || value.isEmpty) {
    return 'Por favor rellena el campo';
  }
  return null;
}
