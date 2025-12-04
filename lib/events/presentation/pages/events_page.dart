import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/event_model.dart';
import '../bloc/event_bloc.dart';
import '../bloc/event_event.dart';
import '../bloc/event_state.dart';
import '../widgets/event_card.dart';
import '../widgets/delete_event_dialog.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final List<EventModel> _events = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final storage = sl<SecureStorageService>();
    final client = sl<ApiClient>();
    final userId = await storage.getUserId();

    try {

      final endpointWithUser = ApiConstants.events +
          (userId != null && userId.isNotEmpty ? '?user_id=${Uri.encodeQueryComponent(userId)}' : '');
      print('🔍 EventsPage: probe con userId -> $endpointWithUser');
      final resp = await client.get(endpointWithUser, requireAuth: true);
      print('🔍 EventsPage: status=${resp.statusCode} body=${resp.body}');
      final parsed = (resp.body.isNotEmpty) ? jsonDecode(resp.body) : null;

      if (!mounted) return;

      if (parsed is List && parsed.isNotEmpty) {
        context.read<EventBloc>().add(LoadEvents(userId: userId));
        return;
      }
    } catch (e, st) {
      print('❌ EventsPage: error probe con userId: $e\n$st');
      if (!mounted) return;
    }

    try {
      print('🔁 EventsPage: probe fallback sin userId -> ${ApiConstants.events}');
      final resp2 = await client.get(ApiConstants.events, requireAuth: true);
      print('🔁 EventsPage: fallback status=${resp2.statusCode} body=${resp2.body}');
      final parsed2 = (resp2.body.isNotEmpty) ? jsonDecode(resp2.body) : null;

      if (!mounted) return;

      if (parsed2 is List && parsed2.isNotEmpty) {
        context.read<EventBloc>().add(const LoadEvents(userId: null));
        return;
      }
    } catch (e, st) {
      print('❌ EventsPage: error fallback sin userId: $e\n$st');
      if (!mounted) return;
    }

    if (!mounted) return;
    context.read<EventBloc>().add(LoadEvents(userId: userId));
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event updated/removed')),
      );
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
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _openCreate,
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: BlocConsumer<EventBloc, EventState>(
        listener: (context, state) {
          if (state is EventLoading) {
            setState(() => _loading = true);
          } else {
            setState(() => _loading = false);
          }

          if (state is EventsLoaded) {
            setState(() {
              _events.clear();
              _events.addAll(state.events);
            });
            context.read<EventBloc>().add(ResetEventState());
          } else if (state is EventCreatedSuccess) {
            setState(() {
              _events.insert(0, state.createdEvent);
            });
            context.read<EventBloc>().add(ResetEventState());
          } else if (state is EventUpdatedSuccess) {
            setState(() {
              final idx = _events.indexWhere((e) => e.id == state.updatedEvent.id);
              if (idx != -1) _events[idx] = state.updatedEvent;
            });
            context.read<EventBloc>().add(ResetEventState());
          } else if (state is EventDeletedSuccess) {
            setState(() {
              _events.removeWhere((e) => e.id == state.eventId);
            });
            context.read<EventBloc>().add(ResetEventState());
          } else if (state is EventError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
            context.read<EventBloc>().add(ResetEventState());
          }
        },
        builder: (context, state) {
          if (_loading && _events.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFA68FCC)));
          }

          if (_events.isEmpty) {
            return const Center(
              child: Text('No hay eventos', style: TextStyle(color: Colors.white70)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 32),
            itemCount: _events.length,
            itemBuilder: (context, index) {
              final ev = _events[index];
              return EventCard(
                event: ev,
                onTap: () => _openDetails(ev.id),
                onDelete: () => _confirmDelete(ev.id),
              );
            },
          );
        },
      ),
    );
  }
}