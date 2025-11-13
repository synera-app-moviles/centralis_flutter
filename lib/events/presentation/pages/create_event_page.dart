import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/di/service_locator.dart';
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

  List<Map<String, dynamic>> _profiles = [];
  final Set<String> _selectedIds = {};
  String _search = '';
  bool _loadingProfiles = true;

  @override
  void initState() {
    super.initState();
    _fetchProfiles();
  }

  Future<void> _fetchProfiles() async {
    try {
      final api = sl<ApiClient>();
      final resp = await api.get(ApiConstants.profiles, requireAuth: true);
      final List<dynamic> data = jsonDecode(resp.body);
      setState(() {
        _profiles = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _loadingProfiles = false;
      });
    } catch (e) {
      setState(() => _loadingProfiles = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading users: $e')));
    }
  }

  Future<void> _createEvent() async {
    if (_formKey.currentState!.validate()) {
      if (_dateTime.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona fecha y hora')),
        );
        return;
      }

      final storage = sl<SecureStorageService>();
      final createdBy = await storage.getUserId() ?? '';


      final recipients = _selectedIds.toList();

      final request = CreateEventRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _dateTime,
        location: _locationController.text.trim(),
        recipientIds: recipients,
        createdBy: createdBy,
      );

      context.read<EventBloc>().add(CreateEvent(request));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _profiles.where((p) {
      final name = (p['fullName'] ?? p['name'] ?? p['username'] ?? '').toString().toLowerCase();
      return name.contains(_search.toLowerCase());
    }).toList();

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
          if (state is EventCreatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.pop(context, true);
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
                        child: filtered.isEmpty
                            ? const Center(child: Text('No users', style: TextStyle(color: Colors.white54)))
                            : ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) => const Divider(color: Colors.white12),
                                itemBuilder: (context, idx) {
                                  final p = filtered[idx];
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