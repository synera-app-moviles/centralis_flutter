import 'package:flutter/material.dart';
 import 'package:flutter_bloc/flutter_bloc.dart';
 import '../bloc/event_bloc.dart';
 import '../bloc/event_event.dart';
 import '../bloc/event_state.dart';
 import '../widgets/date_time_picker_field.dart';
 import '../../data/models/update_event_request.dart';

 class UpdateEventPage extends StatefulWidget {
   final String eventId;

   const UpdateEventPage({super.key, required this.eventId});

   @override
   State<UpdateEventPage> createState() => _UpdateEventPageState();
 }

 class _UpdateEventPageState extends State<UpdateEventPage> {
   final _formKey = GlobalKey<FormState>();
   final _titleController = TextEditingController();
   final _descriptionController = TextEditingController();
   final _locationController = TextEditingController();
   String _dateTime = '';

   @override
   void initState() {
     super.initState();
     context.read<EventBloc>().add(LoadEventById(widget.eventId));
   }

   void _updateEvent() {
     if (_formKey.currentState!.validate()) {
       final request = UpdateEventRequest(
         title: _titleController.text.trim(),
         description: _descriptionController.text.trim(),
         date: _dateTime.isEmpty ? null : _dateTime,
         location: _locationController.text.trim(),
         recipientIds: null, // O actualiza si necesitas
       );

       context.read<EventBloc>().add(UpdateEvent(widget.eventId, request));
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
         title: const Text('Update Event', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
         centerTitle: true,
       ),
       body: BlocConsumer<EventBloc, EventState>(
         listener: (context, state) {
           if (state is EventOperationSuccess) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
             Navigator.pop(context, true);
           } else if (state is EventError) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
           }
         },
         builder: (context, state) {
           if (state is EventLoading) {
             return const Center(child: CircularProgressIndicator(color: Color(0xFFA68FCC)));
           }

           if (state is EventLoaded) {
             _titleController.text = state.event.title;
             _descriptionController.text = state.event.description;
             _locationController.text = state.event.location ?? '';
             _dateTime = state.event.date;
           }

           return SingleChildScrollView(
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
                   ElevatedButton(
                     onPressed: _updateEvent,
                     style: ElevatedButton.styleFrom(
                       backgroundColor: const Color(0xFFA68FCC),
                       padding: const EdgeInsets.symmetric(vertical: 12),
                     ),
                     child: const Text('Update Event', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                   ),
                 ],
               ),
             ),
           );
         },
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