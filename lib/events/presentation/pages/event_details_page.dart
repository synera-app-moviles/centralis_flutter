import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
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
  String? _loadedForEventId;
  bool _loadingAttendees = false;
  final List<Map<String, String?>> _attendees = [];

  @override
  void initState() {
    super.initState();
    context.read<EventBloc>().add(LoadEventById(widget.eventId));
  }

  Future<void> _fetchAttendees(List<String> ids) async {
    if (!mounted) return;
    if (ids.isEmpty) {
      if (mounted) setState(() {
        _attendees.clear();
        _loadingAttendees = false;
      });
      return;
    }

    if (mounted) setState(() {
      _loadingAttendees = true;
      _attendees.clear();
    });

    try {
      for (final id in ids) {
        try {
          final endpoint = ApiConstants.profileById.replaceAll('{id}', id);
          final resp = await sl<ApiClient>().get(endpoint, requireAuth: true);
          final data = jsonDecode(resp.body) as Map<String, dynamic>;

          final first = (data['firstName'] ?? data['first_name'])?.toString();
          final last = (data['lastName'] ?? data['last_name'])?.toString();
          final fullFromParts = ((first ?? '') + ' ' + (last ?? '')).trim();
          final rawName = (data['fullName'] ??
                  data['name'] ??
                  (fullFromParts.isNotEmpty ? fullFromParts : null) ??
                  data['username'] ??
                  data['profileId'] ??
                  data['id'])
              ?.toString();
          final name = (rawName != null && rawName.isNotEmpty) ? rawName : 'Usuario';
          final avatar = (data['photoUrl'] ?? data['avatar'] ?? data['imageUrl'] ?? data['avatarUrl'])?.toString();

          _attendees.add({
            'id': id,
            'name': name,
            'avatar': avatar,
          });
        } catch (e) {
          _attendees.add({
            'id': id,
            'name': 'Usuario',
            'avatar': null,
          });
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching attendees: $e');
    } finally {
      if (mounted) setState(() {
        _loadingAttendees = false;
      });
    }
  }

  bool _shouldFetchAttendees(List<String> newIds) {
    final currentIds = _attendees.map((a) => a['id']).whereType<String>().toSet();
    final incomingIds = newIds.toSet();
    return !setEquals(currentIds, incomingIds);
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
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<EventBloc, EventState>(
        listener: (context, state) {
          if (state is EventUpdatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.pop(context, true);
          } else if (state is EventDeletedSuccess) {
            Navigator.pop(context, true);
          } else if (state is EventError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }

          if (state is EventLoaded) {
            final event = state.event;
            if (_loadedForEventId != event.id || _shouldFetchAttendees(event.recipientIds)) {
              _loadedForEventId = event.id;
              _fetchAttendees(event.recipientIds);
            }
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
                  _buildAttendeesSection(event),
                  const SizedBox(height: 24),
                  // language: dart
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.pushNamed(
                                context,
                                '/events/update',
                                arguments: event.id,
                              );
                              if (result == true) {
                                context.read<EventBloc>().add(LoadEventById(widget.eventId));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Event updated successfully')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFA68FCC),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: const Text(
                                  'Edit',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => DeleteEventDialog(
                                  onConfirm: () {
                                    context.read<EventBloc>().add(DeleteEvent(widget.eventId));
                                  },
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: const Text(
                                  'Delete',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
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
          if (state is EventError) {
            return Center(
              child: Text(
                state.error,
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAttendeesSection(event) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF30214A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendees',
            style: TextStyle(
              color: Color(0xFFA68FCC),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (_loadingAttendees)
            const Center(child: CircularProgressIndicator(color: Color(0xFFA68FCC)))
          else if (_attendees.isEmpty)
            Text(
              '${event.recipientIds.length} asistentes',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _attendees.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white12),
              itemBuilder: (context, index) {
                final a = _attendees[index];
                final avatar = a['avatar'];
                final name = a['name'] ?? 'Usuario';
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF30214A),
                    backgroundImage: (avatar != null && avatar.isNotEmpty) ? NetworkImage(avatar) : null,
                    child: (avatar == null || avatar.isEmpty)
                        ? const Icon(Icons.person, color: Colors.white, size: 22)
                        : null,
                  ),
                  title: Text(name, style: const TextStyle(color: Colors.white)),
                );
              },
            ),
        ],
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