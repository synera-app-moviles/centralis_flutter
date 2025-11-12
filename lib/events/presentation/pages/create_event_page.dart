import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/event_bloc.dart';
import '../bloc/event_event.dart';
import '../bloc/event_state.dart';
import '../widgets/date_time_picker_field.dart';
import '../../data/models/create_event_request.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  String _dateTime = '';

  void _createEvent() {
    if (_formKey.currentState!.validate()) {
      if (_dateTime.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select date and time')),
        );
        return;
      }

      final request = CreateEventRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _dateTime,
        location: _locationController.text.trim(),
        recipientIds: ['00000000-0000-0000-0000-000000000000'], // TODO: obtener IDs reales
        createdBy: '00000000-0000-0000-0000-000000000000', // TODO: obtener userId del token
      );

      context.read<EventBloc>().add(CreateEvent(request));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF170F24),
      appBar: AppBar(
        backgroundColor: const Color(0xFF170F24),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Create Event', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: BlocListener<EventBloc, EventState>(
        listener: (context, state) {
          if (state is EventOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.pop(context, true); // Retorna true para indicar que se creó
          } else if (state is EventError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: Color(0xFFA68FCC)),
                  decoration: const InputDecoration(
                    labelText: 'Event title',
                    labelStyle: TextStyle(color: Color(0xFFA68FCC)),
                    filled: true,
                    fillColor: Color(0xFF30214A),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  style: const TextStyle(color: Color(0xFFA68FCC)),
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Event description',
                    labelStyle: TextStyle(color: Color(0xFFA68FCC)),
                    filled: true,
                    fillColor: Color(0xFF30214A),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Description is required' : null,
                ),
                const SizedBox(height: 16),
                DateTimePickerField(
                  value: _dateTime,
                  onValueChange: (value) => setState(() => _dateTime = value),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  style: const TextStyle(color: Color(0xFFA68FCC)),
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    labelStyle: TextStyle(color: Color(0xFFA68FCC)),
                    filled: true,
                    fillColor: Color(0xFF30214A),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 24),
                BlocBuilder<EventBloc, EventState>(
                  builder: (context, state) {
                    final isLoading = state is EventLoading;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _createEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA68FCC),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Create Event', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}