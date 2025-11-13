import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
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

  bool _initialized = false;

  // Nuevas variables para selección de asistentes
  bool _loadingProfiles = false;
  List<Map<String, dynamic>> _profiles = [];
  String _search = '';
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    context.read<EventBloc>().add(LoadEventById(widget.eventId));
    _fetchProfiles();
  }

  Future<void> _fetchProfiles() async {
    setState(() => _loadingProfiles = true);
    try {
      final resp = await sl<ApiClient>().get(ApiConstants.profiles, requireAuth: true);
      final List<dynamic> data = jsonDecode(resp.body);
      _profiles = data.map((e) {
        if (e is Map<String, dynamic>) return e;
        return Map<String, dynamic>.from(e as Map);
      }).toList();
    } catch (_) {
      _profiles = [];
    } finally {
      if (mounted) setState(() => _loadingProfiles = false);
    }
  }

  void _updateEvent() {
    if (_formKey.currentState!.validate()) {
      final request = UpdateEventRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _dateTime.isEmpty ? null : _dateTime,
        location: _locationController.text.trim(),
        recipientIds: _selectedIds.isEmpty ? null : _selectedIds.toList(),
      );

      context.read<EventBloc>().add(UpdateEvent(widget.eventId, request));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredProfiles = _profiles.where((p) {
      final display = (p['fullName'] ?? p['name'] ?? p['username'] ?? p['profileId'] ?? p['id'])?.toString().toLowerCase() ?? '';
      return display.contains(_search.toLowerCase());
    }).toList();

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
          if (state is EventUpdatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context, true);
          } else if (state is EventError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          if (state is EventLoading && !_initialized) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFA68FCC)));
          }

          if (state is EventLoaded && !_initialized) {
            _titleController.text = state.event.title;
            _descriptionController.text = state.event.description;
            _locationController.text = state.event.location ?? '';
            _dateTime = state.event.date;
            _selectedIds.clear();
            _selectedIds.addAll(state.event.recipientIds);
            _initialized = true;
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
                  const SizedBox(height: 20),
                  const Text('Buscar empleados', style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 8),
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Buscar por nombre',
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Color(0xFF30214A),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    onChanged: (v) => setState(() => _search = v),
                  ),
                  const SizedBox(height: 12),
                  _loadingProfiles
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFA68FCC)))
                      : SizedBox(
                          height: 220,
                          child: filteredProfiles.isEmpty
                              ? const Center(child: Text('No users', style: TextStyle(color: Colors.white54)))
                              : ListView.separated(
                                  itemCount: filteredProfiles.length,
                                  separatorBuilder: (_, __) => const Divider(color: Colors.white12),
                                  itemBuilder: (context, idx) {
                                    final p = filteredProfiles[idx];
                                    final id = (p['profileId'] ?? p['id'] ?? p['userId'] ?? '').toString();
                                    final display = (p['fullName'] ?? p['name'] ?? p['username'] ?? id).toString();
                                    final avatar = (p['photoUrl'] ?? p['avatar'] ?? p['imageUrl'])?.toString();
                                    final selected = _selectedIds.contains(id);
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: const Color(0xFF30214A),
                                        backgroundImage: avatar != null && avatar.isNotEmpty ? NetworkImage(avatar) : null,
                                        child: avatar == null || avatar.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
                                      ),
                                      title: Text(display, style: const TextStyle(color: Colors.white)),
                                      trailing: Checkbox(
                                        value: selected,
                                        onChanged: (_) {
                                          setState(() {
                                            if (selected) _selectedIds.remove(id);
                                            else _selectedIds.add(id);
                                          });
                                        },
                                      ),
                                      onTap: () {
                                        setState(() {
                                          if (selected) _selectedIds.remove(id);
                                          else _selectedIds.add(id);
                                        });
                                      },
                                    );
                                  },
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