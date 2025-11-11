enum Priority {
  normal('NORMAL'),
  high('HIGH'),
  urgent('URGENT');

  const Priority(this.value);
  final String value;

  static Priority fromString(String value) {
    switch (value.toUpperCase()) {
      case 'HIGH':
        return Priority.high;
      case 'URGENT':
        return Priority.urgent;
      default:
        return Priority.normal;
    }
  }
}