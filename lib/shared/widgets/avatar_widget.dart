import 'package:flutter/material.dart';
import '../../app/config/cloudinary_config.dart';
import '../theme/colors.dart';
import 'image_picker_widget.dart';

/// Widget especializado para mostrar y editar avatares de usuario
class AvatarWidget extends StatefulWidget {
  final String? imageUrl;
  final Function(String) onImageChanged;
  final VoidCallback? onImageRemoved;
  final double size;
  final bool isEditable;
  final bool showEditHint;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    required this.onImageChanged,
    this.onImageRemoved,
    this.size = 120,
    this.isEditable = true,
    this.showEditHint = true,
  });

  @override
  State<AvatarWidget> createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends State<AvatarWidget> {
  bool _showImagePicker = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 👤 Avatar circular
        _buildAvatarDisplay(),
        
        // 📝 Texto informativo
        if (widget.showEditHint && widget.isEditable)
          _buildEditHint(),
        
        // 🎛️ Image picker expandible
        if (_showImagePicker && widget.isEditable)
          _buildImagePickerSection(),
      ],
    );
  }

  Widget _buildAvatarDisplay() {
    return GestureDetector(
      onTap: widget.isEditable ? _toggleImagePicker : null,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: CentralisColors.primary,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: CentralisColors.primary.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
              ? _buildNetworkImage()
              : _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildNetworkImage() {
    return Image.network(
      widget.imageUrl!,
      width: widget.size,
      height: widget.size,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: CentralisColors.background,
          ),
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / 
                    loadingProgress.expectedTotalBytes!
                  : null,
              color: CentralisColors.primary,
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('🖼️ Error loading avatar: $error');
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            CentralisColors.primary.withOpacity(0.3),
            CentralisColors.primary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.person,
        size: widget.size * 0.5,
        color: CentralisColors.primary,
      ),
    );
  }

  Widget _buildEditHint() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        widget.imageUrl == null || widget.imageUrl!.isEmpty
            ? 'Toca para agregar foto'
            : 'Toca para cambiar foto',
        style: TextStyle(
          color: CentralisColors.onBackground.withOpacity(0.7),
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildImagePickerSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        color: CentralisColors.secondary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 🔄 Botón para cerrar/minimizar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cambiar Avatar',
                    style: TextStyle(
                      color: CentralisColors.onBackground,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _showImagePicker = false),
                    icon: Icon(
                      Icons.keyboard_arrow_up,
                      color: CentralisColors.onBackground,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // 📤 Image picker widget
              ImagePickerWidget(
                imageType: ImageType.avatar,
                currentImageUrl: widget.imageUrl,
                onImageUploaded: (imageUrl) {
                  widget.onImageChanged(imageUrl);
                  setState(() => _showImagePicker = false);
                },
                onImageRemoved: widget.onImageRemoved != null 
                    ? () {
                        widget.onImageRemoved!();
                        setState(() => _showImagePicker = false);
                      }
                    : null,
                buttonText: 'Seleccionar Nueva Foto',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleImagePicker() {
    setState(() {
      _showImagePicker = !_showImagePicker;
    });
  }
}

/// Widget simple para mostrar avatar sin capacidad de edición
class AvatarDisplay extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final Color? borderColor;

  const AvatarDisplay({
    super.key,
    this.imageUrl,
    this.size = 40,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return AvatarWidget(
      imageUrl: imageUrl,
      onImageChanged: (_) {}, // No hace nada
      size: size,
      isEditable: false,
      showEditHint: false,
    );
  }
}