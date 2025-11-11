import 'package:flutter/material.dart';
import '../widgets/date_time_picker_field.dart';

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
   Widget build(BuildContext context) {
     return Scaffold(
       backgroundColor: const Color(0xFF170F24),
       appBar: AppBar(
         backgroundColor: const Color(0xFF170F24),
         leading: IconButton(
           icon: const Icon(Icons.arrow_back, color: Colors.white),
           onPressed: () => Navigator.pop(context),
         ),
         title: const Text(
           'Update Event',
           style: TextStyle(
             color: Colors.white,
             fontSize: 24,
             fontWeight: FontWeight.bold,
           ),
         ),
         centerTitle: true,
       ),
       body: SingleChildScrollView(
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
                 onPressed: () {
                   Navigator.pop(context);
                 },
                 style: ElevatedButton.styleFrom(
                   backgroundColor: const Color(0xFFA68FCC),
                   padding: const EdgeInsets.symmetric(vertical: 12),
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(8),
                   ),
                 ),
                 child: const Text(
                   'Update Event',
                   style: TextStyle(
                     color: Colors.white,
                     fontSize: 16,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
               ),
             ],
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