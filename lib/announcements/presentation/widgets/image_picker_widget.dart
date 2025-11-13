import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';

class ImagePicker extends StatelessWidget {
  final String? selectedImageUrl;
  final VoidCallback onPickImage;
  final VoidCallback? onRemoveImage;

  const ImagePicker({
    super.key,
    this.selectedImageUrl,
    required this.onPickImage,
    this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AnnouncementColors.cardBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onPickImage,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.image, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'Add Image',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Preview de imagen
        if (selectedImageUrl != null) ...[
          const SizedBox(height: 16),
          const Text(
            'Preview:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  selectedImageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AnnouncementColors.textSecondary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.image_not_supported,
                        color: AnnouncementColors.textSecondary,
                        size: 48,
                      ),
                    );
                  },
                ),
              ),
              if (onRemoveImage != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: onRemoveImage,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}