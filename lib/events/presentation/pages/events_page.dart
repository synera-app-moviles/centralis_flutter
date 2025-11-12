import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/event_bloc.dart';
import '../bloc/event_event.dart';
import '../bloc/event_state.dart';
import '../widgets/event_card.dart';
import '../widgets/delete_event_dialog.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    context.read<EventBloc>().add(const LoadEvents(userId: null, filterType: null));
  }

  Future<void> _openCreate() async {
    final result = await Navigator.pushNamed(context, '/events/create');
    if (result == true) {
      _load();
    }
  }

  Future<void> _openDetails(String id) async {
    final result = await Navigator.pushNamed(context, '/events/details', arguments: id);
    if (result == true) {
      _load();
    }
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => DeleteEventDialog(
        onConfirm: () {
          context.read<EventBloc>().add(DeleteEvent(id));
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
        title: const Text(
          'Events',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFA68FCC),
        onPressed: _openCreate,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocConsumer<EventBloc, EventState>(
        listener: (context, state) {
          if (state is EventCreatedSuccess ||
              state is EventUpdatedSuccess ||
              state is EventDeletedSuccess) {
            _load();
            context.read<EventBloc>().add(ResetEventState());
          }
        },
        builder: (context, state) {
          if (state is EventLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFA68FCC)));
          }

          if (state is EventsLoaded) {
            if (state.events.isEmpty) {
              return const Center(
                child: Text('No hay eventos', style: TextStyle(color: Colors.white70)),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.only(top: 32),
              itemCount: state.events.length,
              itemBuilder: (context, index) {
                final ev = state.events[index];
                return EventCard(
                  event: ev,
                  onTap: () => _openDetails(ev.id),
                  onDelete: () => _confirmDelete(ev.id),
                );
              },
            );
          }

          if (state is EventError) {
            return Center(
              child: Text(
                state.error,
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (state is EventInitial) {
            _load();
            return const Center(child: CircularProgressIndicator());
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}