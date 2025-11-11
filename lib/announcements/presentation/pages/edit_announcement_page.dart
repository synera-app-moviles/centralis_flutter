import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/theme/colors.dart';
import '../../../core/di/service_locator.dart';
import '../../../shared/widgets/image_picker_widget.dart';
import '../../../app/config/cloudinary_config.dart';
import '../bloc/announcement_bloc.dart';
import '../bloc/announcement_event.dart';
import '../bloc/announcement_state.dart';
import '../widgets/priority_selector.dart';
import '../../data/models/announcement.dart';
import '../../data/models/priority.dart';

class EditAnnouncementPage extends StatefulWidget {
  final Announcement announcement;

  const EditAnnouncementPage({
    super.key,
    required this.announcement,
  });

  @override
  State<EditAnnouncementPage> createState() => _EditAnnouncementPageState();
}

class _EditAnnouncementPageState extends State<EditAnnouncementPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late Priority _selectedPriority;
  String? _selectedImageUrl;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.announcement.title);
    _descriptionController = TextEditingController(text: widget.announcement.description);
    _selectedPriority = widget.announcement.priority;
    _selectedImageUrl = widget.announcement.image;
  }

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
            if (state is AnnouncementUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Announcement updated successfully!'),
                  backgroundColor: AnnouncementColors.success,
                ),
              );
              Navigator.pop(context, true); // Retornar true para indicar actualización
            } else if (state is AnnouncementError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: AnnouncementColors.error,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildForm(context),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        "Edit Announcement",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AnnouncementColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo título (prellenado)
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Title',
            labelStyle: TextStyle(color: AnnouncementColors.textSecondary),
            filled: true,
            fillColor: AnnouncementColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.all(16),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 16),
        
        // Campo descripción (prellenado)
        TextField(
          controller: _descriptionController,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'Description',
            labelStyle: TextStyle(color: AnnouncementColors.textSecondary),
            filled: true,
            fillColor: AnnouncementColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.all(16),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 24),
        
        // Sección de prioridad
        PrioritySelector(
          selectedPriority: _selectedPriority,
          onPriorityChanged: (priority) => setState(() => _selectedPriority = priority),
        ),
        const SizedBox(height: 24),
        
        // Sección de imagen
        const Text(
          'Announcement Image',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ImagePickerWidget(
          imageType: ImageType.announcement,
          currentImageUrl: _selectedImageUrl,
          onImageUploaded: (imageUrl) {
            setState(() {
              _selectedImageUrl = imageUrl;
            });
          },
          onImageRemoved: () {
            setState(() {
              _selectedImageUrl = null;
            });
          },
          buttonText: 'Change Image',
        ),
        
        const SizedBox(height: 32),
        
        // Botón actualizar
        BlocBuilder<AnnouncementBloc, AnnouncementState>(
          builder: (context, state) {
            final isLoading = state is AnnouncementLoading;
            
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : () => _updateAnnouncement(context),
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
                      'Update Announcement',
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
      ],
    );
  }

  void _updateAnnouncement(BuildContext context) {
    context.read<AnnouncementBloc>().add(
      AnnouncementUpdateRequested(
        announcementId: widget.announcement.id,
        title: _titleController.text,
        description: _descriptionController.text,
        image: _selectedImageUrl,
        priority: _selectedPriority,
      ),
    );
  }
}