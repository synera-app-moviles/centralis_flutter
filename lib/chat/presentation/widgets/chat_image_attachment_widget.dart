import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../shared/widgets/image_picker_widget.dart';
import '../../../shared/theme/colors.dart';
import '../../../app/config/cloudinary_config.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';

/// Widget para adjuntar imágenes en el chat
class ChatImageAttachmentWidget extends StatefulWidget {
  final String groupId;
  final String currentUserId;

  const ChatImageAttachmentWidget({
    super.key,
    required this.groupId,
    required this.currentUserId,
  });

  @override
  State<ChatImageAttachmentWidget> createState() => _ChatImageAttachmentWidgetState();
}

class _ChatImageAttachmentWidgetState extends State<ChatImageAttachmentWidget> {
  String? _selectedImageUrl;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    // Si hay una imagen seleccionada, mostrar el botón de envío
    if (_selectedImageUrl != null) {
      return _buildSendImageButton();
    }
    
    // Si no hay imagen, mostrar el botón de selección
    return _buildImagePickerButton();
  }

  Widget _buildImagePickerButton() {
    return Container(
      decoration: BoxDecoration(
        color: CentralisColors.primary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(
          Icons.photo_camera,
          color: Colors.white,
          size: 24,
        ),
        onPressed: _showImagePickerDialog,
      ),
    );
  }

  Widget _buildSendImageButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: _isUploading 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : const Icon(
                Icons.send,
                color: Colors.white,
                size: 24,
              ),
        onPressed: _isUploading ? null : _sendImage,
      ),
    );
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: CentralisColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: CentralisColors.placeholder,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Seleccionar imagen',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Contenido del selector de imágenes
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ImagePickerWidget(
                  imageType: ImageType.chat,
                  onImageUploaded: _handleImageSelected,
                  buttonText: 'Seleccionar imagen para el chat',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleImageSelected(String imageUrl) {
    print('📸 Imagen seleccionada: $imageUrl');
    setState(() {
      _selectedImageUrl = imageUrl;
    });
    Navigator.of(context).pop(); // Cerrar el modal
  }

  void _sendImage() async {
    if (_selectedImageUrl == null || _isUploading) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final chatBloc = sl<ChatBloc>();
      chatBloc.add(ChatImageSendRequested(
        groupId: widget.groupId,
        senderId: widget.currentUserId,
        imageUrl: _selectedImageUrl!,
      ));

      // Limpiar la imagen seleccionada
      setState(() {
        _selectedImageUrl = null;
        _isUploading = false;
      });

      print('📸 Imagen enviada exitosamente');
    } catch (error) {
      print('❌ Error al enviar imagen: $error');
      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar imagen: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeSelectedImage() {
    print('🗑️ Imagen removida de la previsualización');
    setState(() {
      _selectedImageUrl = null;
    });
  }
}