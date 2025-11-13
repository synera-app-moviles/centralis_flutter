import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../data/models/create_event_request.dart';
import '../bloc/event_bloc.dart';
import '../bloc/event_event.dart';
import '../bloc/event_state.dart';
import '../widgets/date_time_picker_field.dart';
import '../../../core/storage/secure_storage_service.dart';

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

  bool _loadingProfiles = false;
  List<Map<String, dynamic>> _profiles = [];
  String _search = '';
  final Set<String> _selectedIds = {};
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _fetchProfiles();
  }

  // dart
  Future<void> _fetchProfiles() async {
    setState(() => _loadingProfiles = true);
    try {
      final token = await sl<SecureStorageService>().getToken();
      print('🔍 _fetchProfiles: token="$token"');

      final resp = await sl<ApiClient>().get(ApiConstants.profiles, requireAuth: true);
      print('🔍 _fetchProfiles: status=${resp.statusCode}');
      print('🔍 _fetchProfiles: body (primeros 500 chars): ${resp.body.length > 500 ? resp.body.substring(0, 500) + "..." : resp.body}');

      final List<dynamic> data = jsonDecode(resp.body);
      _profiles = data.map((e) {
        if (e is Map<String, dynamic>) return e;
        return Map<String, dynamic>.from(e as Map);
      }).toList();
    } catch (e, st) {
      print('❌ _fetchProfiles error: $e\n$st');


      try {
        final respNoAuth = await sl<ApiClient>().get(ApiConstants.profiles, requireAuth: false);
        print('🔁 Prueba sin auth - status=${respNoAuth.statusCode}');
        print('🔁 Prueba sin auth - body (primeros 500 chars): ${respNoAuth.body.length > 500 ? respNoAuth.body.substring(0, 500) + "..." : respNoAuth.body}');

        final List<dynamic> data = jsonDecode(respNoAuth.body);
        _profiles = data.map((e) {
          if (e is Map<String, dynamic>) return e;
          return Map<String, dynamic>.from(e as Map);
        }).toList();
      } catch (e2, st2) {
        print('❌ Fallback sin auth falló: $e2\n$st2');
        _profiles = [];
      }
    } finally {
      if (mounted) setState(() => _loadingProfiles = false);
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      final createdBy = await sl<SecureStorageService>().getUserId() ?? '';

      final request = CreateEventRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _dateTime.isEmpty ? DateTime.now().toIso8601String() : _dateTime,
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        recipientIds: _selectedIds.toList(),
        createdBy: createdBy,
      );

      context.read<EventBloc>().add(CreateEvent(request));
    } finally {
      if (mounted) setState(() => _submitting = false);
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
        title: const Text('Create Event', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: BlocConsumer<EventBloc, EventState>(
        listener: (context, state) {
          if (state is EventCreatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context, true);
          } else if (state is EventError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          final isLoading = state is EventLoading || _submitting;
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
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
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
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a description' : null,
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
                                            else if (id.isNotEmpty) _selectedIds.add(id);
                                          });
                                        },
                                      ),
                                      onTap: () {
                                        setState(() {
                                          if (selected) _selectedIds.remove(id);
                                          else if (id.isNotEmpty) _selectedIds.add(id);
                                        });
                                      },
                                    );
                                  },
                                ),
                        ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading ? null : _createEvent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA68FCC),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Create Event', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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