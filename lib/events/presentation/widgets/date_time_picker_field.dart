import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimePickerField extends StatefulWidget {
  final String value;
  final Function(String) onValueChange;
  final Color selectedColor;
  final Color headerBackground;
  final Color textColor;

  const DateTimePickerField({
    super.key,
    required this.value,
    required this.onValueChange,
    this.selectedColor = const Color(0xFFA68FCC),
    this.headerBackground = const Color(0xFF302149),
    this.textColor = Colors.white,
  });

  @override
  State<DateTimePickerField> createState() => _DateTimePickerFieldState();
}

class _DateTimePickerFieldState extends State<DateTimePickerField> {
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _parseInitialValue();
  }

  void _parseInitialValue() {
    if (widget.value.isNotEmpty) {
      try {
        _selectedDateTime = DateTime.parse(widget.value.replaceAll(' ', 'T'));
      } catch (e) {
        _selectedDateTime = null;
      }
    }
  }

  Future<void> _showDateTimePicker() async {
    final now = DateTime.now();
    final initialDate = _selectedDateTime ?? now;

    // Mostrar selector de fecha
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: widget.selectedColor,
              onPrimary: Colors.white,
              surface: widget.headerBackground,
              onSurface: widget.textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null) return;

    // Mostrar selector de hora
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: widget.selectedColor,
              onPrimary: Colors.white,
              surface: widget.headerBackground,
              onSurface: widget.textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time == null) return;

    // Combinar fecha y hora
    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      _selectedDateTime = dateTime;
    });

    // Formato ISO 8601: yyyy-MM-ddTHH:mm:ss
    final formattedDateTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(dateTime);
    widget.onValueChange(formattedDateTime);
  }

  String _getDisplayValue() {
    if (_selectedDateTime != null) {
      return DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime!);
    }
    return widget.value.replaceAll('T', ' ').substring(0, widget.value.length > 16 ? 16 : widget.value.length);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: _getDisplayValue()),
      style: TextStyle(color: widget.selectedColor),
      decoration: InputDecoration(
        labelText: 'Fecha y hora',
        labelStyle: TextStyle(color: widget.selectedColor),
        filled: true,
        fillColor: const Color(0xFF30214A),
        border: const OutlineInputBorder(borderSide: BorderSide.none),
        suffixIcon: Icon(
          Icons.calendar_today,
          color: widget.selectedColor,
          size: 20,
        ),
      ),
      onTap: _showDateTimePicker,
      validator: (value) =>
          (value?.isEmpty ?? true) ? 'Selecciona fecha y hora' : null,
    );
  }
}