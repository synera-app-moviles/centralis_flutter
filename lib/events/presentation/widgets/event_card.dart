import 'package:flutter/material.dart';
import '../../data/models/event_model.dart';

 class EventCard extends StatelessWidget {
   final EventModel event;
   final VoidCallback onTap;
   final VoidCallback? onEdit; // Nuevo callback para editar

   const EventCard({
     Key? key,
     required this.event,
     required this.onTap,
     this.onEdit, // Opcional
   }) : super(key: key);

   String _formatDate(String date) {
     try {
       final replaced = date.replaceAll('T', ' ').replaceAll('Z', '');
       return replaced.length > 16 ? replaced.substring(0, 16) : replaced;
     } catch (e) {
       return date;
     }
   }

   @override
   Widget build(BuildContext context) {
     return Padding(
       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
       child: Row(
         children: [
           // Icon container
           Container(
             width: 48,
             height: 48,
             decoration: BoxDecoration(
               color: const Color(0xFF30214A),
               borderRadius: BorderRadius.circular(5),
             ),
             child: const Icon(
               Icons.calendar_today,
               color: Colors.white,
               size: 20,
             ),
           ),
           const SizedBox(width: 20),
           // Event info
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   event.title,
                   style: const TextStyle(
                     fontSize: 16,
                     fontWeight: FontWeight.bold,
                     color: Colors.white,
                   ),
                   maxLines: 2,
                   overflow: TextOverflow.ellipsis,
                 ),
                 const SizedBox(height: 4),
                 Text(
                   'Location: ${event.location ?? "Sin ubicación"}',
                   style: const TextStyle(
                     fontSize: 14,
                     color: Color(0xFFB3B3B3),
                   ),
                 ),
                 Text(
                   'Attendees: ${event.recipientIds.length}',
                   style: const TextStyle(
                     fontSize: 14,
                     color: Color(0xFFB3B3B3),
                   ),
                 ),
                 Text(
                   _formatDate(event.date),
                   style: const TextStyle(
                     fontSize: 14,
                     color: Color(0xFFB3B3B3),
                   ),
                 ),
               ],
             ),
           ),
           // Columna con ambos botones
           Column(
             children: [
               SizedBox(
                 width: 90,
                 height: 35,
                 child: ElevatedButton(
                   onPressed: onTap,
                   style: ElevatedButton.styleFrom(
                     backgroundColor: const Color(0xFF302149),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(8),
                     ),
                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   ),
                   child: const Text(
                     'Details',
                     style: TextStyle(
                       color: Colors.white,
                       fontSize: 12,
                     ),
                   ),
                 ),
               ),
               const SizedBox(height: 8),
               // Botón de editar
               if (onEdit != null)
                 SizedBox(
                   width: 90,
                   height: 35,
                   child: ElevatedButton(
                     onPressed: onEdit,
                     style: ElevatedButton.styleFrom(
                       backgroundColor: const Color(0xFFA68FCC),
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(8),
                       ),
                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                     ),
                     child: const Text(
                       'Edit',
                       style: TextStyle(
                         color: Colors.white,
                         fontSize: 12,
                       ),
                     ),
                   ),
                 ),
             ],
           ),
         ],
       ),
     );
   }
 }