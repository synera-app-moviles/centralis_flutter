import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../app/config/cloudinary_config.dart';
import '../../core/services/cloudinary_service.dart';
import '../theme/colors.dart';

/// Componente para seleccionar y subir imágenes
class ImagePickerWidget extends StatefulWidget {
  final ImageType imageType;
  final String? currentImageUrl;
  final Function(String) onImageUploaded;
  final VoidCallback? onImageRemoved;
  final String? buttonText;
  final double? width;
  final double? height;

  const ImagePickerWidget({
    super.key,
    required this.imageType,
    required this.onImageUploaded,
    this.currentImageUrl,
    this.onImageRemoved,
    this.buttonText,
    this.width,
    this.height,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePicker _picker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  
  UploadState _uploadState = const UploadIdle();
  double _uploadProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 📤 Botón principal de subida
        _buildUploadButton(),
        
        // 📊 Indicador de progreso
        if (_uploadState is UploadProgress || _uploadState is UploadLoading)
          _buildProgressIndicator(),
        
        // ❌ Mensaje de error
        if (_uploadState is UploadError)
          _buildErrorMessage(),
        
        // ✅ Mensaje de éxito
        if (_uploadState is UploadSuccess)
          _buildSuccessMessage(),
        
        // 🗑️ Botón para eliminar imagen actual
        if (widget.currentImageUrl != null && _uploadState is! UploadLoading)
          _buildRemoveButton(),
      ],
    );
  }

  Widget _buildUploadButton() {
    final isLoading = _uploadState is UploadLoading || _uploadState is UploadProgress;
    
    return SizedBox(
      width: widget.width,
      height: widget.height ?? 48,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : _showImageSourceDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: CentralisColors.primary,
          foregroundColor: CentralisColors.onPrimary,
          disabledBackgroundColor: CentralisColors.primary.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(CentralisColors.onPrimary),
                ),
              )
            : Icon(_getIconForType()),
        label: Text(
          isLoading 
              ? 'Uploading...' 
              : widget.buttonText ?? _getDefaultButtonText(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: _uploadProgress,
            backgroundColor: CentralisColors.placeholder.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(CentralisColors.primary),
          ),
          const SizedBox(height: 4),
          Text(
            'Uploading image... ${(_uploadProgress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 12,
              color: CentralisColors.onBackground.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    final error = _uploadState as UploadError;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error.message,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CentralisColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: CentralisColors.success.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, color: CentralisColors.success, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Image uploaded successfully',
              style: TextStyle(
                color: CentralisColors.success,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoveButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextButton.icon(
        onPressed: widget.onImageRemoved,
        style: TextButton.styleFrom(
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        icon: const Icon(Icons.delete_outline, size: 18),
        label: const Text('Remove current image'),
      ),
    );
  }

  IconData _getIconForType() {
    switch (widget.imageType) {
      case ImageType.avatar:
        return Icons.account_circle;
      case ImageType.chat:
        return Icons.image;
      case ImageType.announcement:
        return Icons.photo_library;
    }
  }

  String _getDefaultButtonText() {
    switch (widget.imageType) {
      case ImageType.avatar:
        return 'Select Avatar';
      case ImageType.chat:
        return 'Send Image';
      case ImageType.announcement:
        return 'Add Image';
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: CentralisColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 📋 Título
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: CentralisColors.placeholder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Select Image',
                  style: TextStyle(
                    color: CentralisColors.onBackground,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                // 📷 Opciones
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSourceOption(
                      icon: Icons.camera_alt,
                      label: 'Cámara',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImageFromCamera();
                      },
                    ),
                    _buildSourceOption(
                      icon: Icons.photo_library,
                      label: 'Galería',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImageFromGallery();
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: CentralisColors.secondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CentralisColors.primary.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: CentralisColors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: CentralisColors.onBackground,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    if (!await _requestCameraPermission()) {
      setState(() {
        _uploadState = const UploadError('Permiso de cámara requerido');
      });
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      
      if (image != null) {
        await _uploadImage(image.path);
      }
    } catch (e) {
      setState(() {
        _uploadState = UploadError('Error al acceder a la cámara: $e');
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    if (!await _requestStoragePermission()) {
      setState(() {
        _uploadState = const UploadError('Permiso de almacenamiento requerido');
      });
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      
      if (image != null) {
        await _uploadImage(image.path);
      }
    } catch (e) {
      setState(() {
        _uploadState = UploadError('Error al acceder a la galería: $e');
      });
    }
  }

  Future<void> _uploadImage(String imagePath) async {
    setState(() {
      _uploadState = const UploadLoading();
      _uploadProgress = 0.0;
    });

    try {
      final imageUrl = await _cloudinaryService.uploadImage(
        imagePath,
        widget.imageType,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
            _uploadState = UploadProgress(progress);
          });
        },
      );

      setState(() {
        _uploadState = UploadSuccess(imageUrl);
      });

      // 📢 Notificar la URL de la imagen subida
      widget.onImageUploaded(imageUrl);

      // 🕐 Limpiar estado de éxito después de 3 segundos
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _uploadState = const UploadIdle();
          });
        }
      });

    } catch (e) {
      setState(() {
        _uploadState = UploadError(e.toString());
      });
    }
  }

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isDenied) {
      _showPermissionDialog('Cámara', 'para tomar fotos');
    }
    return status.isGranted;
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Para Android 13+ (API 33+) usar los nuevos permisos
      if (await _isAndroid13OrHigher()) {
        final status = await Permission.photos.request();
        if (status.isDenied) {
          _showPermissionDialog('Fotos', 'para acceder a la galería');
        }
        return status.isGranted;
      } else {
        // Para Android 12 y anteriores
        final status = await Permission.storage.request();
        if (status.isDenied) {
          _showPermissionDialog('Almacenamiento', 'para acceder a la galería');
        }
        return status.isGranted;
      }
    }
    return true; // iOS no requiere permiso explícito para galería
  }

  Future<bool> _isAndroid13OrHigher() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt >= 33;
    }
    return false;
  }

  void _showPermissionDialog(String permissionName, String reason) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CentralisColors.secondary,
        title: Text(
          'Permiso Requerido',
          style: TextStyle(color: CentralisColors.onBackground),
        ),
        content: Text(
          'Esta aplicación necesita acceso a $permissionName $reason. Ve a Configuración > Aplicaciones > Centralis > Permisos para habilitarlo.',
          style: TextStyle(color: CentralisColors.onBackground),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text('Configuración'),
          ),
        ],
      ),
    );
  }
}