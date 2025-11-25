import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

/// Widget para seleccionar y enviar imágenes en el chat
class ImageAttachmentWidget extends StatelessWidget {
  final String groupId;
  final String senderId;
  final VoidCallback? onImageSent;

  const ImageAttachmentWidget({
    super.key,
    required this.groupId,
    required this.senderId,
    this.onImageSent,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is ChatImageUploaded) {
          // Imagen enviada exitosamente
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Imagen enviada'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          onImageSent?.call();
        } else if (state is ChatError && state.message.contains('image')) {
          // Error al enviar imagen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${state.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          final isUploading = state is ChatImageUploading && state.groupId == groupId;
          
          return IconButton(
            onPressed: isUploading ? null : () => _showImageOptions(context),
            icon: isUploading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: (state as ChatImageUploading).progress,
                    ),
                  )
                : const Icon(Icons.image),
            tooltip: isUploading ? 'Enviando imagen...' : 'Adjuntar imagen',
          );
        },
      ),
    );
  }

  void _showImageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Seleccionar imagen',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Cámara
                  _buildOption(
                    context,
                    icon: Icons.camera_alt,
                    label: 'Cámara',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(context, ImageSource.camera);
                    },
                  ),
                  
                  // Galería
                  _buildOption(
                    context,
                    icon: Icons.photo_library,
                    label: 'Galería',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(context, ImageSource.gallery);
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Cancelar
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 768,
        imageQuality: 85,
      );

      if (image != null) {
        // Enviar evento para subir la imagen
        context.read<ChatBloc>().add(
          ChatImageUploadRequested(
            groupId: groupId,
            senderId: senderId,
            imagePath: image.path,
          ),
        );
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error seleccionando imagen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}