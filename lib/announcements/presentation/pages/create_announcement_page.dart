import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/theme/colors.dart';
import '../../../core/di/service_locator.dart';
import '../bloc/announcement_bloc.dart';
import '../bloc/announcement_event.dart';
import '../bloc/announcement_state.dart';
import '../widgets/priority_selector.dart';
import '../widgets/image_picker_widget.dart' as announce_widgets;
import '../../data/models/priority.dart';

class CreateAnnouncementPage extends StatefulWidget {
  const CreateAnnouncementPage({super.key});

  @override
  State<CreateAnnouncementPage> createState() => _CreateAnnouncementPageState();
}

class _CreateAnnouncementPageState extends State<CreateAnnouncementPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Priority _selectedPriority = Priority.normal;
  String? _selectedImageUrl;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AnnouncementBloc>(),
      child: Scaffold(
        backgroundColor: AnnouncementColors.background,
        appBar: _buildAppBar(context),
        body: BlocListener<AnnouncementBloc, AnnouncementState>(
          listener: (context, state) {
            if (state is AnnouncementCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Announcement created successfully!'),
                  backgroundColor: AnnouncementColors.success,
                ),
              );
              Navigator.pop(context);
            } else if (state is AnnouncementError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: AnnouncementColors.error,
                ),
              );
            }
          },
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildForm(),
                ),
              ),
              _buildPublishButton(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        "New Announcement",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AnnouncementColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo título
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: 'Announcement Title',
            hintStyle: TextStyle(color: AnnouncementColors.textSecondary),
            filled: true,
            fillColor: AnnouncementColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.all(16),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        
        // Campo descripción
        TextField(
          controller: _descriptionController,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Write the announcement details...',
            hintStyle: TextStyle(color: AnnouncementColors.textSecondary),
            filled: true,
            fillColor: AnnouncementColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.all(16),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        
        // Selector de imagen
        announce_widgets.ImagePicker(
          selectedImageUrl: _selectedImageUrl,
          onPickImage: _pickImage,
          onRemoveImage: () => setState(() => _selectedImageUrl = null),
        ),
        const SizedBox(height: 24),
        
        // Selector de prioridad
        PrioritySelector(
          selectedPriority: _selectedPriority,
          onPriorityChanged: (priority) => setState(() => _selectedPriority = priority),
        ),
      ],
    );
  }

  Widget _buildPublishButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      color: AnnouncementColors.background,
      child: BlocBuilder<AnnouncementBloc, AnnouncementState>(
        builder: (context, state) {
          final isLoading = state is AnnouncementLoading;
          
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading || !_canPublish() ? null : () => _publishAnnouncement(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AnnouncementColors.primary,
                disabledBackgroundColor: AnnouncementColors.textSecondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: isLoading 
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Publish Announcement',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            ),
          );
        },
      ),
    );
  }

  bool _canPublish() {
    return _titleController.text.isNotEmpty && 
           _descriptionController.text.isNotEmpty;
  }

  void _pickImage() {
    // TODO: Implement image picking functionality
    // For now, show a dialog to simulate image selection
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AnnouncementColors.cardBackground,
          title: const Text(
            'Select Image',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Image picker not implemented yet. Would you like to use a sample image?',
            style: TextStyle(color: AnnouncementColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AnnouncementColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedImageUrl = 'https://via.placeholder.com/400x200.png?text=Sample+Image';
                });
                Navigator.pop(context);
              },
              child: const Text(
                'Use Sample',
                style: TextStyle(color: AnnouncementColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _publishAnnouncement(BuildContext context) {
    context.read<AnnouncementBloc>().add(
      AnnouncementCreateRequested(
        title: _titleController.text,
        description: _descriptionController.text,
        image: _selectedImageUrl,
        priority: _selectedPriority,
        createdBy: 'current-user-id', // TODO: Get from current user
      ),
    );
  }
}