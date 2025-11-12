import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import '../bloc/event_bloc.dart';
  import '../bloc/event_event.dart';
  import '../bloc/event_state.dart';
  import '../widgets/delete_event_dialog.dart';

  class EventDetailsPage extends StatefulWidget {
    final String eventId;

    const EventDetailsPage({super.key, required this.eventId});

    @override
    State<EventDetailsPage> createState() => _EventDetailsPageState();
  }

  class _EventDetailsPageState extends State<EventDetailsPage> {
    @override
    void initState() {
      super.initState();
      context.read<EventBloc>().add(LoadEventById(widget.eventId));
    }

    void _deleteEvent() {
      showDialog(
        context: context,
        builder: (context) => DeleteEventDialog(
          onConfirm: () {
            context.read<EventBloc>().add(DeleteEvent(widget.eventId));
          },
        ),
      );
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
          title: const Text(
            'Event Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<EventBloc, EventState>(
          listener: (context, state) {
            if (state is EventOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              Navigator.pop(context, true); // Retornar a la lista
            } else if (state is EventError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          builder: (context, state) {
            if (state is EventLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is EventLoaded) {
              final event = state.event;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard('Title', event.title),
                    const SizedBox(height: 16),
                    _buildInfoCard('Description', event.description),
                    const SizedBox(height: 16),
                    _buildInfoCard('Date', event.date),
                    const SizedBox(height: 16),
                    _buildInfoCard('Location', event.location ?? 'Sin ubicación'),
                    const SizedBox(height: 16),
                    _buildInfoCard('Attendees', '${event.recipientIds.length}'),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.pushNamed(
                                context,
                                '/events/update',
                                arguments: event.id,
                              );
                              if (result == true) {
                                context.read<EventBloc>().add(LoadEventById(widget.eventId));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFA68FCC),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'Edit',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _deleteEvent,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      );
    }

    Widget _buildInfoCard(String label, String value) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF30214A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFA68FCC),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
  }